// =================================================================
// =================================================================

// main_screen/pages/analysis_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/analysis_page.dart
import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'AI 분석 페이지',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}