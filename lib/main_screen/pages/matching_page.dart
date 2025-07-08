import 'package:flutter/material.dart';
import 'matching/my_cards_tab.dart';
import 'matching/likes_tab.dart';
import 'matching/matches_tab.dart';

class MatchingPage extends StatelessWidget {
  const MatchingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // MainScreen에서 AppBar를 관리하므로 여기서는 TabBar만 추가
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              TabBar(
                tabs: [
                  Tab(text: '추천 프로필'),
                  Tab(text: '받은/보낸 호감'),
                  Tab(text: '매칭 완료'),
                ],
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyCardsTab(),
            LikesTab(),
            MatchesTab(),
          ],
        ),
      ),
    );
  }
}
