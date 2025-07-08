import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import 'package:balancematch/login/login_screen.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({Key? key}) : super(key: key);

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isAgreed = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('안내 사항을 확인하고 탈퇴에 동의해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.deleteAccount(_passwordController.text);

      // [수정] 팝업에서 '확인'이 눌렸는지 결과를 기다립니다.
      final bool? confirmed = await _showSuccessDialog();

      // [수정] 팝업이 닫히고 '확인'이 눌렸을 때만 로그아웃 및 화면 이동을 실행합니다.
      if (confirmed == true && mounted) {
        // 이미 deleteAccount에서 로그아웃 처리가 되므로, 여기서는 화면 전환만 합니다.
        // (AuthGate가 상태를 감지하여 자동으로 로그인 화면으로 보낼 수도 있습니다)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // [수정] Future<bool?>를 반환하도록 변경
  Future<bool?> _showSuccessDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('탈퇴 완료'),
          content: const Text('회원 탈퇴가 완료되었습니다.\n이용해주셔서 감사합니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              // [수정] 버튼을 누르면 true를 반환하며 팝업을 닫습니다.
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원탈퇴'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('회원탈퇴 안내', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildInfoItem(Icons.error_outline, '재가입 불가', '탈퇴 후 30일 동안 동일한 정보로 재가입이 불가능합니다.'),
              _buildInfoItem(Icons.replay_circle_filled, '복구 불가', '모든 프로필 정보, 매칭 기록, 대화 내용이 영구적으로 삭제되며 복구할 수 없습니다.'),
              _buildInfoItem(Icons.credit_card_off, '재화 환불 어려움', '보유하신 재화(알파)는 자동으로 소멸되며, 환불 규정에 따라 환불이 어려울 수 있습니다.'),
              _buildInfoItem(Icons.shield_outlined, '개인정보 보관', '전자상거래법 등 관련 법령에 따라 일부 정보는 3년간 보관 후 완전히 파기됩니다.'),
              _buildInfoItem(Icons.contact_support_outlined, '고객센터', '문의사항은 고객센터(support@balancematch.com)로 연락주세요.'),
              const Divider(height: 48),
              const Text('본인 확인을 위해 비밀번호를 입력해주세요.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) => value!.isEmpty ? '비밀번호를 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text('위 안내 사항을 모두 확인했으며, 탈퇴에 동의합니다.'),
                value: _isAgreed,
                onChanged: (bool? value) => setState(() => _isAgreed = value!),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('탈퇴하기', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
