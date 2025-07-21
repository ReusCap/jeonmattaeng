// lib/pages/random_recommend_page.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/services/store_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

// ✨ 화면의 상태를 명확하게 관리하기 위한 Enum 정의
enum RecommendState {
  initial, // 초기 상태
  loading, // 로딩 및 셔플 중
  revealed, // 결과가 공개된 상태
}

class RandomRecommendPage extends StatefulWidget {
  const RandomRecommendPage({super.key});

  @override
  State<RandomRecommendPage> createState() => _RandomRecommendPageState();
}

class _RandomRecommendPageState extends State<RandomRecommendPage> {
  String _selectedLocation = '후문';
  Store? _recommendedStore;
  String? _errorMessage;

  // ✨ 여러 bool 변수 대신 하나의 상태(State) 변수로 관리
  RecommendState _state = RecommendState.initial;

  late PageController _pageController;
  Timer? _animationTimer;
  final List<String> _placeholderCategories = ['한식', '일식', '중식', '양식', '기타'];
  final int _pageCount = 100;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRandomStore() async {
    // 1단계: 상태를 로딩 중으로 변경하고 애니메이션 시작
    setState(() {
      _state = RecommendState.loading;
      _errorMessage = null;
      _recommendedStore = null;
    });

    // 고속 셔플 애니메이션 시작
    _animationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_pageController.hasClients) return;
      final randomPage = Random().nextInt(_pageCount);
      _pageController.animateToPage(
        randomPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    try {
      // API로부터 추천 가게 정보 요청
      final store = await StoreService.getRecommendedStore(_selectedLocation);
      if (store == null) {
        throw Exception('해당 위치에 추천할 가게를 찾지 못했습니다.');
      }

      // 셔플 애니메이션이 지속되는 총 시간
      await Future.delayed(const Duration(milliseconds: 1500));
      _animationTimer?.cancel(); // 고속 셔플 타이머 중지

      // 2단계: 결과 카테고리에 맞춰 중앙으로 감속하며 멈추기
      final resultCategory = store.foodCategory;
      final categoryIndex = _placeholderCategories.indexOf(resultCategory);
      final currentPage = _pageController.page?.round() ?? 0;

      int targetPage = (currentPage ~/ 5) * 5 + categoryIndex;
      if (targetPage <= currentPage) {
        targetPage += 5;
      }

      // 최종 결과 카드로 부드럽게 이동
      if (_pageController.hasClients) {
        await _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.decelerate,
        );
      }

      // 결과 공개 전 잠시 멈춤
      await Future.delayed(const Duration(milliseconds: 600));

      // 📸 결과를 보여주기 전에 이미지를 미리 불러옵니다.
      const String defaultImgUrl = "https://jmt-bucket-01.s3.ap-northeast-2.amazonaws.com/%EA%B0%80%EA%B2%8C%EA%B8%B0%EB%B3%B8%EC%9D%B4%EB%AF%B8%EC%A7%80/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA+2025-07-04+%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE+9.55.05.png";
      // [수정] 고유 이미지를 가졌을 경우에만 미리 불러오기 실행
      if (store.displayedImg.isNotEmpty && store.displayedImg != defaultImgUrl && mounted) {
        await precacheImage(NetworkImage(store.displayedImg), context);
      }

      // 3단계: 결과 공개! (UI가 바뀌고 버튼이 나타남)
      setState(() {
        _recommendedStore = store;
        _state = RecommendState.revealed;
      });

    } catch (e) {
      _animationTimer?.cancel(); // 에러 발생 시 타이머 중지
      setState(() {
        _errorMessage = '오류가 발생했어요.\n네트워크 상태를 확인 후 다시 시도해 주세요.';
        _state = RecommendState.initial; // 에러 시 초기 상태로
      });
    }
  }

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

  String _getFoodCategoryImagePath(String? category) {
    switch (category) {
      case '한식': return 'assets/image/한식.png';
      case '중식': return 'assets/image/중식.png';
      case '일식': return 'assets/image/일식.png';
      case '양식': return 'assets/image/양식.png';
      case '기타': return 'assets/image/기타.png';
      default: return 'assets/image/한식.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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

  Widget _buildLocationSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['후문', '상대', '정문'].map((location) {
        bool isSelected = _selectedLocation == location;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {
              // 로딩 중 아닐 때만 위치 변경 가능
              if (_state != RecommendState.loading) {
                setState(() {
                  _selectedLocation = location;
                  _state = RecommendState.initial;
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

  // ✨ 화면 전환 로직을 상태에 따라 단순하게 변경
  Widget _buildResultView() {
    if (_state == RecommendState.initial) {
      if (_errorMessage != null) {
        return Text(_errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.body16Regular.copyWith(color: AppColors.black));
      }
      return _buildInitialCard();
    } else {
      // 로딩 중이거나 결과가 나왔을 때 항상 PageView를 보여줌
      return _buildShufflingAnimation();
    }
  }

  Widget _buildPlaceholderCard(String category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow(color: AppColors.shadowBlack20, blurRadius: 15, offset: const Offset(0, 5)) ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_getFoodCategoryImagePath(category), width: 180, height: 180),
          const SizedBox(height: 20),
          Text(category, style: AppTextStyles.title24Bold.copyWith(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildShufflingAnimation() {
    return SizedBox(
      height: 390,
      child: PageView.builder(
        controller: _pageController,
        // ✨ 결과가 나온 후에는 사용자가 직접 스크롤 가능하도록 변경
        physics: _state == RecommendState.revealed
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: _pageCount,
        itemBuilder: (context, index) {
          // ✨ 현재 페이지와 추천된 가게 정보를 비교하여 어떤 카드를 보여줄지 결정
          final currentPage = _pageController.page?.round() ?? 0;
          if (_state == RecommendState.revealed && index == currentPage && _recommendedStore != null) {
            return _buildResultCard(_recommendedStore!);
          } else {
            final category = _placeholderCategories[index % _placeholderCategories.length];
            return _buildPlaceholderCard(category);
          }
        },
      ),
    );
  }

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
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowBlack20, blurRadius: 15, offset: const Offset(0, 5))]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(100)),
                child: const Icon(Icons.question_mark, size: 100, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 24),
              const Text('랜덤 메뉴 추천', style: AppTextStyles.title24Bold)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(Store store) {
    // 기본 이미지 URL 정의
    const String defaultImgUrl = "https://jmt-bucket-01.s3.ap-northeast-2.amazonaws.com/%EA%B0%80%EA%B2%8C%EA%B8%B0%EB%B3%B8%EC%9D%B4%EB%AF%B8%EC%A7%80/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA+2025-07-04+%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE+9.55.05.png";
    final String categoryImagePath = _getFoodCategoryImagePath(store.foodCategory);

    final cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          // [수정] 기본 이미지인지 아닌지에 따라 다른 위젯을 보여줌
          child: store.displayedImg == defaultImgUrl
          // 1. 기본 이미지일 경우: 카테고리 아이콘 표시
              ? Image.asset(categoryImagePath, width: 150, height: 150, fit: BoxFit.cover)
          // 2. 고유 이미지일 경우: 기존처럼 네트워크 이미지 표시
              : Image.network(store.displayedImg, width: 150, height: 150, fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              // 로딩 중에는 카테고리 아이콘을 보여줘서 깜빡임 최소화
              return Image.asset(categoryImagePath, width: 150, height: 150, fit: BoxFit.cover);
            },
            errorBuilder: (context, error, stackTrace) {
              // 에러 발생 시에도 카테고리 아이콘 표시
              return Image.asset(categoryImagePath, width: 150, height: 150, fit: BoxFit.cover);
            },
          ),
        ),
        Column(
          children: [
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
            if (store.popularMenu != null && store.popularMenu!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '인기 1위',
                        style: AppTextStyles.button14Bold.copyWith(color: AppColors.primaryGreen, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        store.popularMenu!,
                        style: AppTextStyles.body16Bold,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowBlack20, blurRadius: 15, offset: const Offset(0, 5))]),
      child: cardContent,
    );
  }

  // ✨ 버튼도 상태에 따라 다르게 보여줌
  Widget _buildActionButtons() {
    if (_state == RecommendState.revealed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _fetchRandomStore(),
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
        onPressed: _state == RecommendState.loading ? null : _fetchRandomStore,
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