// store_list_page.dart (최적화 후)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/services/store_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class StoreListPage extends StatefulWidget {
  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  late Future<List<Store>> _storeFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadStores();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStores() {
    setState(() {
      _storeFuture = StoreService.fetchStores();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  // ✅ 최적화: 가독성을 위해 리스트 아이템을 별도 메서드로 분리
  Widget _buildStoreTile(Store store) {
    return InkWell(
      onTap: () async {
        final refreshNeeded = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => MenuPage(
              storeId: store.id,
              storeName: store.name,
              storeCategory: store.foodCategory,
              storeImage: store.image,
              storeLikeCount: store.likeSum,
              storeLocation: store.location,
              storeLocationCategory: store.locationCategory,
            ),
          ),
        );

        if (refreshNeeded == true && mounted) {
          _loadStores();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible( // 긴 텍스트가 다른 위젯을 밀어내지 않도록 Flexible 사용
                        child: Text(
                          store.name,
                          style: AppTextStyles.title20SemiBold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        store.foodCategory,
                        style: AppTextStyles.body16Regular.copyWith(
                          color: AppColors.categoryGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 16, color: AppColors.heartRed),
                      const SizedBox(width: 4),
                      Text(
                        store.likeSum.toString(),
                        style: AppTextStyles.caption10Medium.copyWith(
                          color: AppColors.heartRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // ✅ 최적화: 이미지 캐싱 적용
              child: CachedNetworkImage(
                imageUrl: store.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.unclickgrey),
                errorWidget: (context, url, error) => Container(
                  width: 60,
                  height: 60,
                  color: AppColors.unclickgrey,
                  child: const Icon(Icons.storefront, color: AppColors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0.5,
        centerTitle: true,
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: '가게 이름 검색...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: AppColors.categoryGrey)
          ),
          style: const TextStyle(fontSize: 16),
        )
            : Text(
          '전맛탱',
          style: AppTextStyles.title20SemiBold.copyWith(color: AppColors.heartRed),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: FutureBuilder<List<Store>>(
        future: _storeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('가게 목록을 불러올 수 없습니다.'));
          }

          // ✅ 최적화: snapshot.data를 직접 필터링
          final allStores = snapshot.data!;
          final filteredStores = _searchQuery.isEmpty
              ? allStores
              : allStores.where((store) => store.name.contains(_searchQuery)).toList();

          if (filteredStores.isEmpty) {
            return const Center(child: Text('검색 결과가 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: filteredStores.length + 1, // 헤더 포함
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('가게 리스트', style: AppTextStyles.subtitle18SemiBold),
                );
              }
              final store = filteredStores[index - 1];
              return _buildStoreTile(store);
            },
          );
        },
      ),
    );
  }
}