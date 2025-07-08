import 'dart:async';
import 'dart:ui'; // ImageFilter 사용을 위해 import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'profile/profile_page.dart';
import '../../design_system.dart'; // 디자인 시스템 import

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<UserModel?> _myProfileFuture;
  late Future<bool> _canReceiveCardsFuture;

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
    _checkCardStatus();
  }

  void _loadMyProfile() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final myUserId = authService.getCurrentUser()?.uid;
    if (myUserId != null) {
      _myProfileFuture = authService.getUserProfile(myUserId);
    } else {
      _myProfileFuture = Future.value(null);
    }
  }

  void _checkCardStatus() {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _canReceiveCardsFuture = authService.canReceiveWeeklyCards();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadMyProfile();
      _checkCardStatus();
    });
    await Future.wait([_myProfileFuture, _canReceiveCardsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.coreNeutralPrimary,
        leading: IconButton(
          icon: const Icon(Icons.shield_outlined, color: AppColors.labelPrimary),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.labelPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.labelPrimary),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<UserModel?>(
                future: _myProfileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox(height: 250, child: Center(child: Text("내 정보를 불러올 수 없습니다.")));
                  }
                  return _buildMyHexagonCard(context, snapshot.data!);
                },
              ),
              _buildTodayCardsTab(context),
              // [수정] 불필요한 authService 인자 제거
              _buildRecommendationSection(context),
              _buildDailyQuestSection(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 컴포넌트 2: 내 육각형 정보 카드
  Widget _buildMyHexagonCard(BuildContext context, UserModel myProfile) {
    final scores = myProfile.abilityScores ?? {};
    double totalScore = scores.values.fold(0, (sum, item) => sum + item);
    double averageScore = scores.isNotEmpty ? totalScore / scores.length : 0.0;

    final stats = {
      "소속": scores['직업'] ?? 0.0,
      "학력": scores['학력'] ?? 0.0,
      "외모": scores['외모'] ?? 0.0,
      "성격": scores['가치관'] ?? 0.0,
      "자산": scores['자산'] ?? 0.0,
      "집안": scores['부모님'] ?? 0.0,
    };

    return Container(
      color: AppColors.coreNeutralPrimary,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("내 육각형 정보", style: AppTextStyles.titleM),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 120,
                height: 138,
                child: ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE94057), Color(0xFFF27121)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("종합", style: AppTextStyles.baseM),
                        Text(averageScore.toStringAsFixed(1), style: AppTextStyles.titleL),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: stats.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key, style: AppTextStyles.baseS.copyWith(color: AppColors.labelSecondary)),
                        const SizedBox(height: 4),
                        Text((entry.value / 10).toStringAsFixed(1), style: AppTextStyles.baseL.copyWith(color: AppColors.labelPrimary)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 컴포넌트 3: '오늘의 카드' 탭
  Widget _buildTodayCardsTab(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(bottom: BorderSide(color: AppColors.separatorPrimary, width: 1)),
      ),
      child: Text(
        "오늘의 카드",
        style: AppTextStyles.baseM.copyWith(color: AppColors.corePrimary),
      ),
    );
  }

  // 컴포넌트 4: 프로필 카드 목록 (기존 로직과 새 UI 결합)
  Widget _buildRecommendationSection(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FutureBuilder<bool>(
        future: _canReceiveCardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.data == true) {
            return _buildGetCardsButton(context, authService);
          }
          return _buildRecommendationList(authService);
        },
      ),
    );
  }

  // 카드 받기 버튼
  Widget _buildGetCardsButton(BuildContext context, AuthService authService) {
    return SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이번 주 추천 프로필 카드를 받아보세요!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.getWeeklyCards();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('새로운 카드가 도착했습니다!')));
                  _checkCardStatus();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('카드 받기 실패: $e')));
                }
              },
              child: const Text('프로필 카드 받기'),
            ),
          ],
        ),
      ),
    );
  }

  // 추천 카드 리스트
  Widget _buildRecommendationList(AuthService authService) {
    return FutureBuilder<List<String>>(
      future: authService.getBlockedUserIds(),
      builder: (context, blockedUsersSnapshot) {
        if (!blockedUsersSnapshot.hasData) {
          return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()));
        }
        final blockedUserIds = blockedUsersSnapshot.data!;

        return StreamBuilder<List<Recommendation>>(
          stream: authService.getRecommendedUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 280, child: Center(child: CircularProgressIndicator()));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 280,
                child: Center(child: Text("도착한 카드가 없습니다.\n다음 주 월요일을 기다려주세요.")),
              );
            }
            final recommendations = snapshot.data!;
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
                  final isBlocked = blockedUserIds.contains(recommendation.user.uid);
                  return _ProfileCard(
                    recommendation: recommendation,
                    isBlocked: isBlocked,
                    isBlurred: index > 1, // 임시 로직: 2개 이후 카드는 블러 처리
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // 컴포넌트 5: 데일리 퀘스트 섹션
  Widget _buildDailyQuestSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Text(
        "데일리 퀘스트",
        style: AppTextStyles.titleM.copyWith(color: AppColors.labelPrimaryDark),
      ),
    );
  }
}

// 육각형 모양을 만드는 CustomClipper
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// 프로필 카드 위젯 (내부용)
class _ProfileCard extends StatelessWidget {
  final Recommendation recommendation;
  final bool isBlocked;
  final bool isBlurred;

  const _ProfileCard({
    Key? key,
    required this.recommendation,
    required this.isBlocked,
    required this.isBlurred,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = recommendation.user;
    return GestureDetector(
      onTap: () {
        if (!isBlurred) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userId: user.uid)));
        }
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 이미지
              Image.network(
                user.profileImageUrls?.first ?? "https://placehold.co/180x280/e2e8f0/333333?text=No+Image",
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.grey.shade300),
              ),
              // 블러 처리
              if (isBlurred)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              // 하단 정보 그라데이션
              if (!isBlurred)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              // 콘텐츠
              if (isBlurred)
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.backgroundPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text("확인하기", style: AppTextStyles.baseM.copyWith(color: AppColors.labelSecondaryDark)),
                  ),
                )
              else
                _buildCardInfo(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${user.height ?? '??'}세 ${user.jobTitle ?? '???'} ${user.residenceArea ?? '???'}", style: AppTextStyles.baseM.copyWith(color: AppColors.labelPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBadge("육각형 인증"),
              const SizedBox(width: 4),
              _buildBadge("뛰어난 외모"),
            ],
          ),
          const SizedBox(height: 8),
          Text(user.nickname ?? '이름 없음', style: AppTextStyles.titleL.copyWith(color: AppColors.labelPrimary)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coreNeutralPrimary.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("프로필 보기", style: AppTextStyles.baseM.copyWith(color: AppColors.labelPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.groupSecondary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: AppTextStyles.caption.copyWith(color: AppColors.labelPrimaryDark)),
    );
  }
}
