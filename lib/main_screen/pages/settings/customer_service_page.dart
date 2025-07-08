import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 이메일 연동을 위해 필요

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({Key? key}) : super(key: key);

  // 이메일 앱을 실행하는 함수
  Future<void> _launchEmail() async {
    const String email = 'support@balancematch.com';
    const String subject = '앱 관련 문의사항';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        // 이메일 앱을 찾을 수 없는 경우에 대한 예외 처리
        // 실제 앱에서는 사용자에게 알림(예: 스낵바)을 표시하는 것이 좋습니다.
        print('Could not launch ${emailLaunchUri.toString()}');
      }
    } catch (e) {
      print('Error launching email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // 연한 회색 배경
      appBar: AppBar(
        title: const Text('고객센터', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '고객센터 관련 안내문',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '문의 시 아이디나 닉네임을 함께 알려주시면 더 빠른 처리가 가능합니다. 보내주신 문의는 영업일 기준 1-2일 내에 답변드리겠습니다.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 화면 하단에 고정되는 버튼
          _buildBottomButton(),
        ],
      ),
    );
  }

  // 하단 CTA 버튼 위젯
  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // 하단 여백 추가
      color: Colors.grey[200], // 배경과 동일한 색상으로 자연스럽게 연결
      child: ElevatedButton(
        onPressed: _launchEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C), // 진한 차콜색
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '고객센터 연락하기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
