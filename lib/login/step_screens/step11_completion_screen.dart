// =================================================================
// =================================================================

// login/step_screens/step11_completion_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step11_completion_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';
import '../../main_screen/main_screen.dart'; // [추가] MainScreen import

class Step11CompletionScreen extends StatelessWidget {
  final UserProfileData userProfileData;
  // [수정] onFinish 콜백 제거
  const Step11CompletionScreen({Key? key, required this.userProfileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.check_circle_outline, color: Colors.pinkAccent, size: 80),
              SizedBox(height: 24),
              Text(
                '${userProfileData.nickname}님, 환영합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
              ),
              SizedBox(height: 12),
              Text(
                '회원가입이 성공적으로 완료되었습니다.\n지금 바로 내 짝 찾기를 시작해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700, height: 1.5),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                // [수정] onPressed에 직접 네비게이션 로직 구현
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MainScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text('서비스 이용하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
