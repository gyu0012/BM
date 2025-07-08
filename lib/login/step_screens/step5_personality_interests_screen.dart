// =================================================================
// =================================================================

// login/step_screens/step5_personality_interests_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step5_personality_interests_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';

class Step5PersonalityInterestsScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step5PersonalityInterestsScreen({Key? key, required this.userProfileData, required this.onNext, required this.onBack}) : super(key: key);

  @override
  _Step5PersonalityInterestsScreenState createState() => _Step5PersonalityInterestsScreenState();
}

class _Step5PersonalityInterestsScreenState extends State<Step5PersonalityInterestsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _selfIntroductionController;

  final List<String> _allPersonalityTraits = ['예의바른', '긍정적', '잘웃는', '솔직한', '다정한', '배려심', '털털', '장난', '애교', '유머', '섬세', '수줍은', '낙천적', '활발한', '감성적', '친절한', '엉뚱한', '성실한'];
  final List<String> _allHobbies = ['영화', '드라마', '음악', '맛집', '카페', '노래', '게임', '술', '요리', '패션', '공연', '사진', '쇼핑', '웹툰', '예술', '여행', '애니', '인테리어', '악기', '뷰티', '미술', '춤', '드라이브', '산책', '헬스', '자전거', '골프', '캠핑', '수영', '야구', '테니스', '크로스핏', '볼링', '축구', '배드민턴', '등산', '클라이밍', '러닝', '낚시', '필라테스', '요가', '공부', '독서', '어학', '재테크', '봉사'];
  final List<String> _allInterests = ['영화', '드라마', '음악', '맛집', '카페', '노래', '게임', '술', '요리', '패션', '공연', '사진', '쇼핑', '웹툰', '예술', '여행', '애니', '인테리어', '악기', '뷰티', '미술', '춤', '드라이브', '산책', '헬스', '자전거', '골프', '캠핑', '수영', '야구', '테니스', '크로스핏', '볼링', '축구', '배드민턴', '등산', '클라이밍', '러닝', '낚시', '필라테스', '요가', '공부', '독서', '어학', '재테크', '봉사'];

  @override
  void initState() {
    super.initState();
    _selfIntroductionController = TextEditingController(text: widget.userProfileData.selfIntroduction);
  }

  void _submitStep() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.userProfileData.personalityTraits.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('성격을 1개 이상 선택해주세요.')));
        return;
      }
      if (widget.userProfileData.hobbies.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('취미를 1개 이상 선택해주세요.')));
        return;
      }
      if (widget.userProfileData.interests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('관심사를 1개 이상 선택해주세요.')));
        return;
      }

      widget.userProfileData.selfIntroduction = _selfIntroductionController.text.trim();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('성격 및 자기소개', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),
            _buildChipSelector('성격 (최대 3개)', _allPersonalityTraits, widget.userProfileData.personalityTraits, 3),
            SizedBox(height: 16),
            _buildChipSelector('취미 (최대 3개)', _allHobbies, widget.userProfileData.hobbies, 3),
            SizedBox(height: 16),
            _buildChipSelector('관심사 (최대 3개)', _allInterests, widget.userProfileData.interests, 3),
            SizedBox(height: 16),
            TextFormField(
              controller: _selfIntroductionController,
              decoration: InputDecoration(
                  labelText: '자기소개 (최소 10자)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true
              ),
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.length < 10) {
                  return '최소 10자 이상 입력해주세요.';
                }
                return null;
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(onPressed: _submitStep, child: Text('다음')),
            SizedBox(height: 10),
            TextButton(onPressed: widget.onBack, child: Text('이전단계로')),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelector(String label, List<String> allOptions, List<String> selectedOptions, int maxSelection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.start,
            children: allOptions.map((option) {
              final bool isSelected = selectedOptions.contains(option);
              return FilterChip(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                label: Text(option),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: Colors.pinkAccent,
                backgroundColor: Colors.grey.shade200,
                shape: StadiumBorder(
                    side: BorderSide(
                        color: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
                        width: 1.0
                    )
                ),
                onSelected: (bool selected) {
                  // [수정] 칩 선택/해제 로직 변경
                  setState(() {
                    if (selected) {
                      // 선택하려는 경우
                      if (selectedOptions.length < maxSelection) {
                        selectedOptions.add(option);
                      } else {
                        // 개수 초과 시 메시지 표시
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('최대 $maxSelection개까지 선택할 수 있습니다.')));
                      }
                    } else {
                      // 선택 해제하려는 경우
                      selectedOptions.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _selfIntroductionController.dispose();
    super.dispose();
  }
}
