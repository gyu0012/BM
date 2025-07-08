import 'dart:async';
import 'dart:ui'; // ImageFilter 사용을 위해 import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  final _pageController = PageController(viewportFraction: 0.95);

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
    _checkCardStatus();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  // [신규] 카드 받기 로직을 별도 함수로 분리하여 재사용
  Future<void> _fetchNewCards() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.getWeeklyCards();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('새로운 카드가 도착했습니다!')));
      }
      _checkCardStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('카드 받기 실패: $e')));
      }
    }
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
              _buildRecommendationSection(context),
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
      "소속": scores['직업'] ?? 0.0, "학력": scores['학력'] ?? 0.0,
      "외모": scores['외모'] ?? 0.0, "성격": scores['가치관'] ?? 0.0,
      "자산": scores['자산'] ?? 0.0, "집안": scores['부모님'] ?? 0.0,
    };

    return Container(
      color: AppColors.coreNeutralPrimary,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("내 육각형 정보", style: AppTextStyles.titleM.copyWith(color: AppColors.labelPrimary)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 120, height: 138,
                child: ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFFE94057), Color(0xFFF27121)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("종합", style: AppTextStyles.baseM.copyWith(color: AppColors.labelPrimary)),
                        Text(averageScore.toStringAsFixed(1), style: AppTextStyles.titleL.copyWith(color: AppColors.labelPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.5, mainAxisSpacing: 16, crossAxisSpacing: 16,
                  children: stats.entries.map((entry) {
                    return FittedBox(
                      fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: AppTextStyles.baseS.copyWith(color: AppColors.labelSecondary)),
                          const SizedBox(height: 4),
                          Text((entry.value / 10).toStringAsFixed(1), style: AppTextStyles.baseL.copyWith(color: AppColors.labelPrimary)),
                        ],
                      ),
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

  // '오늘의 카드' 탭
  Widget _buildTodayCardsTab(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(bottom: BorderSide(color: AppColors.separatorPrimary, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("오늘의 카드", style: AppTextStyles.baseM.copyWith(color: AppColors.corePrimary)),
          // [수정] 기존 버튼과 테스트 버튼을 Row로 묶음
          Row(
            children: [
              _buildGetCardsButtonSmall(),
              const SizedBox(width: 8),
              _buildTestModeButton(),
            ],
          )
        ],
      ),
    );
  }

  // '오늘의 카드' 탭 우측에 들어갈 작은 카드 받기 버튼
  Widget _buildGetCardsButtonSmall() {
    return FutureBuilder<bool>(
      future: _canReceiveCardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.0));
        }

        final bool canReceive = snapshot.data ?? false;

        return TextButton.icon(
          onPressed: canReceive ? _fetchNewCards : null,
          icon: Icon(Icons.card_giftcard_rounded, size: 16),
          label: Text(canReceive ? "카드 받기" : "다음 주"),
          style: TextButton.styleFrom(
            foregroundColor: canReceive ? AppColors.corePrimary : AppColors.labelSecondaryDark,
            textStyle: AppTextStyles.footnote,
          ),
        );
      },
    );
  }

  // [신규] 테스트 모드 버튼
  Widget _buildTestModeButton() {
    return OutlinedButton(
      onPressed: _fetchNewCards,
      child: const Text("테스트"),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.coreSecondary,
        side: BorderSide(color: AppColors.coreSecondary.withOpacity(0.5)),
        textStyle: AppTextStyles.footnote,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size(0, 30), // 버튼의 최소 높이 조절
      ),
    );
  }

  // 프로필 카드 목록
  Widget _buildRecommendationSection(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: _buildRecommendationList(context),
    );
  }

  // 추천 카드 리스트
  Widget _buildRecommendationList(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Provider.of<AuthService>(context, listen: false).getBlockedUserIds(),
      builder: (context, blockedUsersSnapshot) {
        if (!blockedUsersSnapshot.hasData) {
          return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
        }
        final blockedUserIds = blockedUsersSnapshot.data!;

        return StreamBuilder<List<Recommendation>>(
          stream: Provider.of<AuthService>(context, listen: false).getRecommendedUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 424, child: Center(child: CircularProgressIndicator()));
            }
            final recommendations = snapshot.data ?? [];

            return Column(
              children: [
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      Widget card;

                      if (index == 4) {
                        card = _buildSpecialMessageCard();
                      } else if (index < recommendations.length) {
                        final recommendation = recommendations[index];
                        final isBlocked = blockedUserIds.contains(recommendation.user.uid);
                        card = _ProfileCard(
                          recommendation: recommendation,
                          isBlocked: isBlocked,
                          isBlurred: index > 1,
                        );
                      } else {
                        card = _buildPlaceholderCard();
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: card,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 5,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: AppColors.corePrimary,
                    dotColor: AppColors.separatorPrimary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 5번째 페이지에 표시될 특별 메시지 카드
  Widget _buildSpecialMessageCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.corePrimary, AppColors.coreSecondary],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "매주 월요일 오전 11시\n새로운 프로필 카드가 나옵니다!",
              textAlign: TextAlign.center,
              style: AppTextStyles.baseL.copyWith(
                color: AppColors.labelPrimary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 빈 슬롯에 표시될 플레이스홀더 카드
  Widget _buildPlaceholderCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        color: AppColors.backgroundSecondary,
        child: const Center(
          child: Icon(
            Icons.hourglass_empty_rounded,
            color: AppColors.labelSecondaryDark,
            size: 50,
          ),
        ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                user.profileImageUrls?.first ?? "https://placehold.co/180x280/e2e8f0/333333?text=No+Image",
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: AppColors.backgroundSecondary),
              ),
              if (isBlurred)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              if (!isBlurred)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
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
          Text("${user.height ?? '??'}cm ${user.jobTitle ?? '???'} ${user.residenceArea ?? '???'}", style: AppTextStyles.baseM.copyWith(color: AppColors.labelPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBadge("육각형 인증"),
              const SizedBox(width: 4),
              _buildBadge("뛰어난 외모"),
            ],
          ),
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