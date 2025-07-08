import 'package:flutter/material.dart';
import 'notice_detail_page.dart';

// 공지사항 데이터 모델 (향후 API 연동 시 모델 파일로 분리 권장)
class Notice {
  final String id;
  final String title;
  final String date;
  final String content; // 상세 내용

  Notice({
    required this.id,
    required this.title,
    required this.date,
    required this.content,
  });
}

class NoticeListPage extends StatefulWidget {
  const NoticeListPage({Key? key}) : super(key: key);

  @override
  State<NoticeListPage> createState() => _NoticeListPageState();
}

class _NoticeListPageState extends State<NoticeListPage> {
  // TODO: CMS 구현 후, API를 통해 공지사항 목록을 불러오도록 수정해야 합니다.
  // 현재는 임시 목업(mock) 데이터를 사용합니다.
  final List<Notice> _notices = [
    Notice(
        id: '1',
        title: '신년맞이 기능개선 안내☀️',
        date: '2022.01.20',
        content: '''
안녕하세요 여러분!

[불편사항]
- 첫번째 불편사항
- 두번째 불편사항
- 세번째 불편사항

[개선사항]
- 첫번째 개선사항
- 두번째 개선사항
- 세번째 개선사항
'''
    ),
    Notice(
        id: '2',
        title: '개인정보 처리방침 및 이용약관 개정 안내',
        date: '2022.01.20',
        content: '개인정보 처리방침 및 이용약관이 개정되었습니다. 자세한 내용은 앱 내 약관을 확인해주세요.'
    ),
    Notice(
        id: '3',
        title: '서버 점검 안내 (02:00 ~ 04:00)',
        date: '2022.01.18',
        content: '보다 안정적인 서비스 제공을 위해 서버 점검을 진행합니다. 점검 시간에는 서비스 이용이 원활하지 않을 수 있습니다.'
    ),
  ];

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
      body: ListView.separated(
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          final notice = _notices[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            title: Text(notice.title, style: const TextStyle(fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                notice.date,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            onTap: () {
              // 공지사항 상세 페이지로 이동하면서 선택된 공지사항 객체를 전달
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetailPage(notice: notice),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          // 각 항목 사이에 얇은 회색 구분선 추가
          return Divider(height: 1, thickness: 1, color: Colors.grey[200]);
        },
      ),
    );
  }
}