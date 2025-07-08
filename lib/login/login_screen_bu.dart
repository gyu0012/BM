// login/login_screen.dart (UPDATED)

// 경로: lib/login/login_screen.dart

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



  Future<void> _tryLogin() async {

    if (_formKey.currentState!.validate()) {

      setState(() { _isLoading = true; });

      try {

        final authService = Provider.of<AuthService>(context, listen: false);

        await authService.signInWithEmailPassword(

          _emailController.text.trim(),

          _passwordController.text.trim(),

        );

// --- [수정된 부분] ---

// 로그인 성공 시 별도의 화면 이동 로직이 필요 없음.

// AuthGate가 인증 상태 변경을 감지하고 자동으로 MainScreen으로 전환합니다.



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

      body: Center(

        child: SingleChildScrollView(

          padding: EdgeInsets.all(32.0),

          child: Form(

            key: _formKey,

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: <Widget>[

                Icon(Icons.favorite, size: 80, color: Colors.pinkAccent),

                SizedBox(height: 16),

                Text('BalanceMatch', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),

                SizedBox(height: 8),

                Text('당신에게 꼭 맞는 인연을 찾아보세요', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),

                SizedBox(height: 48),

                TextFormField(

                  controller: _emailController,

                  decoration: InputDecoration(labelText: '이메일', prefixIcon: Icon(Icons.email_outlined)),

                  validator: (value) {

                    if (value == null || value.isEmpty || !value.contains('@')) {

                      return '유효한 이메일을 입력해주세요.';

                    }

                    return null;

                  },

                  keyboardType: TextInputType.emailAddress,

                ),

                SizedBox(height: 16),

                TextFormField(

                  controller: _passwordController,

                  decoration: InputDecoration(labelText: '비밀번호', prefixIcon: Icon(Icons.lock_outline)),

                  obscureText: true,

                  validator: (value) {

                    if (value == null || value.isEmpty) {

                      return '비밀번호를 입력해주세요.';

                    }

                    return null;

                  },

                ),

                SizedBox(height: 24),

                _isLoading

                    ? Center(child: CircularProgressIndicator())

                    : ElevatedButton(onPressed: _tryLogin, child: Text('로그인')),

                SizedBox(height: 16),

                Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Text('아직 회원이 아니신가요?'),

                    TextButton(onPressed: _navigateToSignUp, child: Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold))),

                  ],

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }



  @override

  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();

  }

}