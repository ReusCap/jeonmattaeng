// lib/pages/store_list_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/providers/store_provider.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

// ✨ 1. Provider를 생성하고 제공하는 역할만 하는 StatelessWidget
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
      // ✨ 2. StoreListPage가 생성될 때 fetchStores를 호출하여 데이터 로딩 시작
        ..fetchStores()
        ..selectLocation(selectedLocation)
        ..updateSearchQuery(initialSearchQuery ?? ''),
      // ✨ 3. 실제 UI는 아래의 _StoreListPageView 위젯이 담당
      child: _StoreListPageView(initialSearchQuery: initialSearchQuery),
    );
  }
}

// ✨ 4. UI와 상태를 관리하는 별도의 StatefulWidget
class _StoreListPageView extends StatefulWidget {
  final String? initialSearchQuery;
  const _StoreListPageView({this.initialSearchQuery});

  @override
  State<_StoreListPageView> createState() => _StoreListPageViewState();
}

class _StoreListPageViewState extends State<_StoreListPageView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
      _isSearching = true;
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToMenuPage(BuildContext context, Store store) async {
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
      context.read<StoreProvider>().fetchStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✨ 5. Consumer를 통해 Provider의 데이터와 상태 변화를 감지
    final provider = context.watch<StoreProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _isSearching
          ? _buildSearchAppBar(context, provider)
          : _buildDefaultAppBar(context, provider),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildFoodCategoryFilters(context, provider),
          _buildListHeader(context, provider),
          Expanded(
            child: provider.filteredStores.isEmpty
                ? const Center(child: Text('표시할 가게가 없습니다.'))
                : (provider.isGridView
                ? _buildStoreGridView(context, provider)
                : _buildStoreListView(context, provider)),
          ),
        ],
      ),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context, StoreProvider provider) {
    return AppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      title: Text(provider.selectedLocation, style: AppTextStyles.title20SemiBold),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => setState(() => _isSearching = true),
          icon: const Icon(Icons.search),
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar(BuildContext context, StoreProvider provider) {
    return AppBar(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            provider.updateSearchQuery('');
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '가게 이름으로 검색...',
          border: InputBorder.none,
        ),
        onChanged: provider.updateSearchQuery,
      ),
    );
  }

  Widget _buildFoodCategoryFilters(BuildContext context, StoreProvider provider) {
    final categories = ['한식', '중식', '일식', '양식', '기타'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          final isSelected = provider.selectedFoodCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) => provider.selectFoodCategory(category),
            selectedColor: AppColors.primaryGreen,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.unclickGrey),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, StoreProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Text('좋아요 많은 순'),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          )
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
        childAspectRatio: 0.8,
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
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.name, style: AppTextStyles.body16Bold, overflow: TextOverflow.ellipsis),
                  Text(store.foodCategory, style: AppTextStyles.caption14Medium.copyWith(color: AppColors.grey)),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppColors.heartRed, size: 14),
                      const SizedBox(width: 2),
                      Text(store.likeSum.toString()),
                      const SizedBox(width: 8),
                      const Icon(Icons.comment, color: AppColors.grey, size: 14),
                      const SizedBox(width: 2),
                      const Text('0'),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: AppTextStyles.title20SemiBold),
                    Text(store.foodCategory, style: AppTextStyles.body16Regular.copyWith(color: AppColors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: AppColors.heartRed, size: 16),
                        const SizedBox(width: 4),
                        Text(store.likeSum.toString()),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment, color: AppColors.grey, size: 16),
                        const SizedBox(width: 4),
                        const Text('0'),
                      ],
                    )
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: store.displayedImg,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}