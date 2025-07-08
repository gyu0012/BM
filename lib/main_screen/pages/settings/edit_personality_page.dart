// =================================================================
// =================================================================

// main_screen/pages/settings/edit_personality_page.dart (UPDATED)
// 경로: lib/main_screen/pages/settings/edit_personality_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class EditPersonalityPage extends StatefulWidget {
  const EditPersonalityPage({Key? key}) : super(key: key);

  @override
  _EditPersonalityPageState createState() => _EditPersonalityPageState();
}

class _EditPersonalityPageState extends State<EditPersonalityPage> {
  late Future<UserModel?> _userProfileFuture;
  bool _isLoading = false;

  List<String> _selectedPersonality = [];
  List<String> _selectedHobbies = [];
  List<String> _selectedInterests = [];

  final List<String> _allPersonalityTraits = ['예의바른', '긍정적', '잘웃는', '솔직한', '다정한', '배려심', '털털', '장난', '애교', '유머', '섬세', '수줍은', '낙천적', '활발한', '감성적', '친절한', '엉뚱한', '성실한'];
  final List<String> _allHobbies = ['영화', '드라마', '음악', '맛집', '카페', '노래', '게임', '술', '요리', '패션', '공연', '사진', '쇼핑', '웹툰', '예술', '여행', '애니', '인테리어', '악기', '뷰티', '미술', '춤', '드라이브', '산책', '헬스', '자전거', '골프', '캠핑', '수영', '야구', '테니스', '크로스핏', '볼링', '축구', '배드민턴', '등산', '클라이밍', '러닝', '낚시', '필라테스', '요가', '공부', '독서', '어학', '재테크', '봉사'];
  final List<String> _allInterests = ['영화', '드라마', '음악', '맛집', '카페', '노래', '게임', '술', '요리', '패션', '공연', '사진', '쇼핑', '웹툰', '예술', '여행', '애니', '인테리어', '악기', '뷰티', '미술', '춤', '드라이브', '산책', '헬스', '자전거', '골프', '캠핑', '수영', '야구', '테니스', '크로스핏', '볼링', '축구', '배드민턴', '등산', '클라이밍', '러닝', '낚시', '필라테스', '요가', '공부', '독서', '어학', '재테크', '봉사'];

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
            _selectedPersonality = List.from(user.personalityTraits ?? []);
            _selectedHobbies = List.from(user.hobbies ?? []);
            _selectedInterests = List.from(user.interests ?? []);
          });
        }
      });
    } else {
      _userProfileFuture = Future.value(null);
    }
  }

  Future<void> _saveChanges() async {
    if (_selectedPersonality.isEmpty || _selectedHobbies.isEmpty || _selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('각 항목을 1개 이상 선택해주세요.')));
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
      await authService.updateUserPersonalityAndInterests(
        userId,
        personalityTraits: _selectedPersonality,
        hobbies: _selectedHobbies,
        interests: _selectedInterests,
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
        title: Text('성격/취미/관심사 변경'),
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                _buildChipSelector('성격 (최대 3개)', _allPersonalityTraits, _selectedPersonality, 3),
                SizedBox(height: 24),
                _buildChipSelector('취미 (최대 3개)', _allHobbies, _selectedHobbies, 3),
                SizedBox(height: 24),
                _buildChipSelector('관심사 (최대 3개)', _allInterests, _selectedInterests, 3),
              ],
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
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: allOptions.map((option) {
              final bool isSelected = selectedOptions.contains(option);
              return FilterChip(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
}
