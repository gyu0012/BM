// lib/login/step_screens/step1_authentication_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile_data.dart';
import '../../services/auth_service.dart'; // AuthService 사용을 위해 import

class Step1AuthenticationScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Step1AuthenticationScreen({required this.userProfileData, required this.onNext, required this.onBack});

  @override
  _Step1AuthenticationScreenState createState() => _Step1AuthenticationScreenState();
}

class _Step1AuthenticationScreenState extends State<Step1AuthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _otpController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;

  bool _otpSent = false;
  bool _phoneCheckLoading = false;

  bool _isEmailAvailable = false; // 이메일 중복 확인 결과
  bool _emailCheckLoading = false; // 이메일 중복 확인 로딩 상태
  String? _lastCheckedEmail; // 마지막으로 확인한 이메일

  bool _isNicknameAvailable = false;
  bool _nicknameCheckLoading = false;
  String? _lastCheckedNickname;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.userProfileData.phoneNumber);
    _otpController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nicknameController = TextEditingController(text: widget.userProfileData.nickname);
    _emailController = TextEditingController(text: widget.userProfileData.email);

    // 닉네임 변경 감지 리스너
    _nicknameController.addListener(() {
      if (_lastCheckedNickname != _nicknameController.text) {
        if (mounted) setState(() => _isNicknameAvailable = false);
      }
    });

    // 이메일 변경 감지 리스너
    _emailController.addListener(() {
      if (_lastCheckedEmail != _emailController.text) {
        if (mounted) setState(() => _isEmailAvailable = false);
      }
    });
  }

  // --- [수정된 함수] ---
  Future<void> _checkPhoneAndSendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty || !RegExp(r'^010-?\d{3,4}-?\d{4}$').hasMatch(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('올바른 휴대폰 번호를 입력해주세요.')));
      return;
    }

    setState(() { _phoneCheckLoading = true; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // authService.checkPhoneNumberExists는 번호가 존재하면(중복이면) true를 반환합니다.
      final isAlreadyInUse = await authService.checkPhoneNumberExists(phoneNumber);

      if (!mounted) return;

      // 로직을 올바르게 수정합니다.
      if (isAlreadyInUse) {
        // 이미 사용 중인 번호일 경우, 에러 메시지를 보여줍니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 가입된 휴대폰 번호입니다.'), backgroundColor: Colors.red),
        );
      } else {
        // 사용 가능한 번호일 경우, OTP를 전송합니다.
        setState(() { _otpSent = true; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('인증번호가 발송되었습니다. (테스트 모드: 123456 입력)')));
        // TODO: 실제 SMS 인증 로직을 여기에 구현하세요.
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('휴대폰 번호 확인 중 오류가 발생했습니다.')));
    } finally {
      if (mounted) setState(() { _phoneCheckLoading = false; });
    }
  }
  // --- [수정 완료] ---

  Future<void> _checkEmailDuplicate() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 이메일 형식을 입력해주세요.')),
      );
      return;
    }

    setState(() { _emailCheckLoading = true; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // authService.checkEmailExists는 이메일이 존재하면 true를 반환합니다.
      final isAlreadyInUse = await authService.checkEmailExists(email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAlreadyInUse ? '이미 가입된 이메일입니다.' : '사용 가능한 이메일입니다.'),
            backgroundColor: isAlreadyInUse ? Colors.red : Colors.green,
          ),
        );
        setState(() {
          // 사용 가능 여부는 중복되지 않았을 때 true입니다.
          _isEmailAvailable = !isAlreadyInUse;
          _lastCheckedEmail = email;
        });
      }

    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 확인 중 오류가 발생했습니다.')));
    } finally {
      if(mounted) setState(() { _emailCheckLoading = false; });
    }
  }

  Future<void> _checkNicknameDuplicate() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || nickname.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임은 2자 이상 입력해주세요.')),
      );
      return;
    }

    setState(() { _nicknameCheckLoading = true; });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isAlreadyInUse = await authService.checkNicknameExists(nickname);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAlreadyInUse ? '이미 사용 중인 닉네임입니다.' : '사용 가능한 닉네임입니다.'),
            backgroundColor: isAlreadyInUse ? Colors.red : Colors.green,
          ),
        );
        setState(() {
          _isNicknameAvailable = !isAlreadyInUse;
          _lastCheckedNickname = nickname;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('닉네임 확인 중 오류가 발생했습니다.')));
    } finally {
      if (mounted) setState(() { _nicknameCheckLoading = false; });
    }
  }

  void _submitStep() {
    if (!_isEmailAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이메일 중복 확인을 해주세요.')));
      return;
    }
    if (!_isNicknameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('닉네임 중복 확인을 해주세요.')));
      return;
    }
    // TODO: OTP 인증 성공 여부 확인 로직 추가 필요 (_otpSent는 전송 여부만 확인)

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (isFormValid) {
      _formKey.currentState!.save();
      widget.userProfileData.phoneNumber = _phoneController.text.trim();
      widget.userProfileData.password = _passwordController.text.trim();
      widget.userProfileData.nickname = _nicknameController.text.trim();
      widget.userProfileData.email = _emailController.text.trim();
      widget.onNext();
    } else {
      if (_passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text != _confirmPasswordController.text) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호가 일치하지 않아 초기화됩니다. 다시 입력해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
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
            Text('계정 정보 입력', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '휴대폰 번호',
                hintText: "010-1234-5678",
                prefixIcon: Icon(Icons.phone_iphone),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _phoneCheckLoading
                      ? Transform.scale(scale: 0.6, child: CircularProgressIndicator(strokeWidth: 3))
                      : TextButton(
                    onPressed: _otpSent ? null : _checkPhoneAndSendOtp,
                    child: Text(_otpSent ? '재전송' : '인증받기'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: _otpSent ? Colors.grey.shade300 : Colors.pink.shade50
                    ),
                  ),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) return '휴대폰 번호를 입력해주세요.';
                if (!RegExp(r'^010-?\d{3,4}-?\d{4}$').hasMatch(value)) return '올바른 휴대폰 번호 형식이 아닙니다.';
                return null;
              },
            ),
            if (_otpSent) ...[
              SizedBox(height: 16),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(labelText: '인증번호 입력 (6자리)', prefixIcon: Icon(Icons.verified_user_outlined)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return '인증번호를 입력해주세요.';
                  if (value.length != 6) return '6자리 인증번호를 입력해주세요.';
                  if (value != '123456') return '인증번호가 올바르지 않습니다.'; // 테스트용 검증
                  return null;
                },
              ),
            ],
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일 (필수)',
                prefixIcon: Icon(Icons.email_outlined),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _emailCheckLoading
                      ? Transform.scale(scale: 0.6, child: CircularProgressIndicator(strokeWidth: 3))
                      : TextButton(
                    onPressed: _checkEmailDuplicate,
                    child: Text('중복 확인'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.pink.shade50
                    ),
                  ),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                if (!value.contains('@') || !value.contains('.')) return '유효한 이메일 형식이 아닙니다.';
                if (!_isEmailAvailable) return '이메일 중복 확인이 필요합니다.';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호 (6자 이상)', prefixIcon: Icon(Icons.lock_outline)),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: '비밀번호 확인', prefixIcon: Icon(Icons.lock_person_outlined)),
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) return '비밀번호가 일치하지 않습니다.';
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임 (2~10자)',
                prefixIcon: Icon(Icons.person_outline),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _nicknameCheckLoading
                      ? Transform.scale(scale: 0.6, child: CircularProgressIndicator(strokeWidth: 3))
                      : TextButton(
                    onPressed: _checkNicknameDuplicate,
                    child: Text('중복 확인'),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.pink.shade50
                    ),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '닉네임을 입력해주세요.';
                if (value.length < 2 || value.length > 10) return '닉네임은 2~10자 사이로 입력해주세요.';
                if (!_isNicknameAvailable) return '닉네임 중복 확인이 필요합니다.';
                return null;
              },
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitStep,
              child: Text('다음'),
            ),
            SizedBox(height: 10),
            TextButton(onPressed: widget.onBack, child: Text('이전단계로')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}