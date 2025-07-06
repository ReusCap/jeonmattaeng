// lib/pages/review_page.dart (최종 통일본)

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/menu_model.dart';
import 'package:jeonmattaeng/models/review_model.dart';
import 'package:jeonmattaeng/services/menu_service.dart';
import 'package:jeonmattaeng/services/review_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:jeonmattaeng/utils/jwt_utils.dart';
import 'package:jeonmattaeng/utils/secure_storage.dart';

class ReviewPage extends StatefulWidget {
  final Menu menu;
  final String storeName;
  final int? rank; // ✅ 1. 순위 정보를 받기 위한 변수 추가 (nullable)

  const ReviewPage({
    super.key,
    required this.menu,
    required this.storeName,
    this.rank, // ✅ 2. 생성자에 순위 변수 추가
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Future<List<Review>> _reviewsFuture;
  final TextEditingController _controller = TextEditingController();
  late Menu _menu;
  String? myUserId;
  bool _didLikeChange = false;

  @override
  void initState() {
    super.initState();
    _menu = widget.menu;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final jwt = await SecureStorage.getToken();
    if (!mounted) return;

    final userId = jwt != null ? JwtUtils.extractUserId(jwt) : null;
    final reviewsFuture = ReviewService.getReviews(_menu.id);

    setState(() {
      myUserId = userId;
      _reviewsFuture = reviewsFuture;
    });
  }

  void _refreshReviews() {
    setState(() {
      _reviewsFuture = ReviewService.getReviews(_menu.id);
    });
  }

  void _submitReview() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    FocusScope.of(context).unfocus();
    try {
      await ReviewService.postReview(_menu.id, content);
      _controller.clear();
      _refreshReviews();
    } catch (e) {
      if (!mounted) return;
      debugPrint("리뷰 등록 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 등록 실패')),
      );
    }
  }

  void _deleteReview(String reviewId) async {
    try {
      await ReviewService.deleteReview(reviewId);
      _refreshReviews();
    } catch (e) {
      if (!mounted) return;
      debugPrint("리뷰 삭제 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 삭제 실패')),
      );
    }
  }

  void _toggleLike() async {
    final isLiked = _menu.liked;
    final originalMenu = _menu;

    final updatedMenu = _menu.copyWith(
      liked: !isLiked,
      likeCount: isLiked ? _menu.likeCount - 1 : _menu.likeCount + 1,
    );
    setState(() {
      _menu = updatedMenu;
      _didLikeChange = true;
    });
    try {
      isLiked
          ? await MenuService.unlikeMenu(_menu.id)
          : await MenuService.likeMenu(_menu.id);
    } catch (e) {
      debugPrint('❌ 좋아요 API 호출 실패: $e');
      setState(() {
        _menu = originalMenu;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리 실패')),
      );
    }
  }

  // 메뉴 정보 섹션 UI
  Widget _buildMenuInfoSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_menu.name, style: AppTextStyles.title24Bold),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _menu.liked
                          ? const Color(0xFFFFEBEE)
                          : AppColors.unclickGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite,
                            size: 16,
                            color: _menu.liked
                                ? AppColors.heartRed
                                : AppColors.grey),
                        const SizedBox(width: 4),
                        Text(_menu.likeCount.toString(),
                            style: TextStyle(
                                color: _menu.liked
                                    ? AppColors.heartRed
                                    : AppColors.grey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // ✅ 3. rank 정보가 있을 때만 인기 순위 태그를 표시
                if (widget.rank != null && widget.rank! > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightTeal,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('인기 ${widget.rank}위',
                          style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 리뷰 입력창 UI
  Widget _buildReviewInputBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: '메뉴가 어땠는지 후기를 남겨주세요.',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: AppColors.primaryGreen),
            onPressed: _submitReview,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 이미지 캐싱 위젯
  Widget _buildCachedImage(String imageUrl) {
    const fallbackImageAsset = 'assets/image/이미지없음표시.png';
    if (imageUrl.isEmpty) {
      return Image.asset(fallbackImageAsset, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: AppColors.unclickGrey),
      errorWidget: (context, url, error) =>
          Image.asset(fallbackImageAsset, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _didLikeChange ? _menu : null);
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height / 5,
                    pinned: true,
                    leading: IconButton(
                      icon:
                      const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () =>
                          Navigator.pop(context, _didLikeChange ? _menu : null),
                    ),
                    title: Text(widget.storeName,
                        style: AppTextStyles.subtitle18SemiBold
                            .copyWith(color: AppColors.white)),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildCachedImage(_menu.displayedImg),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black45, Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment(0.0, -0.2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildMenuInfoSection(),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(height: 1),
                    ),
                  ),
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              )),
                        );
                      }
                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                            child: Center(
                                child: Text(
                                    '리뷰를 불러올 수 없습니다.\n에러: ${snapshot.error}')));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(50.0),
                              child: Text('아직 작성된 리뷰가 없습니다.'),
                            ),
                          ),
                        );
                      }
                      final reviews = snapshot.data!;

                      return SliverList.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          final isMyReview =
                              myUserId != null && review.authorId == myUserId;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            onTap: () {
                              if (isMyReview) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => SafeArea(
                                    child: ListTile(
                                      leading: const Icon(Icons.delete,
                                          color: AppColors.heartRed),
                                      title: const Text('삭제하기'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _deleteReview(review.id);
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            leading: CircleAvatar(
                              backgroundImage:
                              review.userProfileImage.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                  review.userProfileImage)
                                  : null,
                              backgroundColor: AppColors.grey,
                              child: review.userProfileImage.isEmpty
                                  ? const Icon(Icons.person,
                                  color: AppColors.white)
                                  : null,
                            ),
                            title: Text(review.content),
                            subtitle: Text(review.userNickname),
                            trailing: Text(
                              '${review.createdAt.month.toString().padLeft(2, '0')}/${review.createdAt.day.toString().padLeft(2, '0')} ${review.createdAt.hour.toString().padLeft(2, '0')}:${review.createdAt.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.caption14Medium
                                  .copyWith(color: AppColors.grey),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildReviewInputBar(),
          ],
        ),
      ),
    );
  }
}