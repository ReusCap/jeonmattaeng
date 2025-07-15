import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/services/location_service.dart';
import 'package:jeonmattaeng/services/store_service.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // --- 상태 변수 ---
  bool _isLoading = true;
  List<Store> _allStores = [];
  Set<Marker> _markers = {};
  Store? _selectedStore;
  Position? _currentPosition;

  BitmapDescriptor _unselectedDotIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _selectedDotIcon = BitmapDescriptor.defaultMarker;


  // --- 상수 ---
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.1398, 126.8521),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons().then((_) {
      _goToMyLocation();
    });
  }

  /// 커스텀 마커 아이콘 생성
  Future<void> _loadMarkerIcons() async {
    final Uint8List unselectedBytes = await _createDotMarker(45, AppColors.primaryGreen);
    final Uint8List selectedBytes = await _createDotMarker(50, AppColors.heartRed);

    if (mounted) {
      setState(() {
        // ✅ [수정] fromBytes에 size 파라미터 추가
        _unselectedDotIcon = BitmapDescriptor.fromBytes(unselectedBytes, size: const Size.square(30));
        _selectedDotIcon = BitmapDescriptor.fromBytes(selectedBytes, size: const Size.square(45));
      });
    }
  }

  /// 테두리가 있는 원형 마커 아이콘을 그리는 함수
  Future<Uint8List> _createDotMarker(int size, Color color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint borderPaint = Paint()..color = Colors.white;
    final Paint dotPaint = Paint()..color = color;
    final double radius = size / 2;
    const double borderWidth = 3.0;

    canvas.drawCircle(Offset(radius, radius), radius, borderPaint);
    canvas.drawCircle(Offset(radius, radius), radius - borderWidth, dotPaint);

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }


  /// 위치 기반으로 서버로부터 가게 데이터를 가져오는 함수
  Future<void> _fetchStores({double? lat, double? lng}) async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final stores = await StoreService.fetchStores(lat: lat, lng: lng);
      if (!mounted) return;

      setState(() {
        _allStores = stores;

        if (_selectedStore != null) {
          _selectedStore = stores.firstWhereOrNull((s) => s.id == _selectedStore!.id);
        }

        _markers = _generateMarkers(stores, _selectedStore);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ 지도 가게 목록 로딩 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주변 가게 목록을 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  /// 현재 위치로 이동하고 주변 가게를 새로고침하는 함수
  Future<void> _goToMyLocation() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      _moveCameraTo(LatLng(position.latitude, position.longitude));
      await _fetchStores(lat: position.latitude, lng: position.longitude);

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _fetchStores(lat: _initialPosition.target.latitude, lng: _initialPosition.target.longitude);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 가져올 수 없습니다. 기본 위치로 검색합니다.')),
        );
      }
    }
  }

  /// 가게 목록과 선택된 가게를 기반으로 마커 Set을 생성하는 함수
  Set<Marker> _generateMarkers(List<Store> stores, Store? selectedStore) {
    if (_unselectedDotIcon == BitmapDescriptor.defaultMarker) return {};

    return stores.map((store) {
      final isSelected = selectedStore != null && store.id == selectedStore.id;
      return Marker(
        markerId: MarkerId(store.id),
        position: LatLng(store.lat, store.lng),
        icon: isSelected ? _selectedDotIcon : _unselectedDotIcon,
        anchor: const Offset(0.5, 0.5),
        onTap: () => _onMarkerTapped(store),
      );
    }).toSet();
  }

  /// 마커를 탭했을 때 호출되는 함수
  void _onMarkerTapped(Store store) {
    setState(() {
      _selectedStore = store;
      _markers = _generateMarkers(_allStores, store);
    });
    _moveCameraTo(LatLng(store.lat, store.lng));
  }

  /// 지도의 빈 공간을 탭했을 때 호출되는 함수
  void _onMapTapped() {
    setState(() {
      _selectedStore = null;
      _markers = _generateMarkers(_allStores, null);
    });
  }

  /// 특정 좌표로 카메라를 부드럽게 이동시키는 함수
  Future<void> _moveCameraTo(LatLng target) async {
    final GoogleMapController controller = await _controller.future;

    // 현재 지도의 줌 레벨을 가져옵니다.
    final double currentZoom = await controller.getZoomLevel();

    // 새로운 줌 레벨을 담을 변수를 선언합니다.
    double newZoom;

    // --- 핵심 로직 ---
    // 만약 현재 줌 레벨이 16보다 작다면 (지도가 멀리 있다면)
    if (currentZoom < 16.2) {
      // 목표 줌 레벨을 16으로 설정하여 '확대'합니다.
      newZoom = 16.2;
    } else {
      // 그렇지 않다면 (이미 16보다 가깝게 확대되어 있다면)
      // 현재 줌 레벨을 그대로 사용하여 '유지'합니다.
      newZoom = currentZoom;
    }

    // 최종적으로 계산된 줌 레벨로 카메라를 이동시킵니다.
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: newZoom),
    ));
  }

  /// 하단 정보 블록을 탭했을 때 메뉴 페이지로 이동하는 함수
  void _navigateToMenuPage(Store store) async {
    await Navigator.push<bool>(
      context,
      // ✅ [수정] MenuPage에 필수 파라미터 전달
      MaterialPageRoute(
        builder: (context) => MenuPage(
          storeId: store.id,
          storeName: store.name,
          storeCategory: store.foodCategory,
          storeImage: store.displayedImg,
          storeLikeCount: store.likeSum,
          storeLocation: store.location,
          storeLocationCategory: store.locationCategory,
        ),
      ),
    );

    if (_currentPosition != null && mounted) {
      _fetchStores(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0.5,
        centerTitle: true,
        title: Text('지도', style: AppTextStyles.title20SemiBold),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: _selectedStore != null ? 140 : 10, right: 4),
        child: FloatingActionButton(
          onPressed: _goToMyLocation,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryGreen,
          elevation: 4.0,
          shape: const CircleBorder(),
          child: const Icon(Icons.my_location),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
            markers: _markers,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            onTap: (_) => _onMapTapped(),
          ),
          if (_isLoading)
            Container(
              // ✅ [수정] withOpacity 대신 withAlpha 사용
              color: Colors.black.withAlpha(26),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _selectedStore != null ? 0 : -150,
            left: 0,
            right: 0,
            child: _buildStoreInfoBlock(),
          ),
        ],
      ),
    );
  }

  /// 하단 가게 정보 블록 UI 위젯
  Widget _buildStoreInfoBlock() {
    if (_selectedStore == null) return const SizedBox.shrink();

    final store = _selectedStore!;
    return GestureDetector(
      onTap: () => _navigateToMenuPage(store),
      child: Container(
        height: 130,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: AppColors.shadowBlack20, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(store.name, style: AppTextStyles.title20SemiBold),
                      const SizedBox(width: 8),
                      Text(store.foodCategory, style: AppTextStyles.body16Regular.copyWith(color: AppColors.categoryGrey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.heartRed, size: 20),
                      const SizedBox(width: 4),
                      Text('${store.likeSum}', style: AppTextStyles.body16Regular),
                      if (store.distance != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, color: AppColors.categoryGrey, size: 20),
                        const SizedBox(width: 4),
                        Text('${(store.distance! / 1000).toStringAsFixed(1)}km', style: AppTextStyles.body16Regular),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                store.displayedImg,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(width: 88, height: 88, color: AppColors.unclickGrey);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}