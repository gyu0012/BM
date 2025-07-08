// login/step_screens/step1a_gender_selection_screen.dart (NEW FILE)
// 경로: lib/login/step_screens/step1a_gender_selection_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';

class Step1aGenderSelectionScreen extends StatelessWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step1aGenderSelectionScreen({
    Key? key,
    required this.userProfileData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  void _selectGender(BuildContext context, String gender) {
    userProfileData.gender = gender;
    onNext(); // 성별을 선택하면 바로 다음 단계로 이동
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar를 제거하여 SignUpFlowScreen의 AppBar가 보이도록 함
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '성별을 선택해주세요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              SizedBox(height: 48),
              _buildGenderButton(context, '남자', Icons.male),
              SizedBox(height: 24),
              _buildGenderButton(context, '여자', Icons.female),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(BuildContext context, String gender, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(gender, style: TextStyle(fontSize: 20)),
      onPressed: () => _selectGender(context, gender),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        foregroundColor: Colors.white,
        backgroundColor: gender == '남자' ? Colors.blue.shade300 : Colors.red.shade300,
      ),
    );
  }
}