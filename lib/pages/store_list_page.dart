import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/providers/store_provider.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class StoreListPage extends StatelessWidget {
  final String selectedLocation;
  final String? initialSearchQuery;

  const StoreListPage({
    super.key,
    required this.selectedLocation,
    this.initialSearchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreProvider()
        ..fetchStores()
        ..selectLocation(selectedLocation)
        ..updateSearchQuery(initialSearchQuery ?? ''),
      child: const _StoreListPageView(),
    );
  }
}

class _StoreListPageView extends StatelessWidget {
  const _StoreListPageView();

  void _navigateToMenuPage(BuildContext context, Store store) async {
    final provider = context.read<StoreProvider>();
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

    if (didLikeChange == true && context.mounted) {
      provider.fetchStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoreProvider>();

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : Column(
      children: [
        _buildFoodCategoryFilters(context, provider),
        _buildListHeader(context, provider),
        Expanded(
          child: provider.filteredStores.isEmpty
              ? const Center(child: Text('표시할 가게가 없습니다.'))
              : RefreshIndicator(
            onRefresh: provider.fetchStores,
            color: AppColors.primaryGreen,
            child: provider.isGridView
                ? _buildStoreGridView(context, provider)
                : _buildStoreListView(context, provider),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodCategoryFilters(BuildContext context, StoreProvider provider) {
    final categories = ['한식', '중식', '일식', '양식', '기타'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: categories.map((category) {
            final isSelected = provider.selectedFoodCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) => provider.selectFoodCategory(category),
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isSelected ? AppColors.primaryGreen : AppColors.unclickGrey),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // [개선] 정렬 기능을 PopupMenuButton으로 구현
  Widget _buildListHeader(BuildContext context, StoreProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('가게 리스트', style: AppTextStyles.subtitle18SemiBold),
              IconButton(
                icon: Icon(provider.isGridView ? Icons.list : Icons.grid_view),
                onPressed: provider.toggleViewMode,
              ),
            ],
          ),
          PopupMenuButton<SortOption>(
            onSelected: (SortOption option) => provider.changeSortOption(option),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.distance,
                child: Text('거리순'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.likes,
                child: Text('좋아요순'),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.unclickGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    provider.sortOption == SortOption.distance ? '거리순' : '좋아요순',
                    style: AppTextStyles.caption14Medium,
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreGridView(BuildContext context, StoreProvider provider) {
    final stores = provider.filteredStores;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75, // 비율 조정
      ),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreCard(context, store);
      },
    );
  }

  Widget _buildStoreListView(BuildContext context, StoreProvider provider) {
    final stores = provider.filteredStores;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreTile(context, store);
      },
    );
  }

  // [개선] 카드에 거리 표시 추가
  Widget _buildStoreCard(BuildContext context, Store store) {
    return GestureDetector(
      onTap: () => _navigateToMenuPage(context, store),
      child: Card(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: store.displayedImg,
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: AppTextStyles.body16Bold, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(store.foodCategory, style: AppTextStyles.caption14Medium.copyWith(color: AppColors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.heartRed, size: 14),
                      const SizedBox(width: 2),
                      Text(store.likeSum.toString()),
                      const Spacer(),
                      // [추가] 거리가 있을 경우 표시
                      if (store.distance != null)
                        Text(
                          store.distance! < 1000
                              ? '${store.distance!.toStringAsFixed(0)}m'
                              : '${(store.distance! / 1000).toStringAsFixed(1)}km',
                          style: AppTextStyles.caption14Medium.copyWith(color: AppColors.primaryGreen),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // [개선] 타일에 거리 표시 추가
  Widget _buildStoreTile(BuildContext context, Store store) {
    return GestureDetector(
      onTap: () => _navigateToMenuPage(context, store),
      child: Card(
        color: AppColors.white,
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: AppTextStyles.title20SemiBold),
                    const SizedBox(height: 4),
                    Text(store.foodCategory, style: AppTextStyles.body16Regular.copyWith(color: AppColors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, color: AppColors.heartRed, size: 16),
                        const SizedBox(width: 4),
                        Text(store.likeSum.toString(), style: AppTextStyles.body16Regular),
                        const Spacer(), // 남은 공간을 밀어냄
                        // [추가] 거리가 있을 경우 표시
                        if (store.distance != null)
                          Text(
                            store.distance! < 1000
                                ? '${store.distance!.toStringAsFixed(0)}m'
                                : '${(store.distance! / 1000).toStringAsFixed(1)}km',
                            style: AppTextStyles.body16Bold.copyWith(color: AppColors.primaryGreen),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: store.displayedImg,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}