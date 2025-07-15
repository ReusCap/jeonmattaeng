import 'dart:async';
import 'package:collection/collection.dart'; // ✅ 1. collection 패키지 임포트
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/services/store_service.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

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

  // --- 상수 ---
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.1768, 126.9061),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  /// 1. 서버로부터 가게 데이터를 가져와 상태를 업데이트하는 함수
  Future<void> _fetchStores() async {
    if (!_isLoading) setState(() => _isLoading = true);

    try {
      final stores = await StoreService.fetchStores();
      if (!mounted) return;

      setState(() {
        _allStores = stores;

        // ✅ 2. 타입 에러 해결: firstWhereOrNull을 사용하여 코드를 간결하고 안전하게 만듭니다.
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
        const SnackBar(content: Text('가게 목록을 불러오는 중 오류가 발생했습니다.')),
      );
    }
  }

  /// 2. 가게 목록과 선택된 가게를 기반으로 마커 Set을 생성하는 함수
  Set<Marker> _generateMarkers(List<Store> stores, Store? selectedStore) {
    return stores.map((store) {
      final isSelected = selectedStore != null && store.id == selectedStore.id;
      return Marker(
        markerId: MarkerId(store.id),
        position: LatLng(store.lat, store.lng),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onTap: () => _onMarkerTapped(store), // ✅ 3. 로직을 별도 함수로 분리하여 가독성 향상
      );
    }).toSet();
  }

  /// 3. 마커를 탭했을 때 호출되는 함수 (로직 분리 및 카메라 이동 추가)
  void _onMarkerTapped(Store store) {
    setState(() {
      _selectedStore = store;
      _markers = _generateMarkers(_allStores, store);
    });
    _moveCameraTo(LatLng(store.lat, store.lng));
  }

  /// 4. 지도의 빈 공간을 탭했을 때 호출되는 함수 (로직 분리)
  void _onMapTapped() {
    setState(() {
      _selectedStore = null;
      _markers = _generateMarkers(_allStores, null);
    });
  }

  /// 5. 특정 좌표로 카메라를 부드럽게 이동시키는 함수 (사용자 경험 향상)
  Future<void> _moveCameraTo(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16.0),
    ));
  }

  /// 6. 하단 정보 블록을 탭했을 때 메뉴 페이지로 이동하는 함수
  void _navigateToMenuPage(Store store) async {
    final bool? didLikeChange = await Navigator.push<bool>(
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

    if (didLikeChange == true && mounted) {
      _fetchStores();
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            markers: _markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            onTap: (_) => _onMapTapped(),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
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
    if (_selectedStore == null) {
      return const SizedBox.shrink();
    }

    final store = _selectedStore!;
    return GestureDetector(
      onTap: () => _navigateToMenuPage(store),
      child: Container(
        height: 130,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlack20,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
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