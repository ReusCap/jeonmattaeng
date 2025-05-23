import 'package:flutter/material.dart';
import 'package:jeonmattaeng/models/store_model.dart';
import 'package:jeonmattaeng/services/store_service.dart';

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
    return _stores
        .where((store) => store.name.contains(_searchQuery))
        .toList();
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
            : const Text(
          '전맛탱',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.pink,
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

          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '가게 리스트',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),

              ...stores.map((store) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 좌측 텍스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            store.foodCategory,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.favorite, size: 16, color: Colors.pink),
                              const SizedBox(width: 4),
                              Text(store.likeSum.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 썸네일
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
              )),
            ],
          );
        },
      ),
    );
  }
}
