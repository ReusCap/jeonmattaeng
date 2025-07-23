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

    // ✅ [수정] 위젯이 빌드된 후, Provider를 통해 가게 데이터를 미리 불러옵니다.
    // listen: false로 설정하여 불필요한 리빌드를 방지합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchStores();
    });
  }

  void _onItemTapped(int index) {
    // 홈 탭을 다시 눌렀을 때 초기화하는 로직은 그대로 유지합니다.
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
      // ✅ IndexedStack을 사용하여 탭 전환 시 페이지 상태를 유지합니다.
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
