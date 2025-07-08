// 경로: lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'services/auth_service.dart';
import 'design_system.dart'; // [추가] 디자인 시스템 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );

    if (kDebugMode) {
      String? token = await FirebaseAppCheck.instance.getToken(true);
      print('*********************************************************************');
      print('** Firebase App Check Debug Token:');
      print('** $token');
      print('*********************************************************************');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
    runApp(ErrorApp(errorMessage: 'Firebase 초기화에 실패했습니다. 설정을 확인해주세요.\n$e'));
    return;
  }
  runApp(const MyApp());
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  const ErrorApp({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(errorMessage, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // [수정] MyApp 위젯에서 로컬 색상 정의를 제거합니다.

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'BalanceMatch',
        // [수정] design_system.dart에 정의된 테마를 불러와 적용합니다.
        theme: AppTheme.getThemeData(),
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
