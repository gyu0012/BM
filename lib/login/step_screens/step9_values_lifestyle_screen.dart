// =================================================================
// =================================================================

// login/step_screens/step9_values_lifestyle_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step9_values_lifestyle_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';

class Step9ValuesLifestyleScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step9ValuesLifestyleScreen({Key? key, required this.userProfileData, required this.onNext, required this.onBack}) : super(key: key);

  @override
  _Step9ValuesLifestyleScreenState createState() => _Step9ValuesLifestyleScreenState();
}

class _Step9ValuesLifestyleScreenState extends State<Step9ValuesLifestyleScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _allCoreValues = [
    '가족', '사랑', '성장', '안정', '행복', '신뢰', '건강', '자유', '정의',
    '성공', '헌신', '창의', '유머', '긍정', '배려', '예의', '평화', '성실',
    '열정', '책임감'
  ];

  final Map<String, List<String>> _lifestyleQuestions = {
    '선호하는 연락 빈도는?': [
      '필요할 때만',
      '하루 2~3번, 안부 물을 정도',
      '틈틈이 자주 (일상 공유)',
      '정해진 시간에 규칙적으로 (아침/저녁 등)',
      '딱히 정해두진 않음'
    ],
    '만났을 때 선호하는 장소는?': [
      '부담 없이 카페',
      '간단한 식사',
      '분위기 좋은 레스토랑/술집',
      '함께 즐길 거리가 있는 곳 (보드게임, 공원 산책 등)',
      '데이트처럼 (맛집, 카페, 영화 등 풀코스)'
    ],
    '선호하는 데이트 유형은?': [
      '맛집 탐방',
      '영화/공연/전시 관람',
      '액티비티 (스포츠, 방탈출 등)',
      '조용한 카페에서 대화',
      '함께하는 취미생활 (운동, 쇼핑, 드라이브 등)'
    ],
    '다퉜을 때 나는 어떻게 화해하는 편?': [
      '그 자리에서 바로 대화로 풀어야 함',
      '서로 감정이 가라앉은 뒤 차분하게 대화',
      '먼저 사과하고 넘어가는 편',
      '자연스럽게 아무 일 없었다는 듯이 풀림',
      '맛있는 음식을 먹으면서 화해'
    ],
    '데이트 비용은 어떻게 하는 게 편해?': [
      '번갈아 가면서 자연스럽게 내는 편',
      '공동의 목표! 데이트 통장을 만들어서 사용',
      '각자 쓴 비용은 확실하게 더치페이',
      '그때그때 상황에 따라 여유 있는 사람이 내기',
      '한 사람이 주도적으로 내는 게 편함'
    ]
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('가치관 및 생활관', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),
            _buildChipSelector('나의 핵심 가치관 (최대 3개)', _allCoreValues, widget.userProfileData.coreValues, 3),
            SizedBox(height: 24),
            Text('나의 생활관', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._lifestyleQuestions.entries.map((entry) {
              return _buildLifestyleQuestion(entry.key, entry.value, widget.userProfileData.lifestyleChoices[entry.key], (val) {
                setState(() {
                  widget.userProfileData.lifestyleChoices[entry.key] = val!;
                });
              });
            }).toList(),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (widget.userProfileData.coreValues.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('핵심 가치관을 1개 이상 선택해주세요.')));
                    return;
                  }
                  bool allLifestyleAnswered = _lifestyleQuestions.keys.every((key) => widget.userProfileData.lifestyleChoices[key] != null && widget.userProfileData.lifestyleChoices[key]!.isNotEmpty);
                  if (!allLifestyleAnswered) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 생활관 질문에 답변해주세요.')));
                    return;
                  }
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
                      if (selectedOptions.length < maxSelection) {
                        selectedOptions.add(option);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('최대 $maxSelection개까지 선택할 수 있습니다.')));
                      }
                    } else {
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

  Widget _buildLifestyleQuestion(String question, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: '답변을 선택해주세요',
              contentPadding: EdgeInsets.symmetric(horizontal:12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            value: currentValue,
            isExpanded: true,
            items: options.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: onChanged,
            validator: (value) => value == null || value.isEmpty ? '답변을 선택해주세요.' : null,
          ),
        ],
      ),
    );
  }
}
