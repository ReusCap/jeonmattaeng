import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/location_service.dart';
import 'package:jeonmattaeng/services/store_service.dart';

// [추가] 정렬 옵션을 관리하기 위한 Enum
enum SortOption { distance, likes }

class StoreProvider with ChangeNotifier {
  List<Store> _allStores = [];

  String _selectedLocation = '후문';
  String? _selectedFoodCategory;
  String _searchQuery = '';
  bool _isGridView = true;
  bool _isLoading = false;
  SortOption _sortOption = SortOption.distance; // [추가] 정렬 상태, 기본값 '거리순'

  String get selectedLocation => _selectedLocation;
  String? get selectedFoodCategory => _selectedFoodCategory;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;
  SortOption get sortOption => _sortOption; // [추가] 정렬 상태 getter

  List<Store> get filteredStores {
    List<Store> tempStores = _allStores;

    // --- 필터링 로직 ---
    if (_selectedLocation != '전체') {
      tempStores = tempStores.where((store) => store.locationCategory == _selectedLocation).toList();
    }
    if (_selectedFoodCategory != null) {
      tempStores = tempStores.where((store) => store.foodCategory == _selectedFoodCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      tempStores = tempStores.where((store) {
        return store.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // --- [개선] 정렬 로직 ---
    tempStores.sort((a, b) {
      switch (_sortOption) {
        case SortOption.likes:
        // '좋아요'가 많은 순 (내림차순)
          return b.likeSum.compareTo(a.likeSum);
        case SortOption.distance:
        default:
        // '거리'가 가까운 순 (오름차순), null은 맨 뒤로
          if (a.distance == null && b.distance == null) return 0;
          if (a.distance == null) return 1;
          if (b.distance == null) return -1;
          return a.distance!.compareTo(b.distance!);
      }
    });

    return tempStores;
  }

  StoreProvider();

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
      print('위치 기반 가게 목록 로딩 실패 (기본 목록으로 재시도): $e');
      try {
        _allStores = await StoreService.fetchStores();
      } catch (e2) {
        print('기본 가게 목록 로딩도 실패: $e2');
        _allStores = [];
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  // [추가] 정렬 옵션을 변경하는 메서드
  void changeSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void selectLocation(String location) {
    _selectedLocation = location;
    _selectedFoodCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  void selectFoodCategory(String category) {
    _selectedFoodCategory = (category == _selectedFoodCategory) ? null : category;
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