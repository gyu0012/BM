// =================================================================
// =================================================================

// login/step_screens/step10_survey_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step10_survey_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';
import '../../models/detailed_survey_data.dart'; // 상세 설문 데이터 모델

class Step10SurveyScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step10SurveyScreen({
    Key? key,
    required this.userProfileData,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  _Step10SurveyScreenState createState() => _Step10SurveyScreenState();
}

class _Step10SurveyScreenState extends State<Step10SurveyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['배경', '일상', '만남', '연애', '결혼'];

  late Map<String, List<SurveyQuestion>> _categorizedQuestions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _categorizedQuestions = {};
    for (var category in _categories) {
      _categorizedQuestions[category] = DetailedSurveyRepository.allQuestions
          .where((q) => q.category == category)
          .toList();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _submitStep() {
    if (widget.userProfileData.surveyAnswers.length < DetailedSurveyRepository.allQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 설문 항목에 답변해주세요.')),
      );
      return;
    }

    int totalFixedScore = 0;
    final fixedScoreQuestions = DetailedSurveyRepository.allQuestions
        .where((q) => q.type == QuestionType.fixed);

    for (var question in fixedScoreQuestions) {
      int? selectedAnswerIndex = widget.userProfileData.surveyAnswers[question.id];
      if (selectedAnswerIndex != null) {
        totalFixedScore += question.answers[selectedAnswerIndex].fixedScore ?? 0;
      }
    }
    widget.userProfileData.myFixedValuesScore = totalFixedScore;

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorSize: TabBarIndicatorSize.tab, // [추가] 인디케이터가 탭 전체 너비를 차지하도록 함
          tabs: _categories.map((String category) => Tab(text: category)).toList(),
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.pinkAccent,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              return _buildSurveyList(_categorizedQuestions[category]!);
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ElevatedButton(
            onPressed: _submitStep,
            child: Text('가입 완료하고 시작하기'),
          ),
        )
      ],
    );
  }

  Widget _buildSurveyList(List<SurveyQuestion> questions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final questionData = questions[index];
        return _buildQuestionWidget(questionData);
      },
    );
  }

  Widget _buildQuestionWidget(SurveyQuestion questionData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionData.questionText,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              hintText: '답변을 선택해주세요',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            isExpanded: true,
            value: widget.userProfileData.surveyAnswers[questionData.id],
            items: questionData.answers.asMap().entries.map((entry) {
              int index = entry.key;
              Answer answer = entry.value;
              return DropdownMenuItem<int>(
                value: index,
                child: Text(answer.text, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (int? selectedAnswerIndex) {
              if (selectedAnswerIndex != null) {
                setState(() {
                  widget.userProfileData.surveyAnswers[questionData.id] = selectedAnswerIndex;
                });
              }
            },
            validator: (value) => value == null ? '답변을 선택해주세요.' : null,
          ),
        ],
      ),
    );
  }
}
