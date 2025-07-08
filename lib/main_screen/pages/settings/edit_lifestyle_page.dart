// =================================================================
// =================================================================

// main_screen/pages/settings/edit_lifestyle_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/settings/edit_lifestyle_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class EditLifestylePage extends StatefulWidget {
  const EditLifestylePage({Key? key}) : super(key: key);

  @override
  _EditLifestylePageState createState() => _EditLifestylePageState();
}

class _EditLifestylePageState extends State<EditLifestylePage> {
  late Future<UserModel?> _userProfileFuture;
  bool _isLoading = false;

  List<String> _selectedCoreValues = [];
  Map<String, String> _selectedLifestyleChoices = {};

  final _formKey = GlobalKey<FormState>();

  final List<String> _allCoreValues = ['가족', '사랑', '성장', '안정', '행복', '신뢰', '건강', '자유', '정의', '성공', '헌신', '창의', '유머', '긍정', '배려', '예의', '평화', '성실', '열정', '책임감'];
  final Map<String, List<String>> _lifestyleQuestions = {
    '선호하는 연락 빈도는?': ['필요할 때만', '하루 2~3번, 안부 물을 정도', '틈틈이 자주 (일상 공유)', '정해진 시간에 규칙적으로 (아침/저녁 등)', '딱히 정해두진 않음'],
    '만났을 때 선호하는 장소는?': ['부담 없이 카페', '간단한 식사', '분위기 좋은 레스토랑/술집', '함께 즐길 거리가 있는 곳 (보드게임, 공원 산책 등)', '데이트처럼 (맛집, 카페, 영화 등 풀코스)'],
    '선호하는 데이트 유형은?': ['맛집 탐방', '영화/공연/전시 관람', '액티비티 (스포츠, 방탈출 등)', '조용한 카페에서 대화', '함께하는 취미생활 (운동, 쇼핑, 드라이브 등)'],
    '다퉜을 때 나는 어떻게 화해하는 편?': ['그 자리에서 바로 대화로 풀어야 함', '서로 감정이 가라앉은 뒤 차분하게 대화', '먼저 사과하고 넘어가는 편', '자연스럽게 아무 일 없었다는 듯이 풀림', '맛있는 음식을 먹으면서 화해'],
    '데이트 비용은 어떻게 하는 게 편해?': ['번갈아 가면서 자연스럽게 내는 편', '공동의 목표! 데이트 통장을 만들어서 사용', '각자 쓴 비용은 확실하게 더치페이', '그때그때 상황에 따라 여유 있는 사람이 내기', '한 사람이 주도적으로 내는 게 편함']
  };

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      _userProfileFuture = authService.getUserProfile(userId);
      _userProfileFuture.then((user) {
        if (user != null && mounted) {
          setState(() {
            _selectedCoreValues = List.from(user.coreValues ?? []);
            _selectedLifestyleChoices = Map.from(user.lifestyleChoices ?? {});
          });
        }
      });
    } else {
      _userProfileFuture = Future.value(null);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 생활관 질문에 답변해주세요.')));
      return;
    }
    if (_selectedCoreValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('핵심 가치관을 1개 이상 선택해주세요.')));
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
      await authService.updateUserLifestyle(
        userId: userId,
        coreValues: _selectedCoreValues,
        lifestyleChoices: _selectedLifestyleChoices,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('성공적으로 변경되었습니다.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('변경 중 오류가 발생했습니다.')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('생활관 변경'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: Text('저장'),
          )
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

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildChipSelector('나의 핵심 가치관 (최대 3개)', _allCoreValues, _selectedCoreValues, 3),
                  SizedBox(height: 24),
                  Text('나의 생활관', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ..._lifestyleQuestions.entries.map((entry) {
                    return _buildLifestyleQuestion(entry.key, entry.value, _selectedLifestyleChoices[entry.key], (val) {
                      setState(() {
                        _selectedLifestyleChoices[entry.key] = val!;
                      });
                    });
                  }).toList(),
                ],
              ),
            ),
          );
        },
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
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: allOptions.map((option) {
              final bool isSelected = selectedOptions.contains(option);
              return FilterChip(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                label: Text(option),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                selected: isSelected,
                showCheckmark: false,
                selectedColor: Colors.pinkAccent,
                backgroundColor: Colors.grey.shade200,
                shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.pinkAccent : Colors.grey.shade300, width: 1.0)),
                onSelected: (bool selected) {
                  setState(() {
                    if (isSelected) {
                      selectedOptions.remove(option);
                    } else {
                      if (selectedOptions.length < maxSelection) {
                        selectedOptions.add(option);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('최대 $maxSelection개까지 선택할 수 있습니다.')));
                      }
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
