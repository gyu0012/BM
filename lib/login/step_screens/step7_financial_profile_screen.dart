// =================================================================
// =================================================================

// login/step_screens/step7_financial_profile_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step7_financial_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile_data.dart';

class Step7FinancialProfileScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step7FinancialProfileScreen({Key? key, required this.userProfileData, required this.onNext, required this.onBack}) : super(key: key);

  @override
  _Step7FinancialProfileScreenState createState() => _Step7FinancialProfileScreenState();
}

class _Step7FinancialProfileScreenState extends State<Step7FinancialProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _incomeEokController = TextEditingController();
  final TextEditingController _incomeCheonController = TextEditingController();
  final TextEditingController _incomeBaekController = TextEditingController();
  final TextEditingController _incomeSipController = TextEditingController();

  final TextEditingController _assetEokController = TextEditingController();
  final TextEditingController _assetCheonController = TextEditingController();
  final TextEditingController _assetBaekController = TextEditingController();
  final TextEditingController _assetSipController = TextEditingController();

  late TextEditingController _descriptionController;

  final List<String> _realEstateOptions = ['미보유', '5억원 미만', '5억원 이상 ~ 10억원 미만', '10억원 이상 ~ 15억원 미만', '15억원 이상 ~ 30억원 미만', '30억원 이상'];
  final List<String> _carOptions = ['미보유', '1천만원 미만', '1천만원 이상 ~ 2천만원 미만', '2천만원 이상 ~ 3천만원 미만', '3천만원 이상 ~ 5천만원 미만', '5천만원 이상 ~ 8천만원 미만', '8천만원 이상 ~ 1억 5천만원 미만', '1억 5천만원 이상'];
  final List<String> _debtOptions = ['없음', '5천만원 미만', '5천만원 ~ 1억원', '1억원 ~ 3억원', '3억원 ~ 5억원', '5억원 이상', '비공개'];


  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.userProfileData.financialDescription);

    _initializeUnitControllers(widget.userProfileData.annualIncome, _incomeEokController, _incomeCheonController, _incomeBaekController, _incomeSipController);
    _initializeUnitControllers(widget.userProfileData.totalAssets, _assetEokController, _assetCheonController, _assetBaekController, _assetSipController);
  }

  void _initializeUnitControllers(int? totalAmount, TextEditingController e, TextEditingController c, TextEditingController b, TextEditingController s) {
    if (totalAmount != null) {
      e.text = (totalAmount ~/ 10000).toString();
      c.text = ((totalAmount % 10000) ~/ 1000).toString();
      b.text = ((totalAmount % 1000) ~/ 100).toString();
      s.text = ((totalAmount % 100) ~/ 10).toString();
    }
  }

  @override
  void dispose() {
    _incomeEokController.dispose();
    _incomeCheonController.dispose();
    _incomeBaekController.dispose();
    _incomeSipController.dispose();
    _assetEokController.dispose();
    _assetCheonController.dispose();
    _assetBaekController.dispose();
    _assetSipController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitAndContinue() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.userProfileData.annualIncome = _calculateAmountFromControllers(_incomeEokController, _incomeCheonController, _incomeBaekController, _incomeSipController);
      widget.userProfileData.totalAssets = _calculateAmountFromControllers(_assetEokController, _assetCheonController, _assetBaekController, _assetSipController);

      widget.userProfileData.financialDescription = _descriptionController.text.trim();
      widget.onNext();
    }
  }

  int _calculateAmountFromControllers(TextEditingController e, TextEditingController c, TextEditingController b, TextEditingController s) {
    final eok = int.tryParse(e.text) ?? 0;
    final cheon = int.tryParse(c.text) ?? 0;
    final baek = int.tryParse(b.text) ?? 0;
    final sip = int.tryParse(s.text) ?? 0;
    return (eok * 10000) + (cheon * 1000) + (baek * 100) + (sip * 10);
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
            Text('나의 경제 정보', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
            SizedBox(height: 30),

            _buildUnitInput('연소득', _incomeEokController, _incomeCheonController, _incomeBaekController, _incomeSipController),
            SizedBox(height: 16),
            _buildUnitInput('자산 (부채 제외)', _assetEokController, _assetCheonController, _assetBaekController, _assetSipController),

            _buildDropdownField('부동산', _realEstateOptions, widget.userProfileData.realEstateValue, (val) => setState(() => widget.userProfileData.realEstateValue = val)),
            _buildDropdownField('자동차', _carOptions, widget.userProfileData.carValue, (val) => setState(() => widget.userProfileData.carValue = val)),
            // _buildDropdownField('부채', _debtOptions, widget.userProfileData.debt, (val) => setState(() => widget.userProfileData.debt = val), optional: true),

            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '경제력 설명 (선택)',
                hintText: '본인의 경제 상황에 대해 자유롭게 설명해주세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLength: 100,
              maxLines: 3,
            ),
            SizedBox(height: 40),
            ElevatedButton(onPressed: _submitAndContinue, child: Text('다음')),
            SizedBox(height: 10),
            TextButton(onPressed: widget.onBack, child: Text('이전단계로')),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitInput(String label, TextEditingController e, TextEditingController c, TextEditingController b, TextEditingController s) {
    Widget unitTextField(TextEditingController controller, String unit, {int maxLength = 1}) {
      return Row(
        children: [
          SizedBox(
            width: 45,
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: maxLength,
              decoration: InputDecoration(counterText: ''),
            ),
          ),
          SizedBox(width: 4),
          Text(unit, style: TextStyle(fontSize: 16)),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              unitTextField(e, '억', maxLength: 5),
              unitTextField(c, '천', maxLength: 1),
              unitTextField(b, '백', maxLength: 1),
              unitTextField(s, '십 (만원)'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String? currentValue, ValueChanged<String?> onChanged, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.attach_money_outlined)),
        value: currentValue,
        items: options.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (value) => !optional && (value == null || value.isEmpty) ? '$label을(를) 선택해주세요.' : null,
      ),
    );
  }
}
