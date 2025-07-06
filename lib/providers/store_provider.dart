// lib/providers/store_provider.dart

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/store_service.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _allStores = [];

  String _selectedLocation = '후문';
  String? _selectedFoodCategory;
  String _searchQuery = '';
  bool _isGridView = true;
  bool _isLoading = false;

  String get selectedLocation => _selectedLocation;
  String? get selectedFoodCategory => _selectedFoodCategory;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  List<Store> get filteredStores {
    List<Store> tempStores = _allStores;

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

    return tempStores;
  }

  // ✨ 생성자에서 fetchStores() 호출을 제거하여 자동 로딩을 방지합니다.
  StoreProvider();

  Future<void> fetchStores() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allStores = await StoreService.fetchStores();
    } catch (e) {
      print('가게 목록 불러오기 실패: $e');
      _allStores = []; // 실패 시 빈 리스트로 초기화
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectLocation(String location) {
    _selectedLocation = location;
    _selectedFoodCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  void selectFoodCategory(String category) {
    if (_selectedFoodCategory == category) {
      _selectedFoodCategory = null;
    } else {
      _selectedFoodCategory = category;
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