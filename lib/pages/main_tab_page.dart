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
      // ✅ 2. BottomNavigationBar를 Container로 감싸서 상단에 구분선 추가
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // 위쪽에만 얇은 회색 테두리를 줍니다.
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0, // ✨ 컨테이너에 테두리를 줬으므로 기본 그림자는 제거합니다.
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: '지도'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
          ],
        ),
      ),
    );
  }
}