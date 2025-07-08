import 'package:balancematch/main_screen/pages/analysis_page.dart';
import 'package:balancematch/main_screen/pages/history_page.dart';
import 'package:balancematch/main_screen/pages/home_page.dart';
import 'package:balancematch/main_screen/pages/matching_page.dart';
import 'package:balancematch/main_screen/pages/settings_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // [추가] 각 탭에 해당하는 페이지 위젯 리스트
  // 관리를 용이하게 하기 위해 별도의 리스트로 분리합니다.
  final List<Widget> _pages = [
    const HomePage(),
    const MatchingPage(),
    const HistoryPage(),
    const AnalysisPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // [추가] 뒤로가기 버튼 로직을 처리하는 함수
  Future<bool> _onWillPop() async {
    // 현재 선택된 탭의 Navigator에서 pop이 가능한지 확인합니다.
    final isFirstRouteInCurrentTab =
    !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

    if (isFirstRouteInCurrentTab) {
      // 현재 탭의 스택에 더 이상 뒤로 갈 페이지가 없는 경우
      if (_selectedIndex != 0) {
        // 현재 탭이 '홈' 탭이 아니면, '홈' 탭으로 이동시킵니다.
        setState(() {
          _selectedIndex = 0;
        });
        // 앱을 종료하지 않습니다.
        return false;
      }
    }
    // 현재 탭이 '홈' 탭이고, 더 이상 뒤로 갈 페이지가 없으면 앱을 종료합니다.
    return isFirstRouteInCurrentTab;
  }

  @override
  Widget build(BuildContext context) {
    // [수정] Scaffold를 WillPopScope로 감싸서 뒤로가기 이벤트를 제어합니다.
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
            _buildOffstageNavigator(3),
            _buildOffstageNavigator(4),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: '매칭'),
            BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: '매칭 이력'),
            BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights), label: 'AI 분석'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: '설정'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Colors.grey.shade600,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
      ),
    );
  }

  // [수정] _buildOffstageNavigator가 인덱스만 받도록 변경
  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => _pages[index],
          );
        },
      ),
    );
  }
}
