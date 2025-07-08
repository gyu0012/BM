import 'package:flutter/material.dart';

// 색상 시스템 정의
class AppColors {
  // Core Colors
  static const Color corePrimary = Color(0xFFE94057); // 메인 레드
  static const Color coreSecondary = Color(0xFF007AFF); // 블루 (사용 시)
  static const Color coreNeutralPrimary = Color(0xFF1C1C1E); // 다크 그레이/블랙
  static const Color coreNeutralSecondary = Color(0xFFF2F2F7); // 라이트 그레이

  // Label Colors (On Dark Background)
  static const Color labelPrimary = Color(0xFFFFFFFF); // 흰색
  static const Color labelSecondary = Color(0x99EBEBF5); // 흰색 (60% 투명도)
  static const Color labelTertiary = Color(0x4DEBEBF5); // 흰색 (30% 투명도)

  // Label Colors (On Light Background)
  static const Color labelPrimaryDark = Color(0xFF000000); // 검은색
  static const Color labelSecondaryDark = Color(0x993C3C43); // 회색 (60% 투명도)

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // 흰색 배경
  static const Color backgroundSecondary = Color(0xFFF2F2F7); // 연한 회색 배경

  // Separator
  static const Color separatorPrimary = Color(0xFFE5E5EA);

  // Group
  static const Color groupPrimary = Color(0xFFFFFFFF);
  static const Color groupSecondary = Color(0xFFF2F2F7);
}

// 타이포그래피 시스템 정의
class AppTextStyles {
  static const String fontFamily = 'Pretendard';

  static const TextStyle titleL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );

  static const TextStyle titleM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );

  static const TextStyle titleS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );

  static const TextStyle baseL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );

  static const TextStyle baseM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.03,
  );

  static const TextStyle baseS = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.03,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.03,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
  );
}

// [추가] 앱 전체 테마 정의
class AppTheme {
  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.corePrimary,
      scaffoldBackgroundColor: AppColors.backgroundSecondary,
      fontFamily: AppTextStyles.fontFamily,

      // 앱 전체 색상 구성표 정의
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.corePrimary,
        primary: AppColors.corePrimary,
        secondary: AppColors.coreSecondary,
        error: Colors.red.shade800,
        background: AppColors.backgroundSecondary,
        surface: AppColors.backgroundPrimary,
      ),

      // AppBar 테마
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundPrimary,
        foregroundColor: AppColors.labelPrimaryDark,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        titleTextStyle: AppTextStyles.titleS.copyWith(color: AppColors.labelPrimaryDark),
      ),

      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.titleL,
        headlineMedium: AppTextStyles.titleM,
        titleLarge: AppTextStyles.titleS,
        bodyLarge: AppTextStyles.baseM,
        bodyMedium: AppTextStyles.baseS,
        labelLarge: AppTextStyles.baseL,
        bodySmall: AppTextStyles.footnote,
        labelSmall: AppTextStyles.caption,
      ).apply(
        bodyColor: AppColors.labelPrimaryDark,
        displayColor: AppColors.labelPrimaryDark,
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.corePrimary,
            foregroundColor: AppColors.labelPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: AppTextStyles.baseL
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.corePrimary,
            textStyle: AppTextStyles.baseM,
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
          borderSide: BorderSide(color: AppColors.separatorPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.corePrimary, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: AppTextStyles.baseS.copyWith(color: AppColors.labelSecondaryDark),
      ),

      // 하단 네비게이션 바 테마
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundPrimary,
        selectedItemColor: AppColors.corePrimary,
        unselectedItemColor: AppColors.labelTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 2,
      ),

      // 팝업 다이얼로그 테마
      dialogTheme: DialogTheme(
          backgroundColor: AppColors.backgroundPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titleTextStyle: AppTextStyles.titleS.copyWith(color: AppColors.labelPrimaryDark),
          contentTextStyle: AppTextStyles.baseS.copyWith(color: AppColors.labelSecondaryDark)
      ),

      // 체크박스 테마
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.corePrimary;
          }
          return AppColors.labelTertiary;
        }),
        checkColor: MaterialStateProperty.all(AppColors.labelPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // 탭바 테마
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.corePrimary,
        unselectedLabelColor: AppColors.labelSecondaryDark,
        indicatorColor: AppColors.corePrimary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // 하단 시트 테마
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.backgroundPrimary,
        modalBackgroundColor: AppColors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
