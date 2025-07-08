// =================================================================
// =================================================================

// login/step_screens/step3_detailed_profile1_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step3_detailed_profile1_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';

class Step3DetailedProfile1Screen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3DetailedProfile1Screen({Key? key, required this.userProfileData, required this.onNext, required this.onBack}) : super(key: key);

  @override
  _Step3DetailedProfile1ScreenState createState() => _Step3DetailedProfile1ScreenState();
}

class _Step3DetailedProfile1ScreenState extends State<Step3DetailedProfile1Screen> {
  final _formKey = GlobalKey<FormState>();

  // [수정] 학력 선택지 확장
  final List<String> _educationOptions = [
    '고등학교',
    '전문대학',
    '지방 4년제',
    '수도권 4년제',
    '지방 국립대 2년제',
    '지방 국립대 4년제',
    '인서울 4년제',
    '인서울 상위 4년제',
    '대학원 석사',
    '대학원 박사',
    '해외 유학 (미국/영국/프랑스)',
    '해외 유학 (호주/캐나다/중국/일본)',
    '해외 유학 (그 외 국가)',
    '해외 대학원 석사 (미국/영국/프랑스)',
    '해외 대학원 석사 (호주/캐나다/중국/일본)',
    '해외 대학원 석사 (그 외 국가)',
    '해외 대학원 박사 (미국/영국/프랑스)',
    '해외 대학원 박사 (호주/캐나다/중국/일본)',
    '해외 대학원 박사 (그 외 국가)',
    '의대/치대/한의대/로스쿨',
    '기타'
  ];

  final List<String> _bodyTypeOptions = ['마른 편', '보통', '통통한 편', '근육질', '글래머'];

  late TextEditingController _schoolNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _jobTitleController;

  @override
  void initState() {
    super.initState();
    _schoolNameController = TextEditingController(text: widget.userProfileData.schoolName);
    _companyNameController = TextEditingController(text: widget.userProfileData.companyName);
    _jobTitleController = TextEditingController(text: widget.userProfileData.jobTitle);
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _companyNameController.dispose();
    _jobTitleController.dispose();
    super.dispose();
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
            Text('상세 프로필 (1/2)', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),
            _buildDropdownField('학력', _educationOptions, widget.userProfileData.educationLevel, (val) => setState(() => widget.userProfileData.educationLevel = val)),
            _buildTextFormField(_schoolNameController, '학교명', hint: "예) 한국대학교", icon: Icons.school_outlined),
            _buildTextFormField(_companyNameController, '직장명', hint: "예) (주)데이맨", icon: Icons.business_center_outlined),
            _buildTextFormField(_jobTitleController, '직급', hint: "예) 매니저, 팀장", icon: Icons.badge_outlined),
            _buildHeightSlider(),
            _buildDropdownField('체형', _bodyTypeOptions, widget.userProfileData.bodyType, (val) => setState(() => widget.userProfileData.bodyType = val)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.userProfileData.schoolName = _schoolNameController.text.trim();
                  widget.userProfileData.companyName = _companyNameController.text.trim();
                  widget.userProfileData.jobTitle = _jobTitleController.text.trim();
                  widget.onNext();
                }
              },
              child: Text('다음'),
            ),
            SizedBox(height: 10),
            TextButton(onPressed: widget.onBack, child: Text('이전단계로')),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('키: ${widget.userProfileData.height ?? "선택 안 함"} cm', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          Slider(
            value: (widget.userProfileData.height ?? 165).toDouble(),
            min: 120,
            max: 220,
            divisions: 100,
            label: (widget.userProfileData.height ?? 165).round().toString(),
            onChanged: (double value) {
              setState(() {
                widget.userProfileData.height = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.category_outlined)),
        value: currentValue,
        isExpanded: true,
        items: options.map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis)
        )).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? '$label을(를) 선택해주세요.' : null,
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {String? hint, IconData? icon, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: icon != null ? Icon(icon) : null),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label을(를) 입력해주세요.';
          }
          return null;
        },
      ),
    );
  }
}
