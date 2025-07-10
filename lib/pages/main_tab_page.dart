import 'package:flutter/material.dart';
import 'package:jeonmattaeng/pages/home_page.dart';
import 'package:jeonmattaeng/pages/map_page.dart';
import 'package:jeonmattaeng/pages/mypage.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0;

  // 1. HomePage를 제어하기 위한 GlobalKey 생성
  final GlobalKey<HomePageState> _homeKey = GlobalKey();

  // 2. 페이지 목록을 인스턴스 변수로 변경
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 3. 페이지 목록 초기화 시 HomePage에 Key를 할당
    _pages = <Widget>[
      HomePage(key: _homeKey), // HomePage에 Key 전달
      const MapPage(),
      const MyPage(),
    ];
  }

  // 4. 탭을 눌렀을 때의 동작을 처리하는 함수
  void _onItemTapped(int index) {
    // 만약 현재 '홈' 탭(인덱스 0)이 선택된 상태에서 '홈' 탭을 다시 눌렀다면
    if (index == 0 && _selectedIndex == 0) {
      // Key를 사용해 HomePage의 reset() 메소드를 호출하여 초기 화면으로 돌림
      _homeKey.currentState?.reset();
    }

    // 선택된 탭의 인덱스를 변경하여 화면을 전환
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped, // 5. 새로 만든 함수를 연결
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined), label: '지도'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
          ],
        ),
      ),
    );
  }
}