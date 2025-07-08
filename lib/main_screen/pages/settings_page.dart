import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'settings/etc_page.dart';
import 'settings/edit_profile_page.dart';
import 'profile/profile_page.dart';
import 'settings/store_page.dart';
import 'settings/notice_list_page.dart';
import 'settings/faq_page.dart';
import 'settings/customer_service_page.dart';
import 'settings/notification_settings_page.dart';
import 'settings/change_password_page.dart';
import 'settings/block_contacts_page.dart'; // [추가] BlockContactsPage import

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    Widget _buildSectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
        child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
      );
    }

    Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
      return ListTile(
        leading: Icon(icon, size: 26, color: Colors.grey.shade700),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      );
    }

    return Scaffold(
      body: ListView(
        children: <Widget>[
          _buildSectionHeader('내 정보'),
          _buildListTile('내 프로필', Icons.person_outline, () {
            final myUserId = authService.getCurrentUser()?.uid;
            if (myUserId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: myUserId)),
              );
            }
          }),
          _buildListTile('프로필 변경', Icons.edit_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditProfilePage()),
            );
          }),

          _buildSectionHeader('서비스'),
          _buildListTile('상점', Icons.storefront_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StorePage()),
            );
          }),
          _buildListTile('공지사항', Icons.campaign_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NoticeListPage()),
            );
          }),
          _buildListTile('FAQ', Icons.quiz_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FaqPage()),
            );
          }),
          _buildListTile('고객센터', Icons.headset_mic_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CustomerServicePage()),
            );
          }),
          // [추가] 지인 차단하기 메뉴
          _buildListTile('지인 차단하기', Icons.block, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BlockContactsPage()),
            );
          }),

          _buildSectionHeader('앱 설정'),
          _buildListTile('알림 설정', Icons.notifications_outlined, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
            );
          }),
          _buildListTile('비밀번호 변경', Icons.lock_outline, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
            );
          }),
          _buildListTile('기타', Icons.more_horiz_outlined, () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EtcPage()));
          }),
        ],
      ),
    );
  }
}
