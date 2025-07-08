// login/step_screens/step4_detailed_profile2_screen.dart (NEW FILE)
// 경로: lib/login/step_screens/step4_detailed_profile2_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';

class Step4DetailedProfile2Screen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Step4DetailedProfile2Screen({required this.userProfileData, required this.onNext, required this.onBack});

  @override
  _Step4DetailedProfile2ScreenState createState() => _Step4DetailedProfile2ScreenState();
}

class _Step4DetailedProfile2ScreenState extends State<Step4DetailedProfile2Screen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _religionOptions = ['무교', '기독교', '불교', '천주교', '기타'];
  final List<String> _smokingOptions = ['비흡연', '가끔 흡연 (연초)', '매일 흡연 (연초)', '전자담배 사용', '금연 중'];
  final List<String> _drinkingOptions = ['전혀 안 함', '가끔 사회적으로', '즐기는 편 (주 1-2회)', '자주 마심 (주 3회 이상)'];
  final List<String> _drinkingAmountOptions = ['못 마셔요/안 마셔요', '맥주 1~2잔', '소주 반 병', '소주 1병', '소주 1~2병', '소주 2병 이상'];
  final List<String> _mbtiOptions = [
    'ISTJ', 'ISFJ', 'INFJ', 'INTJ', 'ISTP', 'ISFP', 'INFP', 'INTP',
    'ESTP', 'ESFP', 'ENFP', 'ENTP', 'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ', '잘 모름'
  ];


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('상세 프로필 (2/2)', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),
            _buildDropdownField('종교', _religionOptions, widget.userProfileData.religion, (val) => setState(() => widget.userProfileData.religion = val)),
            _buildDropdownField('흡연', _smokingOptions, widget.userProfileData.smokingHabits, (val) => setState(() => widget.userProfileData.smokingHabits = val)),
            _buildDropdownField('음주', _drinkingOptions, widget.userProfileData.drinkingHabits, (val) => setState(() => widget.userProfileData.drinkingHabits = val)),
            _buildDropdownField('주량', _drinkingAmountOptions, widget.userProfileData.drinkingAmount, (val) => setState(() => widget.userProfileData.drinkingAmount = val)),
            _buildDropdownField('MBTI', _mbtiOptions, widget.userProfileData.mbti, (val) => setState(() => widget.userProfileData.mbti = val)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onNext();
                }
              },
              child: Text('다음'),
            ),
            SizedBox(height: 10),
            TextButton(onPressed: widget.onBack, child: Text('이전단계로')),
          ],
        ),
      ),
    );
  }
  Widget _buildDropdownField(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.checklist_rtl_outlined)),
        value: currentValue,
        items: options.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? '$label을(를) 선택해주세요.' : null,
      ),
    );
  }
}