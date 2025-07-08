import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../profile/profile_page.dart';

class MyCardsTab extends StatelessWidget {
  const MyCardsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final myUserId = authService.getCurrentUser()?.uid;

    if (myUserId == null) {
      return const Center(child: Text("로그인이 필요합니다."));
    }

    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: authService.getBlockedUserIds(),
        builder: (context, blockedUsersSnapshot) {
          if (blockedUsersSnapshot.connectionState == ConnectionState.waiting && !blockedUsersSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // 에러가 발생하거나 데이터가 null일 경우를 대비
          final blockedUserIds = blockedUsersSnapshot.data ?? [];

          return StreamBuilder<List<Recommendation>>(
            stream: authService.getRecommendedUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('오류 발생: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("오늘의 추천 프로필이 없습니다."));
              }

              final recommendations = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
                  final isBlocked = blockedUserIds.contains(recommendation.user.uid);

                  return ProfileCardWithTimer(
                    recommendation: recommendation,
                    isBlocked: isBlocked,
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

class ProfileCardWithTimer extends StatefulWidget {
  final Recommendation recommendation;
  final bool isBlocked; // [추가] 차단 여부를 받는 변수

  const ProfileCardWithTimer({
    Key? key,
    required this.recommendation,
    required this.isBlocked, // [추가] 생성자에 추가
  }) : super(key: key);

  @override
  State<ProfileCardWithTimer> createState() => _ProfileCardWithTimerState();
}

class _ProfileCardWithTimerState extends State<ProfileCardWithTimer> {
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
  }

  void _calculateRemainingTime() {
    final expiresAt = widget.recommendation.createdAt.toDate().add(const Duration(days: 7));
    final now = DateTime.now();
    final remaining = expiresAt.difference(now);

    if (mounted) {
      setState(() {
        _remainingTime = remaining.isNegative ? Duration.zero : remaining;
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds <= 0) {
      return "기간 만료";
    }

    if (duration.inHours >= 24) {
      int days = (duration.inHours / 24).ceil();
      return "D-$days";
    }
    else if (duration.inHours > 0) {
      return "D-${duration.inHours}h";
    }
    else if (duration.inMinutes > 0) {
      return "D-${duration.inMinutes}m";
    }
    else {
      return "D-1m";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.recommendation.user;

    // [수정] 차단 여부와 관계없이 항상 프로필 페이지로 이동할 수 있도록 GestureDetector를 최상위로 이동
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(userId: user.uid)),
        );
      },
      child: _buildCardContent(context),
    );
  }

  // [추가] 카드의 내용을 빌드하는 별도 메서드
  Widget _buildCardContent(BuildContext context) {
    // [수정] 만약 차단된 사용자라면, 차단 UI를 즉시 반환합니다.
    if (widget.isBlocked) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.grey.shade300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, color: Colors.grey.shade700, size: 48),
              const SizedBox(height: 8),
              Text('차단된 사용자', style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
      );
    }

    // 차단되지 않은 경우, 기존 프로필 카드 UI를 보여줍니다.
    final firstPhoto = widget.recommendation.user.profileImageUrls?.isNotEmpty == true
        ? widget.recommendation.user.profileImageUrls![0]
        : null;

    return VisibilityDetector(
      key: Key(widget.recommendation.user.uid),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5) {
          _calculateRemainingTime();
        }
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Positioned.fill(
              child: firstPhoto != null
                  ? Image.network(
                firstPhoto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 80, color: Colors.grey.shade400),
              )
                  : Container(color: Colors.grey.shade300, child: Icon(Icons.person, size: 80, color: Colors.grey.shade400)),
            ),
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(_remainingTime),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recommendation.user.nickname ?? '이름 없음',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.recommendation.user.residenceArea ?? ''}',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
