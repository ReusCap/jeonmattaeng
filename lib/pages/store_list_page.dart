import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/store_service.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';
import 'package:jeonmattaeng/pages/menu_page.dart';
import 'package:jeonmattaeng/theme/app_text_styles.dart';

class StoreListPage extends StatefulWidget {
  const StoreListPage({super.key});

  @override
  State<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  late Future<List<Store>> _storeFuture;
  List<Store> _stores = [];
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  void _loadStores() {
    _storeFuture = StoreService.fetchStores();
    _storeFuture.then((data) {
      setState(() {
        _stores = data;
      });
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchQuery = '';
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
  }

  List<Store> get _filteredStores {
    if (_searchQuery.isEmpty) return _stores;
    return _stores.where((store) => store.name.contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
        title: _isSearching
            ? TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '가게 이름 검색',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        )
            : Text(
          '전맛탱',
          style: AppTextStyles.title20SemiBold.copyWith(
            color: AppColors.heartRed, // ❤️ 브랜드 타이틀 강조
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              if (_isSearching) {
                _cancelSearch();
              } else {
                _startSearch();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Store>>(
        future: _storeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || _stores.isEmpty) {
            return const Center(child: Text('가게 목록을 불러오지 못했습니다.'));
          }

          final stores = _filteredStores;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: stores.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '가게 리스트',
                    style: AppTextStyles.subtitle18SemiBold, // 📝 서브타이틀 스타일
                  ),
                );
              }

              final store = stores[index - 1];
              return InkWell(
                onTap: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuPage(
                        storeId: store.id,
                        storeName: store.name,
                        storeCategory: store.foodCategory,
                        storeImage: store.image,
                        storeLikeCount: store.likeSum,
                        storeLocation: store.location,
                      ),
                    ),
                  );

                  if (updated == true) {
                    _loadStores(); // ✅ 좋아요 변경되었으면 가게 목록 다시 로드
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
                            Text(
                              store.name,
                              style: AppTextStyles.title20SemiBold, // 🍽️ 가게 이름
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.foodCategory,
                              style: AppTextStyles.body16Regular.copyWith(
                                color: AppColors.categroyGray, // 🍱 카테고리 색상
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.favorite, size: 16, color: AppColors.heartRed),
                                const SizedBox(width: 4),
                                Text(
                                  store.likeSum.toString(),
                                  style: AppTextStyles.caption10Medium.copyWith(
                                    color: AppColors.heartRed, // ❤️ 하트 강조
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          store.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.store),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
