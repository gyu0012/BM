// 경로: lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
// [추가] Firebase App Check 패키지 import
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'auth_gate.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // 1. Firebase 서비스 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2. [추가] Firebase App Check 활성화
    await FirebaseAppCheck.instance.activate(
      // 안드로이드에서는 Play Integrity 사용
      androidProvider: AndroidProvider.playIntegrity,
      // iOS에서는 DeviceCheck 사용
      appleProvider: AppleProvider.deviceCheck,
    );

  } catch (e) {
    print('Firebase initialization error: $e');
    // 초기화 실패 시 에러 화면 표시
    runApp(ErrorApp(errorMessage: 'Firebase 초기화에 실패했습니다. 설정을 확인해주세요.\n$e'));
    return;
  }
  // 초기화 성공 시 메인 앱 실행
  runApp(MyApp());
}

/// Firebase 초기화 실패 시 보여줄 에러 위젯
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

/// 메인 애플리케이션 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 디자인 가이드에 따른 색상 정의
    const Color primaryRed = Color(0xFFD32F2F);
    const Color primaryBlue = Color(0xFF1976D2);
    const Color neutralPrimary = Color(0xFF212121);
    const Color neutralSecondary = Color(0xFF757575);
    const Color neutralTertiary = Color(0xFFBDBDBD);
    const Color backgroundPrimary = Color(0xFFFFFFFF);
    const Color backgroundSecondary = Color(0xFFF5F5F5);

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'BalanceMatch',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryRed,
          scaffoldBackgroundColor: backgroundSecondary,
          fontFamily: 'Noto Sans KR',

          // 앱 전체 색상 구성표 정의
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryBlue,
            primary: primaryBlue,
            secondary: primaryRed,
            error: Colors.red.shade800,
            background: backgroundSecondary,
            surface: backgroundPrimary,
          ),

          // AppBar 테마
          appBarTheme: AppBarTheme(
            backgroundColor: backgroundPrimary,
            foregroundColor: neutralPrimary,
            elevation: 1,
            shadowColor: Colors.grey.withOpacity(0.2),
            titleTextStyle: TextStyle(
                color: neutralPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Noto Sans KR'
            ),
          ),

          // 텍스트 테마
          textTheme: TextTheme(
            displayLarge: TextStyle(color: neutralPrimary, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(color: neutralPrimary, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(color: neutralPrimary, fontWeight: FontWeight.w600),
            titleMedium: TextStyle(color: neutralSecondary),
            bodyLarge: TextStyle(color: neutralPrimary, fontSize: 16),
            bodyMedium: TextStyle(color: neutralSecondary, fontSize: 14),
            labelLarge: TextStyle(color: backgroundPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),

          // 버튼 테마
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: backgroundPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryRed,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              )
          ),

          // 카드 테마
          cardTheme: CardTheme(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          ),

          // 입력 필드 테마
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: TextStyle(color: neutralSecondary),
          ),

          // 하단 네비게이션 바 테마
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: backgroundPrimary,
            selectedItemColor: primaryRed,
            unselectedItemColor: neutralSecondary,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            elevation: 2,
          ),

          // 팝업 다이얼로그 테마
          dialogTheme: DialogTheme(
              backgroundColor: backgroundPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titleTextStyle: TextStyle(color: neutralPrimary, fontSize: 20, fontWeight: FontWeight.bold),
              contentTextStyle: TextStyle(color: neutralSecondary, fontSize: 16)
          ),

          // 체크박스 테마
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return primaryBlue;
              }
              return neutralTertiary;
            }),
            checkColor: MaterialStateProperty.all(backgroundPrimary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),

          // 탭바 테마
          tabBarTheme: TabBarTheme(
            labelColor: primaryRed,
            unselectedLabelColor: neutralSecondary,
            indicatorColor: primaryRed,
            indicatorSize: TabBarIndicatorSize.tab,
          ),

          // 슬라이더 테마
          sliderTheme: SliderThemeData(
            activeTrackColor: primaryBlue,
            inactiveTrackColor: primaryBlue.withOpacity(0.3),
            thumbColor: primaryBlue,
            overlayColor: primaryBlue.withAlpha(50),
          ),

          // 하단 시트 테마
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: backgroundPrimary,
            modalBackgroundColor: backgroundPrimary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
        ),
        home: AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}