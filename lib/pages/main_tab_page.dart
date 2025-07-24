import 'package:flutter/material.dart';
import 'package:jeonmattaeng/pages/home_page.dart';
import 'package:jeonmattaeng/pages/map_page.dart';
import 'package:jeonmattaeng/pages/mypage.dart';
import 'package:jeonmattaeng/providers/store_provider.dart';
import 'package:provider/provider.dart';

// ✅ [추가] Provider를 제공하기 위한 Wrapper 위젯
// 이 위젯이 MainTabPage를 감싸면서 StoreProvider를 생성합니다.
class MainTabPageWrapper extends StatelessWidget {
  const MainTabPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreProvider(),
      child: const MainTabPage(),
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _selectedIndex = 0;
  final GlobalKey<HomePageState> _homeKey = GlobalKey();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = <Widget>[
      HomePage(key: _homeKey),
      const MapPage(),
      const MyPage(),
    ];

    // ✅ 변경된 부분: allStores가 비었을 때만 fetchStores() 호출
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<StoreProvider>();
      if (provider.allStores.isEmpty) {
        await provider.fetchStores();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 0 && _selectedIndex == 0) {
      _homeKey.currentState?.reset();
    }

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
        height: 110.0, // ✅ 원하는 높이로 설정 (기본값은 보통 56.0)
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
