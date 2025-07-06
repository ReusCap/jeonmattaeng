import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/services/store_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class RandomRecommendPage extends StatefulWidget {
  const RandomRecommendPage({super.key});

  @override
  State<RandomRecommendPage> createState() => _RandomRecommendPageState();
}

class _RandomRecommendPageState extends State<RandomRecommendPage> {
  String _selectedLocation = '후문';
  Store? _recommendedStore;
  bool _isLoading = false;
  String? _errorMessage;

  // 서버에서 랜덤 가게 정보를 가져오는 함수
  Future<void> _fetchRandomStore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // 추천을 시작하면 이전 가게 정보는 초기화
      // _recommendedStore = null;
    });

    try {
      final store = await StoreService.getRecommendedStore(_selectedLocation);
      // [수정] 서버에서 데이터를 제대로 받아왔는지 확인
      if (store == null) {
        throw Exception('해당 위치에 추천할 가게를 찾지 못했습니다.');
      }
      setState(() {
        _recommendedStore = store;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '추천 가게를 불러오는데 실패했어요. 😢\n다시 시도해주세요.';
        _isLoading = false;
        _recommendedStore = null; // 에러 발생 시 초기 상태로
      });
    }
  }

  // 가게 메뉴 목록 페이지로 이동하는 함수
  void _navigateToMenuPage(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPage(
          storeId: store.id,
          storeName: store.name,
          storeCategory: store.foodCategory,
          storeImage: store.displayedImg ?? '',
          storeLikeCount: store.likeSum,
          storeLocation: store.location,
          storeLocationCategory: store.locationCategory,
        ),
      ),
    );
  }

  // 카테고리에 맞는 로컬 이미지 경로를 반환하는 함수
  String _getFoodCategoryImagePath(String? category) {
    switch (category) {
      case '한식': return 'assets/image/한식.png';
      case '양식': return 'assets/image/양식.png';
      case '일식': return 'assets/image/일식.png';
      case '패스트푸드': return 'assets/image/패스트푸드.png';
      case '중식': return 'assets/image/중식.png';
      default: return 'assets/image/한식.png'; // 기본 이미지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppColors.transparent 대신 Colors.transparent 사용
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            _buildLocationSelector(),
            const Spacer(flex: 2),
            _buildResultView(),
            const Spacer(flex: 3),
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 위치 선택 UI
  Widget _buildLocationSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['후문', '상대', '정문'].map((location) {
        bool isSelected = _selectedLocation == location;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {
              if (!_isLoading) {
                setState(() {
                  _selectedLocation = location;
                  // 위치 변경 시, 추천 결과 초기화
                  _recommendedStore = null;
                  _errorMessage = null;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? AppColors.white : AppColors.unclickGrey,
              foregroundColor: isSelected ? AppColors.primaryGreen : AppColors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: isSelected ? 4 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: Text(location, style: AppTextStyles.body16Bold),
          ),
        );
      }).toList(),
    );
  }

  // 로딩, 에러, 결과, 초기 상태에 따라 다른 위젯을 보여주는 부분
  Widget _buildResultView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.heartRed));
    }
    if (_errorMessage != null) {
      return Text(_errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.body16Regular.copyWith(color: AppColors.black));
    }
    if (_recommendedStore != null) {
      return _buildResultCard(_recommendedStore!);
    } else {
      return _buildInitialCard(); // 추천 전 초기 카드
    }
  }

  // 추천받기 전 보여줄 초기 카드 UI
  Widget _buildInitialCard() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: -0.08,
          child: Container(width: 280, height: 380, decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(20))),
        ),
        Container(
          width: 290,
          height: 390,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowBlack20, blurRadius: 15, offset: const Offset(0, 5))]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(color: AppColors.lightTeal, borderRadius: BorderRadius.circular(100)),
                child: const Icon(Icons.question_mark, size: 80, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 24),
              const Text('랜덤 메뉴 추천', style: AppTextStyles.title24Bold)
            ],
          ),
        ),
      ],
    );
  }

  // 추천 결과 카드 UI
  Widget _buildResultCard(Store store) {
    // [수정] 메뉴 데이터가 ID 값이므로, "인기 대표 메뉴"와 같은 고정 텍스트로 대체
    const String menuDisplayName = '인기 대표 메뉴';
    final String categoryImagePath = _getFoodCategoryImagePath(store.foodCategory);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: -0.08,
          child: Container(width: 280, height: 380, decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(20))),
        ),
        Container(
          width: 290,
          height: 390,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowBlack20, blurRadius: 15, offset: const Offset(0, 5))]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(categoryImagePath, width: 150, height: 150, fit: BoxFit.cover),
              ),
              Column(
                children: [
                  // [수정] 카테고리 이름이 있을 때만 표시
                  if (store.foodCategory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                        child: Text(store.foodCategory, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white)),
                      ),
                    ),
                  Text(store.name, style: AppTextStyles.title24Bold, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.unclickGrey, width: 1)),
                    child: Text(menuDisplayName, style: AppTextStyles.button11Bold.copyWith(color: AppColors.heartRed)),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  // 상태에 따라 다른 버튼들을 보여주는 부분
  Widget _buildActionButtons() {
    if (_recommendedStore != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _fetchRandomStore,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
              fixedSize: const Size(150, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              side: const BorderSide(color: AppColors.grey),
            ),
            child: const Text('다시 뽑기', style: AppTextStyles.body16Bold),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _navigateToMenuPage(_recommendedStore!),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              fixedSize: const Size(150, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('가게 보기', style: AppTextStyles.body16Bold),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: _isLoading ? null : _fetchRandomStore,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text('랜덤 메뉴 추천', style: AppTextStyles.body16Bold),
      );
    }
  }
}