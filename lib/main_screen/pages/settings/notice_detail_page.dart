import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'notice_list_page.dart'; // Notice 모델을 사용하기 위해 import

class NoticeDetailPage extends StatelessWidget {
  final Notice notice;

  const NoticeDetailPage({Key? key, required this.notice}) : super(key: key);

  // 본문 텍스트를 Markdown 형식으로 변환하는 함수
  String _formatContentToMarkdown(String content) {
    // [텍스트] -> **텍스트** (굵게)
    String formatted = content.replaceAllMapped(
      RegExp(r'\[(.*?)\]'),
          (match) => '**${match.group(1)}**',
    );
    // - 텍스트 -> * 텍스트 (글머리 기호)
    formatted = formatted.replaceAllMapped(
      RegExp(r'^- (.*)', multiLine: true),
          (match) => '* ${match.group(1)}',
    );
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                notice.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // 날짜
              Text(
                notice.date,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              // 구분선
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),
              // 본문 (Markdown 렌더링)
              // TODO: 이 기능을 사용하려면 pubspec.yaml 파일에 flutter_markdown 패키지를 추가해야 합니다.
              // dependencies:
              //   flutter_markdown: ^0.6.18
              MarkdownBody(
                data: _formatContentToMarkdown(notice.content),
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16, height: 1.6), // 본문 텍스트 스타일
                  listBullet: const TextStyle(fontSize: 16, height: 1.6), // 리스트 스타일
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
