// 경로: lib/main_screen/pages/matching/matches_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../profile/profile_page.dart'; // [추가] 프로필 페이지를 import 합니다.


class MatchesTab extends StatelessWidget {
  const MatchesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<List<String>>(
        stream: authService.getMatchedUserIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('매칭된 상대가 없습니다.'));
          }

          final matchedUserIds = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: matchedUserIds.length,
            itemBuilder: (context, index) {
              // 각 매칭된 사용자의 프로필 정보를 가져옵니다.
              return FutureBuilder<UserModel?>(
                future: authService.getUserProfile(matchedUserIds[index]),
                builder: (context, userSnapshot) {
                  // 로딩 중이거나 데이터가 없으면 빈 위젯을 표시합니다.
                  if (userSnapshot.connectionState == ConnectionState.waiting || !userSnapshot.hasData) {
                    // 로딩 상태를 보여주기 위한 플레이스홀더 (선택 사항)
                    return const Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(radius: 30, backgroundColor: Colors.black12),
                        title: Text('...'),
                        subtitle: Text('...'),
                      ),
                    );
                  }

                  final user = userSnapshot.data!;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: (user.profileImageUrls?.isNotEmpty ?? false)
                            ? NetworkImage(user.profileImageUrls!.first)
                            : null,
                        child: (user.profileImageUrls?.isEmpty ?? true)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(user.nickname ?? '알 수 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                      // [수정] 부제목 텍스트를 프로필 확인에 맞게 변경
                      subtitle: const Text('매칭이 성사되었습니다! 프로필을 확인해보세요.'),
                      // [수정] 아이콘을 더 적절한 것으로 변경
                      trailing: const Icon(Icons.chevron_right),
                      // [수정] onTap 로직을 프로필 페이지로 이동하도록 변경
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(userId: user.uid),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}