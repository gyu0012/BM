// =================================================================
// =================================================================

// login/step_screens/step2_core_profile_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step2_core_profile_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_profile_data.dart';
import 'area_selection_screen.dart'; // 새로 만든 지역 선택 페이지 import

class Step2CoreProfileScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Step2CoreProfileScreen({required this.userProfileData, required this.onNext, required this.onBack});

  @override
  _Step2CoreProfileScreenState createState() => _Step2CoreProfileScreenState();
}

class _Step2CoreProfileScreenState extends State<Step2CoreProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _maritalStatusOptions = ['미혼', '기혼(재혼)', '이혼/사별'];
  final List<String> _marriagePlanOptions = ['가급적 빨리', '1~2년 내', '3~4년 내', '결혼 생각 없음', '여유롭게 생각'];

  // 지역 선택 결과를 담을 상태 변수
  String? _residenceArea;
  String? _activityArea;

  @override
  void initState() {
    super.initState();
    _residenceArea = widget.userProfileData.residenceArea;
    _activityArea = widget.userProfileData.activityArea;
  }

  // 지역 선택 페이지로 이동하고 결과를 받아오는 함수
  Future<void> _selectArea({required bool isResidence}) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => AreaSelectionScreen(
          title: isResidence ? '거주지역 선택' : '주요활동지역 선택',
        ),
      ),
    );

    // 결과가 null이 아니면 상태 업데이트
    if (result != null) {
      setState(() {
        if (isResidence) {
          _residenceArea = result;
          widget.userProfileData.residenceArea = result;
        } else {
          _activityArea = result;
          widget.userProfileData.activityArea = result;
        }
      });
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
            Text('기본 프로필', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),
            _buildDropdownField('결혼 상태', _maritalStatusOptions, widget.userProfileData.maritalStatus, (val) => setState(() => widget.userProfileData.maritalStatus = val)),
            _buildDropdownField('결혼 계획', _marriagePlanOptions, widget.userProfileData.marriagePlanDetails, (val) => setState(() => widget.userProfileData.marriagePlanDetails = val)),

            // --- [수정] 거주지역/활동지역 입력 UI 변경 ---
            SizedBox(height: 8),
            _buildAreaSelector(
              label: '거주 지역',
              value: _residenceArea,
              onTap: () => _selectArea(isResidence: true),
            ),
            SizedBox(height: 8),
            _buildAreaSelector(
              label: '주요 활동 지역',
              value: _activityArea,
              onTap: () => _selectArea(isResidence: false),
            ),
            // --- 수정 끝 ---

            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // 지역 선택 여부 유효성 검사 추가
                if (_residenceArea == null || _activityArea == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('거주지역과 활동지역을 모두 선택해주세요.')),
                  );
                  return;
                }
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
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

  // 지역 선택 버튼 UI를 만드는 헬퍼 위젯
  Widget _buildAreaSelector({required String label, required String? value, required VoidCallback onTap}) {
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
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value ?? '지역을 선택해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: value == null ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.info_outline)),
        value: currentValue,
        items: options.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null || value.isEmpty ? '$label을(를) 선택해주세요.' : null,
      ),
    );
  }
}