// main_tab_page.dart
import 'package:flutter/material.dart';
import 'store_list_page.dart';
import 'map_page.dart';
import 'mypage.dart';
import 'package:jeonmattaeng/theme/app_colors.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0; // ✅ 기본 탭: 리스트 페이지

  final List<Widget> _pages = const [
    StoreListPage(), // 리스트
    //MapPage(),             // 지도
    MyPage(),              // 마이페이지
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFFFFFFF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '리스트'),
          //BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}
