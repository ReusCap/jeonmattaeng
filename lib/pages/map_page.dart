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

  // --- 아이콘 및 스트림 변수 ---
  BitmapDescriptor _unselectedDotIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _selectedDotIcon = BitmapDescriptor.defaultMarker;
  StreamSubscription<Position>? _positionStreamSubscription; // [추가] 위치 스트림 구독을 관리할 변수

  // --- 상수 ---
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.1754, 126.9059), // 전남대학교 좌표
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  // [개선] 페이지가 사라질 때 위치 스트림 구독을 반드시 취소하여 메모리 누수를 방지합니다.
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // [수정] 초기화 시 첫 위치를 가져온 후, 실시간 위치 감지를 시작합니다.
  Future<void> _initializeMap() async {
    await _loadMarkerIcons();
    await _startListeningLocation();
  }

  // [추가] 실시간 위치 감지를 시작하는 함수
  Future<void> _startListeningLocation() async {
    // 1. 먼저 현재 위치를 한 번 가져와서 지도에 표시합니다. (로딩 인디케이터 표시)
    await _goToMyLocation();

    // 2. 위치 변경 감지를 시작합니다.
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // [핵심] 50미터 이상 움직일 때만 이벤트를 발생시켜 효율을 높입니다.
    );

    // 3. 위치 스트림을 구독합니다.
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      debugPrint('위치 변경 감지: ${position.latitude}, ${position.longitude}');
      // [핵심] 위치가 변경될 때마다 '조용한' 업데이트 함수를 호출합니다.
      _updateDistancesSilently(position);
    });
  }

  // [추가] 로딩 인디케이터 없이 데이터를 '조용히' 갱신하는 함수
  Future<void> _updateDistancesSilently(Position newPosition) async {
    try {
      // 새 위치를 기준으로 가게 목록과 거리를 다시 가져옵니다.
      final stores = await StoreService.fetchStores(lat: newPosition.latitude, lng: newPosition.longitude);
      if (!mounted) return;

      setState(() {
        // isLoading 상태를 변경하지 않아 화면 깜빡임이 없습니다.
        _allStores = stores;
        _currentPosition = newPosition; // 현재 위치 정보도 갱신

        // 현재 선택된 가게가 있다면, 새 정보(거리 등)로 업데이트합니다.
        if (_selectedStore != null) {
          _selectedStore = stores.firstWhereOrNull((s) => s.id == _selectedStore!.id);
        }
        // 마커를 새로 생성하여 UI를 업데이트합니다.
        _markers = _generateMarkers(stores, _selectedStore);
      });
    } catch (e) {
      // 조용한 업데이트이므로, 실패 시 사용자에게 알리지 않고 로그만 남길 수 있습니다.
      debugPrint('❌ 조용한 가게 목록 업데이트 실패: $e');
    }
  }

  // --- 이하 기존 코드 (큰 변경 없음) ---

  Future<void> _loadMarkerIcons() async {
    final Uint8List unselectedBytes = await _createDotMarker(45, AppColors.primaryGreen);
    final Uint8List selectedBytes = await _createDotMarker(50, AppColors.heartRed);

    if (mounted) {
      setState(() {
        _unselectedDotIcon = BitmapDescriptor.fromBytes(unselectedBytes);
        _selectedDotIcon = BitmapDescriptor.fromBytes(selectedBytes);
      });
    }
  }

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

  // 이 함수는 이제 '내 위치' 버튼을 누르거나, 초기 로딩 시에만 사용됩니다.
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
      });
    } catch (e) {
      debugPrint('❌ 지도 가게 목록 로딩 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주변 가게 목록을 불러오는 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      final position = await LocationService.getCurrentLocation();
      if (!mounted) return;

      setState(() => _currentPosition = position);

      _moveCameraTo(LatLng(position.latitude, position.longitude));
      await _fetchStores(lat: position.latitude, lng: position.longitude);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      await _fetchStores(lat: _initialPosition.target.latitude, lng: _initialPosition.target.longitude);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 가져올 수 없습니다. 기본 위치로 검색합니다.')),
        );
      }
    }
  }

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

  void _onMarkerTapped(Store store) {
    setState(() {
      _selectedStore = store;
      _markers = _generateMarkers(_allStores, store);
    });
    _moveCameraTo(LatLng(store.lat, store.lng));
  }

  void _onMapTapped() {
    if (_selectedStore != null) {
      setState(() {
        _selectedStore = null;
        _markers = _generateMarkers(_allStores, null);
      });
    }
  }

  Future<void> _moveCameraTo(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    final double currentZoom = await controller.getZoomLevel();
    double newZoom = (currentZoom < 16.2) ? 16.2 : currentZoom;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: newZoom),
    ));
  }

  void _navigateToMenuPage(Store store) async {
    final bool? didStateChange = await Navigator.push<bool>(
      context,
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

    if (didStateChange == true && _currentPosition != null && mounted) {
      await _fetchStores(lat: _currentPosition!.latitude, lng: _currentPosition!.longitude);
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
            padding: const EdgeInsets.only(bottom: 1),
          ),
          if (_isLoading)
            Container(
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
                      Flexible(child: Text(store.name, style: AppTextStyles.title20SemiBold, overflow: TextOverflow.ellipsis)),
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
                      const SizedBox(width: 12),
                      if (store.distance != null) ...[
                        const Icon(Icons.location_on, color: AppColors.categoryGrey, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          store.distance! < 1000
                              ? '${store.distance!.toStringAsFixed(0)}m'
                              : '${(store.distance! / 1000).toStringAsFixed(1)}km',
                          style: AppTextStyles.body16Regular,
                        ),
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