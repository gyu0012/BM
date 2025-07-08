// main_screen/pages/profile/widgets/values_tab.dart (UPDATED)
// 경로: lib/main_screen/pages/profile/widgets/values_tab.dart
import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../models/detailed_survey_data.dart';

class ValuesTab extends StatefulWidget {
  final UserModel user;
  const ValuesTab({Key? key, required this.user}) : super(key: key);

  @override
  State<ValuesTab> createState() => _ValuesTabState();
}

class _ValuesTabState extends State<ValuesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _surveyCategories = ['배경', '일상', '만남', '연애', '결혼'];

  // 카테고리별로 질문을 미리 분류
  late Map<String, List<SurveyQuestion>> _categorizedQuestions;

  @override
  void initState() {
    super.initState();
    // [수정] 탭 컨트롤러 길이를 5로 변경
    _tabController = TabController(length: _surveyCategories.length, vsync: this);

    _categorizedQuestions = {};
    for (var category in _surveyCategories) {
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

  @override
  Widget build(BuildContext context) {
    // surveyAnswers가 null이거나 비어있으면 표시할 내용이 없음을 알림
    if (widget.user.surveyAnswers == null || widget.user.surveyAnswers!.isEmpty) {
      return const Center(child: Text("등록된 가치관 정보가 없습니다."));
    }

    return Column(
      children: [
        // [수정] 5개의 카테고리 탭으로 변경
        TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.pinkAccent,
          indicatorSize: TabBarIndicatorSize.tab, // [추가] 인디케이터가 탭 전체 너비를 차지하도록 함
          tabs: _surveyCategories.map((String category) => Tab(text: category)).toList(),
        ),
        // [수정] 각 탭에 해당하는 질문 목록을 보여주는 TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _surveyCategories.map((category) {
              // 해당 카테고리의 질문 리스트를 가져옴
              final questionsForCategory = _categorizedQuestions[category]!;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: questionsForCategory.length,
                itemBuilder: (context, index) {
                  final question = questionsForCategory[index];
                  final answerIndex = widget.user.surveyAnswers![question.id];

                  // 사용자가 답변하지 않았거나, 답변 인덱스가 유효하지 않으면 표시하지 않음
                  if (answerIndex == null || answerIndex >= question.answers.length) {
                    return SizedBox.shrink();
                  }

                  final answerText = question.answers[answerIndex].text;

                  // 질문과 답변을 보여주는 카드 위젯
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.questionText,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'A. $answerText',
                            style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
