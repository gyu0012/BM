// =================================================================
// =================================================================

// main_screen/pages/settings/edit_basic_info_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/settings/edit_basic_info_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../login/step_screens/area_selection_screen.dart';

class EditBasicInfoPage extends StatefulWidget {
  const EditBasicInfoPage({Key? key}) : super(key: key);

  @override
  _EditBasicInfoPageState createState() => _EditBasicInfoPageState();
}

class _EditBasicInfoPageState extends State<EditBasicInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _selfIntroductionController;
  String? _maritalStatus;
  String? _marriagePlanDetails;
  String? _residenceArea;
  String? _activityArea;
  int? _height;
  String? _bodyType;
  String? _religion;
  String? _smokingHabits;
  String? _drinkingHabits;
  String? _drinkingAmount;
  String? _mbti;

  final List<String> _maritalStatusOptions = ['미혼', '기혼(재혼)', '이혼/사별'];
  final List<String> _marriagePlanOptions = ['가급적 빨리', '1~2년 내', '3~4년 내', '결혼 생각 없음', '여유롭게 생각'];
  final List<String> _bodyTypeOptions = ['마른 편', '보통', '통통한 편', '근육질', '글래머'];
  final List<String> _religionOptions = ['무교', '기독교', '불교', '천주교', '기타'];
  final List<String> _smokingOptions = ['비흡연', '가끔 흡연 (연초)', '매일 흡연 (연초)', '전자담배 사용', '금연 중'];
  final List<String> _drinkingOptions = ['전혀 안 함', '가끔 사회적으로', '즐기는 편 (주 1-2회)', '자주 마심 (주 3회 이상)'];
  final List<String> _drinkingAmountOptions = ['못 마셔요/안 마셔요', '맥주 1~2잔', '소주 반 병', '소주 1병', '소주 1~2병', '소주 2병 이상'];
  final List<String> _mbtiOptions = ['ISTJ', 'ISFJ', 'INFJ', 'INTJ', 'ISTP', 'ISFP', 'INFP', 'INTP', 'ESTP', 'ESFP', 'ENFP', 'ENTP', 'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ', '잘 모름'];

  @override
  void initState() {
    super.initState();
    _selfIntroductionController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      final user = await authService.getUserProfile(userId);
      if (user != null && mounted) {
        setState(() {
          _selfIntroductionController.text = user.selfIntroduction ?? '';
          _maritalStatus = user.maritalStatus;
          _marriagePlanDetails = user.marriagePlanDetails;
          _residenceArea = user.residenceArea;
          _activityArea = user.activityArea;
          _height = user.height;
          _bodyType = user.bodyType;
          _religion = user.religion;
          _smokingHabits = user.smokingHabits;
          _drinkingHabits = user.drinkingHabits;
          _drinkingAmount = user.drinkingAmount;
          _mbti = user.mbti;
        });
      }
    }
  }

  @override
  void dispose() {
    _selfIntroductionController.dispose();
    super.dispose();
  }

  Future<void> _selectArea({required bool isResidence}) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => AreaSelectionScreen(
          title: isResidence ? '거주지역 선택' : '주요활동지역 선택',
        ),
      ),
    );
    if (result != null) {
      setState(() {
        if (isResidence) _residenceArea = result;
        else _activityArea = result;
      });
    }
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

    final Map<String, dynamic> dataToUpdate = {
      'selfIntroduction': _selfIntroductionController.text.trim(),
      'maritalStatus': _maritalStatus,
      'marriagePlanDetails': _marriagePlanDetails,
      'residenceArea': _residenceArea,
      'activityArea': _activityArea,
      'height': _height,
      'bodyType': _bodyType,
      'religion': _religion,
      'smokingHabits': _smokingHabits,
      'drinkingHabits': _drinkingHabits,
      'drinkingAmount': _drinkingAmount,
      'mbti': _mbti,
    };

    try {
      await authService.updateUserBasicProfile(userId, dataToUpdate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프로필 정보가 성공적으로 변경되었습니다.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
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
        title: Text('프로필 정보 변경'),
        actions: [ TextButton(onPressed: _isLoading ? null : _saveChanges, child: Text('저장')) ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _selfIntroductionController,
              decoration: InputDecoration(labelText: '자기소개', border: OutlineInputBorder(), alignLabelWithHint: true),
              maxLines: 5,
              maxLength: 500,
              validator: (value) => (value?.length ?? 0) < 10 ? '최소 10자 이상 입력해주세요.' : null,
            ),
            SizedBox(height: 16),
            _buildDropdownField('결혼 상태', _maritalStatusOptions, _maritalStatus, (val) => setState(() => _maritalStatus = val)),
            _buildDropdownField('결혼 계획', _marriagePlanOptions, _marriagePlanDetails, (val) => setState(() => _marriagePlanDetails = val)),
            _buildAreaSelector('거주 지역', _residenceArea, () => _selectArea(isResidence: true)),
            _buildAreaSelector('주요 활동 지역', _activityArea, () => _selectArea(isResidence: false)),
            _buildHeightSlider(),
            _buildDropdownField('체형', _bodyTypeOptions, _bodyType, (val) => setState(() => _bodyType = val)),
            _buildDropdownField('종교', _religionOptions, _religion, (val) => setState(() => _religion = val)),
            _buildDropdownField('흡연', _smokingOptions, _smokingHabits, (val) => setState(() => _smokingHabits = val)),
            _buildDropdownField('음주', _drinkingOptions, _drinkingHabits, (val) => setState(() => _drinkingHabits = val)),
            _buildDropdownField('주량', _drinkingAmountOptions, _drinkingAmount, (val) => setState(() => _drinkingAmount = val)),
            _buildDropdownField('MBTI', _mbtiOptions, _mbti, (val) => setState(() => _mbti = val)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: currentValue,
        items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? '$label을(를) 선택해주세요.' : null,
      ),
    );
  }

  Widget _buildAreaSelector(String label, String? value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value ?? '지역을 선택해주세요', style: TextStyle(fontSize: 16)),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('키: ${_height ?? 175} cm', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Slider(
            value: (_height ?? 175).toDouble(),
            min: 140, max: 200, divisions: 60,
            label: _height?.round().toString(),
            onChanged: (double value) => setState(() => _height = value.round()),
          ),
        ],
      ),
    );
  }
}