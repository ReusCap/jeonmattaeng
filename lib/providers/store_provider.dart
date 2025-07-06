// lib/providers/store_provider.dart

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/store_service.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _allStores = []; // 서버에서 받아온 원본 가게 목록
  List<Store> _filteredStores = []; // 필터링된 가게 목록 (실제 화면에 표시됨)

  String _selectedLocation = '전대후문'; // 현재 선택된 위치 필터
  String? _selectedFoodCategory; // 현재 선택된 음식 필터
  bool _isGridView = true; // 보기 모드 (true: 그리드, false: 리스트)
  bool _isLoading = false;

  // 외부에서 접근할 getter들
  List<Store> get filteredStores => _filteredStores;
  String get selectedLocation => _selectedLocation;
  String? get selectedFoodCategory => _selectedFoodCategory;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  StoreProvider() {
    fetchStores(); // Provider 생성 시 가게 목록 불러오기
  }

  // 서버에서 가게 목록 불러오기
  Future<void> fetchStores() async {
    _isLoading = true;
    notifyListeners(); // 로딩 시작을 UI에 알림

    try {
      _allStores = await StoreService.fetchStores();
      _applyFilters(); // 필터 적용
    } catch (e) {
      print('가게 목록 불러오기 실패: $e');
    }

    _isLoading = false;
    notifyListeners(); // 로딩 끝났음을 UI에 알림
  }

  // 위치 필터 변경
  void selectLocation(String location) {
    _selectedLocation = location;
    _selectedFoodCategory = null; // 위치가 바뀌면 음식 필터는 초기화
    _applyFilters();
  }

  // 음식 필터 변경
  void selectFoodCategory(String category) {
    // 이미 선택된 카테고리를 다시 누르면 필터 해제
    if (_selectedFoodCategory == category) {
      _selectedFoodCategory = null;
    } else {
      _selectedFoodCategory = category;
    }
    _applyFilters();
  }

  // 보기 모드 변경
  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners(); // UI에 변경사항 알림
  }

  // 현재 필터에 맞게 가게 목록을 업데이트하는 내부 함수
  void _applyFilters() {
    List<Store> tempStores = _allStores;

    // 1. 위치 필터링
    tempStores = tempStores.where((store) => store.locationCategory == _selectedLocation).toList();

    // 2. 음식 카테고리 필터링
    if (_selectedFoodCategory != null) {
      tempStores = tempStores.where((store) => store.foodCategory == _selectedFoodCategory).toList();
    }

    _filteredStores = tempStores;
    notifyListeners(); // 최종 필터링된 목록을 UI에 알림
  }
}