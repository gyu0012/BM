// login/step_screens/step0_terms_agreement_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step0_terms_agreement_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';
import 'terms_detail_screen.dart'; // 새로 만든 상세 페이지 import

class Step0TermsAgreementScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;

  Step0TermsAgreementScreen({required this.userProfileData, required this.onNext});

  @override
  _Step0TermsAgreementScreenState createState() => _Step0TermsAgreementScreenState();
}

class _Step0TermsAgreementScreenState extends State<Step0TermsAgreementScreen> {
  bool _agreedToAllRequired = false;

  // --- [수정된 부분 시작] ---
  // 변수에 전체 URL이 아닌, Google Docs의 고유 ID만 저장합니다.
  // URL 예시: https://docs.google.com/document/d/e/[여기가 ID 부분]/pub
  static const String _serviceTermsDocId = "2PACX-1vSX_9GFvFdIxCOSMQu6QmRdS6WVdLkH_NmkmaHWlGFYtbx2LWwYdGbbxtPHQkEHAHWU1VKhle7pYyJl";
  static const String _privacyPolicyDocId = "2PACX-1vSs3SPpnF_aspViQyfpoLyK7VkA-iolSDg-WfO2C0EbeTCMH3hoErrZ8GYrIWDZLRnkL5Qx17UbLZGC";
  static const String _marketingConsentDocId = "2PACX-1vSlBxB7DJB0Npwc8DvS2TZbVxLlzZMzhfCc-_x_ohFpJ9HDOSBCebvUtNN9QbMJhJIuLTZb1Ydxq_gh";

  // 위 ID를 사용하여 올바른 웹 게시용 URL을 생성합니다.
  final String _serviceTermsUrl = 'https://docs.google.com/document/d/e/$_serviceTermsDocId/pub?embedded=true';
  final String _privacyPolicyUrl = 'https://docs.google.com/document/d/e/$_privacyPolicyDocId/pub?embedded=true';
  final String _marketingConsentUrl = 'https://docs.google.com/document/d/e/$_marketingConsentDocId/pub?embedded=true';
  // --- [수정된 부분 끝] ---


  @override
  void initState() {
    super.initState();
    _checkAgreements();
  }

  void _checkAgreements() {
    setState(() {
      _agreedToAllRequired = widget.userProfileData.agreedTerms && widget.userProfileData.agreedPrivacy;
    });
  }

  // "보기" 버튼 클릭 시 약관 상세 페이지로 이동하는 함수
  void _navigateToDetails(String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TermsDetailScreen(title: title, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('서비스 이용약관 동의', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
          SizedBox(height: 30),
          _buildAgreementRow(
            '서비스 이용약관 (필수)',
            widget.userProfileData.agreedTerms,
                (value) {
              setState(() { widget.userProfileData.agreedTerms = value ?? false; });
              _checkAgreements();
            },
                () => _navigateToDetails('서비스 이용약관', _serviceTermsUrl),
          ),
          _buildAgreementRow(
            '개인정보 처리방침 (필수)',
            widget.userProfileData.agreedPrivacy,
                (value) {
              setState(() { widget.userProfileData.agreedPrivacy = value ?? false; });
              _checkAgreements();
            },
                () => _navigateToDetails('개인정보 처리방침', _privacyPolicyUrl),
          ),
          _buildAgreementRow(
            '마케팅 정보 수신 동의 (선택)',
            widget.userProfileData.agreedMarketing,
                (value) {
              setState(() { widget.userProfileData.agreedMarketing = value ?? false; });
            },
                () => _navigateToDetails('마케팅 정보 수신 동의', _marketingConsentUrl),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _agreedToAllRequired ? widget.onNext : null,
            child: Text('동의하고 다음으로'),
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementRow(String title, bool value, ValueChanged<bool?> onChanged, VoidCallback onViewDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16))),
          TextButton(
            onPressed: onViewDetails, // "보기" 버튼 클릭 시 전달받은 함수 실행
            child: Text(
              '보기',
              style: TextStyle(decoration: TextDecoration.underline, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
