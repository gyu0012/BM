import 'package:balancematch/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

import 'etc/withdrawal_page.dart'; // [추가] 회원탈퇴 페이지 import

class EtcPage extends StatelessWidget {
  const EtcPage({Key? key}) : super(key: key);

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, size: 26, color: color ?? Colors.grey.shade700),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('기타'),
      ),
      body: ListView(
        children: <Widget>[
          _buildListTile('약관 보기', Icons.description_outlined, () {
            // TODO: 약관 보기 페이지로 이동
          }),
          _buildListTile('로그아웃', Icons.logout, () {
            // 로그아웃 확인 다이얼로그 표시
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃 하시겠습니까?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('취소'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('확인', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        // [수정] 비동기 처리 및 화면 이동 로직 개선
                        await authService.signOut();
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                                  (route) => false
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          }, color: Colors.redAccent),
          _buildListTile('회원탈퇴', Icons.no_accounts_outlined, () {
            // [수정] 회원탈퇴 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WithdrawalPage()),
            );
          }, color: Colors.grey.shade600),
        ],
      ),
    );
  }
}
