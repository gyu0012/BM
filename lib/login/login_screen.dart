// lib/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_flow_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- [UI 개선] ---
  // 색상 정의
  static const Color primaryColor = Color(0xFF6A4DFF); // 메인 보라색
  static const Color darkGreyColor = Color(0xFF3D405B); // 어두운 회색 (버튼)
  static const Color lightGreyColor = Color(0xFFF0F2F5); // 배경 회색
  static const Color textFieldBorderColor = Color(0xFFDCDCDC); // 텍스트 필드 테두리

  Future<void> _tryLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // AuthGate가 상태를 감지하므로 별도의 화면 이동 코드는 필요 없습니다.
      } on FirebaseAuthException catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 실패: ${e.message}')),
          );
        }
      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('알 수 없는 오류가 발생했습니다.')),
          );
        }
      } finally {
        if(mounted) setState(() { _isLoading = false; });
      }
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignUpFlowScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- [UI 개선] ---
      // 배경색을 이미지와 유사하게 변경
      backgroundColor: lightGreyColor,
      body: Center(
        child: SingleChildScrollView(
          // --- [UI 개선] ---
          // 좌우 패딩을 늘려 중앙 컨텐츠 영역을 만듬
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            // --- [UI 개선] ---
            // 웹이나 태블릿 등 넓은 화면에서 너무 넓어지지 않도록 최대 너비 제한
            constraints: BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- [UI 개선] ---
                  // 이미지의 육각형 로고 아이콘 구현
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor.withOpacity(0.8), primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // 육각형 모양을 만들기 위해 shape 속성 대신 클리핑을 사용할 수 있으나,
                      // 여기서는 간단하게 둥근 사각형으로 대체하여 유사한 느낌을 줍니다.
                      // 완벽한 육각형은 CustomClipper 등을 사용해야 합니다.
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.favorite_border, color: Colors.white, size: 45),
                  ),
                  SizedBox(height: 20),
                  // --- [UI 개선] ---
                  // 앱 이름 변경 및 스타일 적용
                  Text(
                    'Balance Match',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: darkGreyColor,
                    ),
                  ),
                  SizedBox(height: 40),
                  // --- [UI 개선] ---
                  // 이메일 입력 필드 스타일 변경
                  TextFormField(
                    controller: _emailController,
                    decoration: _buildInputDecoration('아이디(이메일주소)'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return '유효한 이메일을 입력해주세요.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  // --- [UI 개선] ---
                  // 비밀번호 입력 필드 스타일 변경
                  TextFormField(
                    controller: _passwordController,
                    decoration: _buildInputDecoration('비밀번호'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  // --- [UI 개선] ---
                  // 로그인 버튼 스타일 변경
                  _isLoading
                      ? Center(child: CircularProgressIndicator(color: primaryColor))
                      : ElevatedButton(
                    onPressed: _tryLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreyColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 16),
                  // --- [UI 개선] ---
                  // '아이디/비밀번호 찾기' 버튼 추가
                  TextButton(
                    onPressed: () { /* TODO: 아이디/비밀번호 찾기 로직 구현 */ },
                    child: Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 24),
                  // --- [UI 개선] ---
                  // 회원가입 버튼을 OutlinedButton으로 변경 및 스타일 적용
                  OutlinedButton(
                    onPressed: _navigateToSignUp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkGreyColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: textFieldBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('회원가입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 12),
                  // --- [UI 개선] ---
                  // '고객센터 연락하기' 버튼 추가
                  TextButton(
                    onPressed: () { /* TODO: 고객센터 로직 구현 */ },
                    child: Text(
                      '고객센터 연락하기',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- [UI 개선] ---
  // TextFormField의 Decoration을 생성하는 헬퍼 함수
  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      // 아이콘 제거
      // prefixIcon: Icon(iconData, color: Colors.grey[500]),
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
