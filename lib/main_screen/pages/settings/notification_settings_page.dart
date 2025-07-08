import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isLoading = true;
  Map<String, bool> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Firestore에서 현재 사용자의 알림 설정을 불러오는 함수
  Future<void> _loadSettings() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      final settings = await authService.getNotificationSettings(userId);
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 설정 값을 변경하고 Firestore에 업데이트하는 함수
  Future<void> _updateSetting(String key, bool value) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;

    if (userId == null) return;

    setState(() {
      _settings[key] = value;
      // '모든 알림' 스위치를 끄면 모든 하위 스위치도 끔
      if (key == 'allNotifications' && !value) {
        _settings.updateAll((key, v) => false);
      }
      // '모든 알림' 스위치를 켜면 모든 하위 스위치도 켬
      if (key == 'allNotifications' && value) {
        _settings.updateAll((key, v) => true);
      }
    });

    try {
      await authService.updateNotificationSettings(userId, _settings);
    } catch (e) {
      // 에러 발생 시 사용자에게 알림 (예: 스낵바)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 저장에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          _buildSwitchTile(
            title: '모든 알림',
            valueKey: 'allNotifications',
            isHeader: true,
          ),
          const Divider(height: 1),
          _buildSectionHeader('일반 알림'),
          _buildSwitchTile(
            title: '공지사항 알림',
            valueKey: 'general_notice',
          ),
          _buildSwitchTile(
            title: '푸시 메세지 알림',
            valueKey: 'general_push',
          ),
          const Divider(height: 1),
          _buildSectionHeader('매칭 알림'),
          _buildSwitchTile(
            title: '상대방이 나의 프로필 카드 열람',
            valueKey: 'matching_profileView',
          ),
          _buildSwitchTile(
            title: '상대방이 나에게 호감 전송',
            valueKey: 'matching_like',
          ),
          _buildSwitchTile(
            title: '상대방이 내 호감 수락/거절',
            valueKey: 'matching_likeResponse',
          ),
          _buildSwitchTile(
            title: '상대방이 내 연락처 열람',
            valueKey: 'matching_contactView',
          ),
        ],
      ),
    );
  }

  // 섹션 헤더 위젯
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  // 스위치 리스트 타일 위젯
  Widget _buildSwitchTile({
    required String title,
    required String valueKey,
    bool isHeader = false,
  }) {
    // '모든 알림'이 꺼져있으면 하위 스위치는 비활성화
    final bool isEnabled = _settings['allNotifications'] ?? true;

    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      value: _settings[valueKey] ?? true,
      onChanged: (isHeader || isEnabled) ? (bool value) {
        _updateSetting(valueKey, value);
      } : null, // 비활성화 상태일 때는 onChanged를 null로 설정
      activeColor: Colors.pinkAccent,
    );
  }
}
