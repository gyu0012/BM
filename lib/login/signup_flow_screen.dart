// =================================================================
// =================================================================

// login/signup_flow_screen.dart (UPDATED)
// 경로: lib/login/signup_flow_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_data.dart';
import '../services/auth_service.dart';
import '../services/ability_score_service.dart';
import '../main_screen/main_screen.dart';

// Step screens import
import 'step_screens/step0_terms_agreement_screen.dart';
import 'step_screens/step1a_gender_selection_screen.dart';
import 'step_screens/step1_authentication_screen.dart';
import 'step_screens/step2_core_profile_screen.dart';
import 'step_screens/step3_detailed_profile1_screen.dart';
import 'step_screens/step4_detailed_profile2_screen.dart';
import 'step_screens/step5_personality_interests_screen.dart';
import 'step_screens/step6_photo_upload_screen.dart';
import 'step_screens/step7_financial_profile_screen.dart';
import 'step_screens/step8_parents_financial_profile_screen.dart';
import 'step_screens/step9_values_lifestyle_screen.dart'; // [수정] 생활관/가치관
import 'step_screens/step10_survey_screen.dart'; // [추가] 상세 설문
import 'step_screens/step11_completion_screen.dart'; // [수정] 완료


class SignUpFlowScreen extends StatefulWidget {
  @override
  _SignUpFlowScreenState createState() => _SignUpFlowScreenState();
}

class _SignUpFlowScreenState extends State<SignUpFlowScreen> {
  final PageController _pageController = PageController();
  final UserProfileData _userProfileData = UserProfileData();
  int _currentPage = 0;
  bool _isLoading = false;

  late List<Widget> _steps;

  // [수정] 단계 제목 리스트 변경
  final List<String> _stepTitles = [
    "이용약관 동의", // 0
    "성별 선택", // 1
    "계정 정보 입력", // 2
    "기본 프로필", // 3
    "상세 프로필 1", // 4
    "상세 프로필 2", // 5
    "성격 및 자기소개", // 6
    "사진 등록", // 7
    "나의 경제 정보", // 8
    "부모님 경제 정보", // 9
    "가치관 및 생활관", // 10
    "가치관 설문", // 11
    "가입 완료", // 12
  ];

  @override
  void initState() {
    super.initState();
    // [수정] 단계 리스트 변경
    _steps = [
      Step0TermsAgreementScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1)),
      Step1aGenderSelectionScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step1AuthenticationScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step2CoreProfileScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step3DetailedProfile1Screen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step4DetailedProfile2Screen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step5PersonalityInterestsScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step6PhotoUploadScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step7FinancialProfileScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step8ParentsFinancialProfileScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step9ValuesLifestyleScreen(userProfileData: _userProfileData, onNext: () => _navigateToPage(_currentPage + 1), onBack: () => _navigateToPage(_currentPage - 1)),
      Step10SurveyScreen(userProfileData: _userProfileData, onNext: _completeRegistration, onBack: () => _navigateToPage(_currentPage - 1)),
      Step11CompletionScreen(userProfileData: _userProfileData),
    ];
  }

  void _navigateToPage(int page) {
    if (page >= 0 && page < _steps.length) {
      if (page < _steps.length - 1) {
        _pageController.animateToPage(
          page,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (page == _steps.length - 1) {
        if (_currentPage == _steps.length - 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => _steps.last),
          );
        }
      }
    }
  }

  Future<void> _completeRegistration() async {
    setState(() { _isLoading = true; });

    try {
      final scoreService = AbilityScoreService();
      _userProfileData.abilityScores = scoreService.calculateScores(_userProfileData);

      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signUpWithEmailPassword(
        _userProfileData.email,
        _userProfileData.password,
        _userProfileData,
      );

      if (mounted) {
        _navigateToPage(_steps.length - 1);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 실패: ${e.message}')));
        setState(() { _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('알 수 없는 오류 발생: $e')));
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = _currentPage < _stepTitles.length -1 ? _stepTitles[_currentPage] : "가입 완료";
    String progressText = _currentPage < _stepTitles.length -1 ? '(${_currentPage + 1}/${_steps.length-1})' : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('$appBarTitle $progressText'),
        leading: _currentPage > 0 && _currentPage < _steps.length -1
            ? IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => _navigateToPage(_currentPage - 1),
        )
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: _steps.sublist(0, _steps.length -1),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}