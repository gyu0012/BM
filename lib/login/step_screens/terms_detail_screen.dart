// login/step_screens/terms_detail_screen.dart (NEW FILE)
// 경로: lib/login/step_screens/terms_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// 각 약관의 상세 내용을 웹뷰로 보여주는 화면
class TermsDetailScreen extends StatefulWidget {
  final String title;
  final String url;

  const TermsDetailScreen({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<TermsDetailScreen> createState() => _TermsDetailScreenState();
}

class _TermsDetailScreenState extends State<TermsDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // WebView 컨트롤러 초기 설정
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 로딩 진행률 표시 (필요시 구현)
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // 웹 리소스 로딩 중 오류 발생 시 처리
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            print('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)); // 전달받은 URL 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 웹뷰 위젯
          WebViewWidget(controller: _controller),
          // 로딩 중일 때 로딩 인디케이터 표시
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.pinkAccent,
              ),
            ),
          // 에러 발생 시 에러 메시지 표시
          if (_hasError)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '페이지를 불러오는 데 실패했습니다.\n인터넷 연결을 확인하거나 잠시 후 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
