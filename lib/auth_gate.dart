// auth_gate.dart (NEW FILE)
// 경로: lib/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'login/login_screen.dart';
import 'main_screen/main_screen.dart';

// 사용자의 인증 상태에 따라 로그인 화면 또는 메인 화면을 보여주는 위젯
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      // AuthService의 인증 상태 변경 스트림을 구독
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 인증 상태를 기다리는 중이면 로딩 인디케이터 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 사용자가 로그인 상태이면(snapshot에 데이터가 있으면) MainScreen 표시
        if (snapshot.hasData) {
          return MainScreen();
        }

        // 사용자가 로그인 상태가 아니면 LoginScreen 표시
        return LoginScreen();
      },
    );
  }
}