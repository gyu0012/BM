// =================================================================
// =================================================================

// main_screen/pages/settings/edit_survey_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/settings/edit_survey_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../models/detailed_survey_data.dart';
import '../../../services/auth_service.dart';

class EditSurveyPage extends StatefulWidget {
  const EditSurveyPage({Key? key}) : super(key: key);

  @override
  _EditSurveyPageState createState() => _EditSurveyPageState();
}

class _EditSurveyPageState extends State<EditSurveyPage> with SingleTickerProviderStateMixin {
  late Future<UserModel?> _userProfileFuture;
  late TabController _tabController;
  final List<String> _categories = ['배경', '일상', '만남', '연애', '결혼'];
  late Map<String, List<SurveyQuestion>> _categorizedQuestions;
  bool _isLoading = false;

  Map<String, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _categorizedQuestions = {};
    for (var category in _categories) {
      _categorizedQuestions[category] = DetailedSurveyRepository.allQuestions.where((q) => q.category == category).toList();
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      _userProfileFuture = authService.getUserProfile(userId);
      _userProfileFuture.then((user) {
        if (user != null && mounted) {
          setState(() {
            _selectedAnswers = Map.from(user.surveyAnswers ?? {});
          });
        }
      });
    } else {
      _userProfileFuture = Future.value(null);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_selectedAnswers.length < DetailedSurveyRepository.allQuestions.length) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 설문 항목에 답변해주세요.')));
      return;
    }

    setState(() { _isLoading = true; });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사용자 정보가 없습니다.')));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await authService.updateUserSurvey(userId, _selectedAnswers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('가치관 설문이 성공적으로 변경되었습니다.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('변경 중 오류가 발생했습니다.')));
      }
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가치관 설문 변경'),
        actions: [
          TextButton(onPressed: _isLoading ? null : _saveChanges, child: Text('저장'))
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('프로필 정보를 불러올 수 없습니다.'));
          }

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
            ],
          );
        },
      ),
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
          Text(questionData.questionText, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              hintText: '답변을 선택해주세요',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            isExpanded: true,
            value: _selectedAnswers[questionData.id],
            items: questionData.answers.asMap().entries.map((entry) {
              return DropdownMenuItem<int>(value: entry.key, child: Text(entry.value.text, overflow: TextOverflow.ellipsis));
            }).toList(),
            onChanged: (int? selectedAnswerIndex) {
              if (selectedAnswerIndex != null) {
                setState(() {
                  _selectedAnswers[questionData.id] = selectedAnswerIndex;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
