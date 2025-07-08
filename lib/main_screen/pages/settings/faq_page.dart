import 'package:flutter/material.dart';

// FAQ 데이터 모델 (향후 API 연동 시 모델 파일로 분리 권장)
class FAQ {
  final String id;
  final String question;
  final String answer;

  FAQ({required this.id, required this.question, required this.answer});
}

class FaqPage extends StatelessWidget {
   FaqPage({Key? key}) : super(key: key);

  // TODO: CMS 구현 후, API를 통해 FAQ 목록을 불러오도록 수정해야 합니다.
  // 현재는 임시 목업(mock) 데이터를 사용합니다.
  final List<FAQ> _faqs = [
    FAQ(
      id: '1',
      question: '재화(알파)는 어떻게 사용하나요?',
      answer: '알파는 서비스 내에서 다른 사용자에게 호감을 표현하거나, 잠겨있는 프로필을 열람하는 등 다양한 유료 기능을 이용할 때 사용되는 가상의 화폐입니다.',
    ),
    FAQ(
      id: '2',
      question: '결제가 되었는데 재화가 충전되지 않았어요.',
      answer: '결제 시스템의 일시적인 오류일 수 있습니다. 앱을 완전히 종료했다가 다시 실행하여 재화가 정상적으로 충전되었는지 확인해 주세요. 문제가 지속될 경우, 앱 내 [고객센터]를 통해 문의해 주시면 신속하게 처리해 드리겠습니다.',
    ),
    FAQ(
      id: '3',
      question: '프로필 사진은 어떻게 변경하나요?',
      answer: '설정 페이지의 [프로필 변경] 메뉴를 통해 새로운 사진을 추가하거나 기존 사진을 삭제할 수 있습니다. 프로필 사진은 최소 1장 이상 등록되어야 합니다.',
    ),
    FAQ(
      id: '4',
      question: '회원 탈퇴는 어떻게 하나요?',
      answer: '설정 페이지의 [기타] 메뉴에 있는 [회원 탈퇴] 버튼을 통해 진행할 수 있습니다. 탈퇴 시 모든 개인정보와 활동 내역은 관련 법령에 따라 안전하게 처리되며, 복구할 수 없으니 신중하게 결정해 주세요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            title: Text(
              faq.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                color: Colors.grey[50],
                child: Text(
                  faq.answer,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
