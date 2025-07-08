// =================================================================
// =================================================================

// main_screen/pages/matching/likes_tab.dart (UPDATED)
// 경로: lib/main_screen/pages/matching/likes_tab.dart
import 'package:balancematch/main_screen/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../models/like_model.dart';
import '../../../services/auth_service.dart';

class LikesTab extends StatelessWidget {
  const LikesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [ Tab(text: '받은 호감'), Tab(text: '보낸 호감'), ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLikesList(context, received: true),
                _buildLikesList(context, received: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikesList(BuildContext context, {required bool received}) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final stream = received ? authService.getReceivedLikes() : authService.getSentLikes();

    return StreamBuilder<List<Like>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('${received ? '받은' : '보낸'} 호감이 없습니다.'));
        }

        final likes = snapshot.data!;

        return ListView.builder(
          itemCount: likes.length,
          itemBuilder: (context, index) {
            final like = likes[index];
            final userId = received ? like.fromUserId : like.toUserId;

            return FutureBuilder<UserModel?>(
              future: authService.getUserProfile(userId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return ListTile();
                final user = userSnapshot.data!;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user.profileImageUrls?.first ?? ''),
                    ),
                    title: Text(user.nickname ?? '알 수 없음', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      received ? '${user.nickname}님이 회원님에게 호감을 보냈습니다.' : '${user.nickname}님에게 호감을 보냈습니다.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: user.uid)));
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}