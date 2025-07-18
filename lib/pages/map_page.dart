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

  bool _isLoading = true;
  List<Store> _allStores = [];
  Set<Marker> _markers = {};
  Store? _selectedStore;
  Position? _currentPosition;

  BitmapDescriptor _unselectedDotIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _selectedDotIcon = BitmapDescriptor.defaultMarker;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.1754, 126.9059), // 전남대학교 좌표로 수정
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _loadMarkerIcons();
    await _goToMyLocation();
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주변 가게 목록을 불러오는 중 오류가 발생했습니다.')),
        );
      }
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
      if (!mounted) return;
      setState(() => _isLoading = false);
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
    // [개선] MenuPage에서 bool? 값을 반환받아 데이터 변경 여부를 확인합니다.
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

    // [개선] 데이터가 변경되었을 경우(true)에만 목록을 새로고침합니다.
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
            padding: const EdgeInsets.only(bottom: 1), // 하단 Google 로고가 가려지지 않게 패딩 추가
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
                        // [개선] 1000m 미만은 m, 그 이상은 km 단위로 표시
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