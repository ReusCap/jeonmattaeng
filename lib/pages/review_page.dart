// lib/pages/review_page.dart (최종 수정본)
import 'dart:developer'; // debugPrint를 위해 추가

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
  const ReviewPage({super.key, required this.menu});
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
    _loadUserIdAndFetchReviews();
  }
  Future<void> _loadUserIdAndFetchReviews() async {
    final jwt = await SecureStorage.getToken();
    if (!mounted) return;
    final userId = jwt != null ? JwtUtils.extractUserId(jwt) : null;
    setState(() {
      myUserId = userId;
    });
    _fetchReviews();
  }
  void _fetchReviews() {
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
      _fetchReviews();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 등록 실패')),
      );
    }
  }
  void _deleteReview(String reviewId) async {
    try {
      await ReviewService.deleteReview(reviewId);
      _fetchReviews();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리뷰 삭제 실패')),
      );
    }
  }

  // ✅ 좋아요 로직 수정
  void _toggleLike() async {
    final isLiked = _menu.liked;
    final originalMenu = _menu; // 되돌리기를 위해 원래 상태 저장

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
      // ✅ 디버깅 로그 추가
      debugPrint('❌ 좋아요 API 호출 실패: $e');
      setState(() {
        _menu = originalMenu; // 실패 시 원래 상태로 복구
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리 실패')),
      );
    }
  }
  Widget _buildReviewInputBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          const Icon(Icons.comment_outlined, color: AppColors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '메뉴가 어땠는지 후기를 남겨주세요.',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.darkgreen),
            onPressed: _submitReview,
          )
        ],
      ),
    );
  }
  Widget _buildCachedImage(String imageUrl, double width, double height) {
    const fallbackImageAsset = 'assets/image/이미지없음표시.png';
    if (imageUrl.isEmpty) {
      return Image.asset(fallbackImageAsset, width: width, height: height, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(color: AppColors.unclickgrey),
      errorWidget: (context, url, error) => Image.asset(fallbackImageAsset, fit: BoxFit.cover),
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
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Navigator.pop(context, _didLikeChange ? _menu : null),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.black45,
                      ),
                    ),
                    // ✅ UI 수정된 부분
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildCachedImage(_menu.image, double.infinity, MediaQuery.of(context).size.height / 5),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_menu.name, style: AppTextStyles.title24Bold.copyWith(color: AppColors.white)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _toggleLike,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _menu.liked ? Icons.favorite : Icons.favorite_border,
                                          color: _menu.liked ? AppColors.heartRed : AppColors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _menu.likeCount.toString(),
                                          style: AppTextStyles.body16Regular.copyWith(color: AppColors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const SliverToBoxAdapter(
                            child: Center(child: Text('리뷰를 불러올 수 없습니다.')));
                      }
                      final reviews = snapshot.data!;
                      if (reviews.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(50.0),
                              child: Text('아직 작성된 리뷰가 없습니다.'),
                            ),
                          ),
                        );
                      }
                      return SliverList.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          final isMyReview = myUserId != null && review.authorId == myUserId;
                          return ListTile(
                            onTap: () {
                              if (isMyReview) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => SafeArea(
                                    child: ListTile(
                                      leading: const Icon(Icons.delete, color: AppColors.heartRed),
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
                              backgroundImage: review.userProfileImage.isNotEmpty
                                  ? CachedNetworkImageProvider(review.userProfileImage)
                                  : null,
                              backgroundColor: AppColors.grey,
                              child: review.userProfileImage.isEmpty
                                  ? const Icon(Icons.person, color: AppColors.white)
                                  : null,
                            ),
                            title: Text(review.content),
                            subtitle: Text(review.userNickname),
                            trailing: Text(
                              '${review.createdAt.month.toString().padLeft(2, '0')}/${review.createdAt.day.toString().padLeft(2, '0')} ${review.createdAt.hour.toString().padLeft(2, '0')}:${review.createdAt.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.caption10Medium.copyWith(color: AppColors.grey),
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