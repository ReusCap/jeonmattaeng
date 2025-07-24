import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/providers/store_provider.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

// ✅ [수정] StatelessWidget에서 StatefulWidget으로 변경
class StoreListPage extends StatefulWidget {
  final String selectedLocation;
  final String? initialSearchQuery;

  const StoreListPage({
    super.key,
    required this.selectedLocation,
    this.initialSearchQuery,
  });

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  @override
  void initState() {
    super.initState();
    // ✅ [수정] 위젯이 빌드된 직후, Provider의 상태를 초기화합니다.
    // HomePage에서 전달받은 위치, 검색어로 필터링을 설정합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StoreProvider>();
      provider.selectLocation(widget.selectedLocation);
      provider.updateSearchQuery(widget.initialSearchQuery ?? '');
      // ✅ await 없이 중복 방지
      if (provider.allStores.isEmpty) {
        provider.fetchStores();
      }
    });
  }

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

    // ✅ [수정] 비동기 작업 후 위젯이 여전히 마운트 상태인지 확인합니다.
    if (didLikeChange == true && mounted) {
      // 좋아요 상태가 변경되면 데이터를 다시 불러옵니다.
      provider.fetchStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ [수정] context.watch를 통해 상위 위젯(MainTabPageWrapper)의 StoreProvider를 구독합니다.
    final provider = context.watch<StoreProvider>();

    // ✅ [수정] 로딩 조건: 데이터가 비어있을 때만 로딩 인디케이터를 보여줍니다.
    // 이렇게 하면 필터링 시 깜빡임이 사라집니다.
    if (provider.isLoading && provider.allStores.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }

    return Column(
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

  // ... 이하 UI 빌드 메서드들은 모두 이 State 클래스 안으로 이동했습니다 ...

  Widget _buildFoodCategoryFilters(BuildContext context, StoreProvider provider) {
    final categories = ['전체', '한식', '중식', '일식', '양식', '기타'];
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, StoreProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('가게 리스트', style: AppTextStyles.subtitle18SemiBold),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(provider.isGridView ? Icons.list : Icons.grid_view),
                onPressed: provider.toggleViewMode,
                color: AppColors.grey,
              ),
            ],
          ),
          PopupMenuButton<SortOption>(
            onSelected: provider.changeSortOption,
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
        childAspectRatio: 0.85,
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
                placeholder: (context, url) => Container(color: AppColors.unclickGrey),
                errorWidget: (context, url, error) => const Icon(Icons.restaurant_menu, color: AppColors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                          child: Text(store.name, style: AppTextStyles.body16Bold, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      Text(store.foodCategory, style: AppTextStyles.caption14Medium.copyWith(color: AppColors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.heartRed, size: 14),
                      const SizedBox(width: 2),
                      Text(store.likeSum.toString(), style: AppTextStyles.caption14Medium),
                      const Spacer(),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(child: Text(store.name, style: AppTextStyles.title20SemiBold)),
                        const SizedBox(width: 8),
                        Text(store.foodCategory, style: AppTextStyles.body16Regular.copyWith(color: AppColors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, color: AppColors.heartRed, size: 16),
                        const SizedBox(width: 4),
                        Text(store.likeSum.toString(), style: AppTextStyles.body16Regular),
                        const Spacer(),
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
                  placeholder: (context, url) => Container(color: AppColors.unclickGrey),
                  errorWidget: (context, url, error) => const Icon(Icons.restaurant_menu, color: AppColors.grey),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
