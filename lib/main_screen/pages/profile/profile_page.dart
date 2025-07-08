// 경로: lib/main_screen/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import 'widgets/profile_tab.dart';
import 'widgets/ability_tab.dart';
import 'widgets/values_tab.dart';
import 'widgets/locked_content_placeholder.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<UserModel?>>? _profilesFuture;

  // --- 상태 변수 통합 ---
  bool _isMyProfile = false;
  // 콘텐츠 잠금/열람 상태
  bool _isAbilityUnlocked = false;
  bool _isValuesUnlocked = false;
  bool _isLoadingUnlocks = true;
  // 사용자 관계 상태
  Map<String, dynamic> _relationshipStatus = {'status': 'loading'};
  // [추가] 차단 상태
  bool _isBlocked = false;
  bool _isLoadingBlockStatus = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 위젯 빌드가 완료된 후 데이터를 로드하여 안전하게 Provider에 접근
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// 프로필에 필요한 모든 데이터를 로드하는 통합 메소드
  void _loadData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final myUserId = authService.getCurrentUser()?.uid;

    if (!mounted) return;

    setState(() {
      _isMyProfile = (myUserId == widget.userId);

      // 내 프로필일 경우 모든 콘텐츠를 열람 상태로 설정
      if (_isMyProfile) {
        _isAbilityUnlocked = true;
        _isValuesUnlocked = true;
        _isLoadingUnlocks = false;
        _isLoadingBlockStatus = false; // 내 프로필은 차단 상태가 없음
        _profilesFuture = Future.wait([authService.getUserProfile(widget.userId)]);
      }
      // 다른 사용자 프로필일 경우, 필요한 모든 상태를 확인
      else {
        _checkUnlockStatus();
        _loadRelationshipStatus();
        _checkBlockStatus(); // [추가] 차단 상태 확인
        _profilesFuture = Future.wait([
          myUserId != null ? authService.getUserProfile(myUserId) : Future.value(null),
          authService.getUserProfile(widget.userId),
        ]);
      }
    });
  }

  /// 프로필 탭(어빌리티, 가치관) 열람 상태를 확인
  Future<void> _checkUnlockStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final unlockedTabs = await authService.checkUnlockStatus(widget.userId);
    if (mounted) {
      setState(() {
        _isAbilityUnlocked = unlockedTabs.contains('ability');
        _isValuesUnlocked = unlockedTabs.contains('values');
        _isLoadingUnlocks = false;
      });
    }
  }

  /// 두 사용자 간의 관계 상태를 확인
  Future<void> _loadRelationshipStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final status = await authService.getRelationshipStatus(widget.userId);
    if (mounted) {
      setState(() => _relationshipStatus = status);
    }
  }

  /// [추가] 사용자의 차단 상태를 확인하는 메소드
  Future<void> _checkBlockStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isBlocked = await authService.isUserBlocked(widget.userId);
    if (mounted) {
      setState(() {
        _isBlocked = isBlocked;
        _isLoadingBlockStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중(프로필 로드 시작 전 또는 차단 상태 확인 중)일 때 로딩 인디케이터 표시
    if (_profilesFuture == null || _isLoadingBlockStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // [추가] 차단된 사용자일 경우, 차단 전용 UI 표시
    if (_isBlocked) {
      return _buildBlockedStateUI();
    }

    return Scaffold(
      body: FutureBuilder<List<UserModel?>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoadingUnlocks) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty || snapshot.data!.last == null) {
            return Scaffold(appBar: AppBar(), body: const Center(child: Text('프로필 정보를 불러올 수 없습니다.')));
          }

          final myProfile = _isMyProfile ? snapshot.data!.first : snapshot.data![0];
          final targetUser = _isMyProfile ? snapshot.data!.first! : snapshot.data!.last!;

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: Text('${targetUser.nickname ?? '사용자'}님의 프로필'),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  // [추가] 더보기 메뉴 (내 프로필이 아닐 때만 표시)
                  actions: [
                    if (!_isMyProfile)
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showMoreOptions(context),
                      ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: [
                      const Tab(text: '프로필'),
                      Tab(icon: _isMyProfile || _isAbilityUnlocked ? null : const Icon(Icons.lock, size: 18), text: '어빌리티'),
                      Tab(icon: _isMyProfile || _isValuesUnlocked ? null : const Icon(Icons.lock, size: 18), text: '가치관'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                ProfileTab(user: targetUser),
                _isAbilityUnlocked
                    ? AbilityTab(myProfile: myProfile, targetUser: targetUser)
                    : LockedContentPlaceholder(title: '어빌리티 정보', onUnlock: () => _unlockContent('어빌리티')),
                _isValuesUnlocked
                    ? ValuesTab(user: targetUser)
                    : LockedContentPlaceholder(title: '가치관 정보', onUnlock: () => _unlockContent('가치관')),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _isMyProfile
          ? null
          : FutureBuilder<List<UserModel?>>(
          future: _profilesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.last == null) {
              return const SizedBox.shrink();
            }
            final targetUser = snapshot.data!.last!;
            return _buildBottomActionButton(targetUser);
          }
      ),
    );
  }

  /// [신규] 차단 상태일 때 보여줄 전체 화면 위젯
  Widget _buildBlockedStateUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              '차단된 사용자입니다.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.unblockUser(widget.userId);
                setState(() => _isBlocked = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('차단을 해제했습니다.')),
                );
              },
              child: const Text('차단 해제'),
            ),
          ],
        ),
      ),
    );
  }

  /// [신규] 더보기 메뉴(신고/차단) 바텀 시트
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.report_gmailerrorred, color: Colors.red),
                title: const Text('신고하기', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop(); // 바텀 시트 닫기
                  _showReportDialog(context);
                },
              ),
              ListTile(
                leading: Icon(_isBlocked ? Icons.check_circle_outline : Icons.block, color: Colors.blue),
                title: Text(_isBlocked ? '차단 해제' : '차단하기', style: const TextStyle(color: Colors.blue)),
                onTap: () async {
                  Navigator.of(context).pop(); // 바텀 시트 닫기
                  final authService = Provider.of<AuthService>(context, listen: false);
                  if (_isBlocked) {
                    await authService.unblockUser(widget.userId);
                    setState(() => _isBlocked = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('차단을 해제했습니다.')));
                  } else {
                    await authService.blockUser(widget.userId);
                    setState(() => _isBlocked = true);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('사용자를 차단했습니다.')));
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('취소'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// [신규] 신고 사유 선택 다이얼로그
  void _showReportDialog(BuildContext context) {
    final reportReasons = ['부적절한 프로필', '욕설 및 비방', '사기 의심', '스팸 및 광고', '기타'];
    String? selectedReason;
    final otherReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('사용자 신고'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('신고 사유를 선택해주세요.'),
                    ...reportReasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) => setDialogState(() => selectedReason = value),
                      );
                    }),
                    if (selectedReason == '기타')
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          controller: otherReasonController,
                          decoration: const InputDecoration(
                            hintText: '상세 사유를 입력해주세요.',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: (selectedReason == null) ? null : () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    try {
                      await authService.reportUser(
                        reportedUserId: widget.userId,
                        reason: selectedReason!,
                        details: otherReasonController.text,
                      );
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고가 접수되었습니다.')),
                      );
                    } catch (e) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('신고 접수 중 오류가 발생했습니다: $e')),
                      );
                    }
                  },
                  child: const Text('접수하기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 기존 하단 버튼 및 콘텐츠 열람 로직 (변경 없음) ---

  /// 관계 상태에 따라 다른 버튼을 보여주는 위젯
  Widget _buildBottomActionButton(UserModel targetUser) {
    final status = _relationshipStatus['status'];

    if (status == 'loading') {
      return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
    }

    switch (status) {
      case 'like_sent':
        return _buildButton('호감 수락 대기중', null);
      case 'like_received':
        return _buildButton('호감 수락하기', () => _acceptLike(targetUser));
      case 'matched':
        bool unlocked = _relationshipStatus['contactInfoUnlocked'] ?? false;
        return _buildButton(
          unlocked ? '연락처: ${targetUser.phoneNumber}' : '연락처 열람하기 (재화 소모)',
          unlocked ? null : () => _unlockContact(targetUser),
        );
      case 'none':
      default:
        return _buildButton('호감 보내기', () => _sendLike(targetUser));
    }
  }

  /// 공통 버튼 위젯
  Widget _buildButton(String text, VoidCallback? onPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: onPressed == null ? Colors.grey : Theme.of(context).colorScheme.primary,
          disabledBackgroundColor: Colors.grey[400],
        ),
      ),
    );
  }

  /// 호감 보내기 로직
  void _sendLike(UserModel targetUser) {
    final List<String> likeReasonOptions = ['외모', '취미 및 관심사', '라이프 스타일', '연애/결혼 가치관', '능력/학력'];
    final List<String> selectedReasons = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${targetUser.nickname ?? '상대'}님에게 호감을 보냅니다.'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('호감을 보낸 이유(1개 이상 선택)'),
                    const SizedBox(height: 8),
                    ...likeReasonOptions.map((reason) {
                      return CheckboxListTile(
                        title: Text(reason),
                        value: selectedReasons.contains(reason),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            if (value == true) selectedReasons.add(reason);
                            else selectedReasons.remove(reason);
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  onPressed: selectedReasons.isEmpty ? null : () async {
                    Navigator.of(dialogContext).pop();
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.sendLike(targetUser.uid, selectedReasons);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${targetUser.nickname}님에게 호감을 보냈습니다.')),
                    );
                    _loadRelationshipStatus();
                  },
                  child: const Text('호감 전송'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 호감 수락하기 로직
  void _acceptLike(UserModel targetUser) {
    final List<String> reasons = List<String>.from(_relationshipStatus['reasons'] ?? []);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('${targetUser.nickname ?? '상대'}님이 보낸 호감'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('상대방이 아래의 이유로 호감을 보냈습니다.', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (reasons.isEmpty) const Text('전달된 호감 이유가 없습니다.')
                else ...reasons.map((reason) => ListTile(
                  leading: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary),
                  title: Text(reason),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('나중에'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('수락하기'),
              onPressed: () async {
                final authService = Provider.of<AuthService>(context, listen: false);
                final likeId = _relationshipStatus['likeId'];
                if (likeId == null) return;
                Navigator.of(dialogContext).pop();
                await authService.acceptLike(likeId, targetUser.uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${targetUser.nickname}님과 매칭되었습니다!')),
                );
                _loadRelationshipStatus();
              },
            ),
          ],
        );
      },
    );
  }

  /// 연락처 열람하기 로직
  void _unlockContact(UserModel targetUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('연락처 열람'),
          content: const Text('상대방의 연락처를 확인하시겠습니까?\n(재화 1개가 소모됩니다)'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: const Text('열람하기'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.unlockContact(targetUser.uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('연락처 열람이 완료되었습니다.')),
                );
                _loadRelationshipStatus();
              },
            ),
          ],
        );
      },
    );
  }

  /// 콘텐츠(탭) 열람 로직
  void _unlockContent(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type 정보 열람'),
        content: const Text('재화를 사용하여 정보를 열람하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('열람하기'),
            onPressed: () async {
              Navigator.of(context).pop();
              final authService = Provider.of<AuthService>(context, listen: false);
              String tabKey = (type == '어빌리티') ? 'ability' : 'values';
              await authService.unlockProfileTab(widget.userId, tabKey);
              setState(() {
                if (type == '어빌리티') _isAbilityUnlocked = true;
                else if (type == '가치관') _isValuesUnlocked = true;
              });
            },
          ),
        ],
      ),
    );
  }
}