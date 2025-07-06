// lib/pages/main_tab_page.dart (최종 수정본)

import 'package:flutter/material.dart';
import 'package:jeonmattaeng/pages/home_page.dart'; // ✅ StoreListPage 대신 HomePage를 임포트
import 'map_page.dart';
import 'mypage.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0;

  // ✅ 1. 페이지 목록을 새로운 구조에 맞게 변경합니다.
  // 첫 번째 페이지를 StoreListPage에서 HomePage로 교체합니다.
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    MapPage(), // TODO: MapPage 구현 필요
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 선택된 인덱스에 맞는 페이지를 보여줍니다.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // ✅ 2. BottomNavigationBar 아이템들도 새로운 구조에 맞게 수정합니다.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.redAccent, // 활성화된 아이콘 색상
        unselectedItemColor: Colors.grey,   // 비활성화된 아이콘 색상
        showSelectedLabels: true,           // 선택된 아이템 라벨 표시
        showUnselectedLabels: true,         // 선택되지 않은 아이템 라벨 표시
        type: BottomNavigationBarType.fixed, // 탭 애니메이션 고정
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}