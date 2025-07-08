// =================================================================
// =================================================================

// main_screen/pages/settings/edit_ability_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/settings/edit_ability_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class EditAbilityPage extends StatefulWidget {
  const EditAbilityPage({Key? key}) : super(key: key);

  @override
  _EditAbilityPageState createState() => _EditAbilityPageState();
}

class _EditAbilityPageState extends State<EditAbilityPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _educationLevel;
  late TextEditingController _schoolNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _jobTitleController;

  final List<String> _educationOptions = [
    '고등학교', '전문대학', '지방 4년제', '수도권 4년제',
    '지방 국립대 2년제', '지방 국립대 4년제', '인서울 4년제', '인서울 상위 4년제',
    '대학원 석사', '대학원 박사', '해외 유학 (미국/영국/프랑스)',
    '해외 유학 (호주/캐나다/중국/일본)', '해외 유학 (그 외 국가)',
    '해외 대학원 석사 (미국/영국/프랑스)', '해외 대학원 석사 (호주/캐나다/중국/일본)',
    '해외 대학원 석사 (그 외 국가)', '해외 대학원 박사 (미국/영국/프랑스)',
    '해외 대학원 박사 (호주/캐나다/중국/일본)', '해외 대학원 박사 (그 외 국가)',
    '의대/치대/한의대/로스쿨', '기타'
  ];

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController();
    _companyNameController = TextEditingController();
    _jobTitleController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      final user = await authService.getUserProfile(userId);
      if (user != null && mounted) {
        setState(() {
          _educationLevel = user.educationLevel;
          _schoolNameController.text = user.schoolName ?? '';
          _companyNameController.text = user.companyName ?? '';
          _jobTitleController.text = user.jobTitle ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _companyNameController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사용자 정보가 없습니다.')));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await authService.updateUserAbility(
          userId: userId,
          educationLevel: _educationLevel!,
          schoolName: _schoolNameController.text.trim(),
          companyName: _companyNameController.text.trim(),
          jobTitle: _jobTitleController.text.trim()
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('정보가 성공적으로 변경되었습니다.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('정보 변경 중 오류가 발생했습니다.')));
      }
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('학력 및 직업 변경'),
        actions: [
          TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: Text('저장')
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            _buildDropdownField('학력', _educationOptions, _educationLevel, (val) => setState(() => _educationLevel = val)),
            SizedBox(height: 16),
            _buildTextFormField(_schoolNameController, '학교명'),
            SizedBox(height: 16),
            _buildTextFormField(_companyNameController, '직장명'),
            SizedBox(height: 16),
            _buildTextFormField(_jobTitleController, '직급'),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      value: currentValue,
      isExpanded: true,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? '$label을(를) 선택해주세요.' : null,
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$label을(를) 입력해주세요.';
        }
        return null;
      },
    );
  }
}
