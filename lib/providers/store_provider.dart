import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/location_service.dart';
import 'package:jeonmattaeng/services/store_service.dart';

enum SortOption { distance, likes }

class StoreProvider with ChangeNotifier {
  List<Store> _allStores = [];
  String _selectedLocation = '후문';
  String? _selectedFoodCategory;
  String _searchQuery = '';
  bool _isGridView = true;
  bool _isLoading = false;
  SortOption _sortOption = SortOption.distance;

  // ✅ 외부에서 전체 가게 목록에 접근할 수 있도록 getter 추가
  List<Store> get allStores => _allStores;

  String get selectedLocation => _selectedLocation;
  String? get selectedFoodCategory => _selectedFoodCategory;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;
  SortOption get sortOption => _sortOption;

  List<Store> get filteredStores {
    List<Store> tempStores = _allStores;

    // 위치 필터링
    if (_selectedLocation != '전체') {
      tempStores = tempStores.where((store) => store.locationCategory == _selectedLocation).toList();
    }
    // 음식 카테고리 필터링
    if (_selectedFoodCategory != null && _selectedFoodCategory != '전체') {
      tempStores = tempStores.where((store) => store.foodCategory == _selectedFoodCategory).toList();
    }
    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      tempStores = tempStores.where((store) {
        return store.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 정렬 로직
    tempStores.sort((a, b) {
      switch (_sortOption) {
        case SortOption.likes:
          return b.likeSum.compareTo(a.likeSum);
        case SortOption.distance:
        default:
          if (a.distance == null && b.distance == null) return 0;
          if (a.distance == null) return 1;
          if (b.distance == null) return -1;
          return a.distance!.compareTo(b.distance!);
      }
    });

    return tempStores;
  }

  Future<void> fetchStores() async {
    _isLoading = true;
    notifyListeners();
    try {
      final position = await LocationService.getCurrentLocation();
      _allStores = await StoreService.fetchStores(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      debugPrint('위치 기반 가게 목록 로딩 실패 (기본 목록으로 재시도): $e');
      try {
        _allStores = await StoreService.fetchStores();
      } catch (e2) {
        debugPrint('기본 가게 목록 로딩도 실패: $e2');
        _allStores = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeSortOption(SortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      notifyListeners();
    }
  }

  void selectLocation(String location) {
    _selectedLocation = location;
    // ✅ 위치 변경 시, 음식 카테고리와 검색어는 초기화
    _selectedFoodCategory = '전체';
    _searchQuery = '';
    notifyListeners();
  }

  void selectFoodCategory(String category) {
    // ✅ '전체'를 선택하면 null로 만들어 모든 카테고리를 보여주도록 수정
    if (category == '전체') {
      _selectedFoodCategory = null;
    } else {
      _selectedFoodCategory = (category == _selectedFoodCategory) ? null : category;
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }
}
