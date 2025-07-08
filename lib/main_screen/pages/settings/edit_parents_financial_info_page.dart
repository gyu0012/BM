// =================================================================
// =================================================================

// main_screen/pages/settings/edit_parents_financial_info_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/settings/edit_parents_financial_info_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class EditParentsFinancialInfoPage extends StatefulWidget {
  const EditParentsFinancialInfoPage({Key? key}) : super(key: key);

  @override
  _EditParentsFinancialInfoPageState createState() => _EditParentsFinancialInfoPageState();
}

class _EditParentsFinancialInfoPageState extends State<EditParentsFinancialInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _incomeEokController = TextEditingController();
  final TextEditingController _incomeCheonController = TextEditingController();
  final TextEditingController _incomeBaekController = TextEditingController();
  final TextEditingController _incomeSipController = TextEditingController();

  final TextEditingController _assetEokController = TextEditingController();
  final TextEditingController _assetCheonController = TextEditingController();
  final TextEditingController _assetBaekController = TextEditingController();
  final TextEditingController _assetSipController = TextEditingController();

  late TextEditingController _descriptionController;

  String? _realEstateValue;
  String? _carValue;
  String? _debt;

  final List<String> _realEstateOptions = ['미보유', '5억원 미만', '5억원 이상 ~ 10억원 미만', '10억원 이상 ~ 15억원 미만', '15억원 이상 ~ 30억원 미만', '30억원 이상', '모름/비공개'];
  final List<String> _carOptions = ['미보유', '3천만원 미만', '3천만원 이상 ~ 8천만원 미만', '8천만원 이상 ~ 1억 5천만원 미만', '1억 5천만원 이상', '모름/비공개'];
  final List<String> _debtOptions = ['없음', '5천만원 미만', '5천만원 ~ 1억원', '1억원 ~ 3억원', '3억원 ~ 5억원', '5억원 이상', '모름/비공개'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      final user = await authService.getUserProfile(userId);
      if (user != null && user.parentsAssets != null && mounted) {
        setState(() {
          _initializeUnitControllers(user.parentsAssets!['annualIncome'], _incomeEokController, _incomeCheonController, _incomeBaekController, _incomeSipController);
          _initializeUnitControllers(user.parentsAssets!['totalAssets'], _assetEokController, _assetCheonController, _assetBaekController, _assetSipController);
          _realEstateValue = user.parentsAssets!['realEstateValue'];
          _carValue = user.parentsAssets!['carValue'];
          _debt = user.parentsAssets!['debt'];
          _descriptionController.text = user.parentsAssets!['financialDescription'] ?? '';
        });
      }
    }
  }

  void _initializeUnitControllers(dynamic totalAmount, TextEditingController e, TextEditingController c, TextEditingController b, TextEditingController s) {
    int? amount = (totalAmount is int) ? totalAmount : null;
    if (amount != null && amount > 0) {
      e.text = (amount ~/ 10000).toString();
      c.text = ((amount % 10000) ~/ 1000).toString();
      b.text = ((amount % 1000) ~/ 100).toString();
      s.text = ((amount % 100) ~/ 10).toString();
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

    final int annualIncome = _calculateAmountFromControllers(_incomeEokController, _incomeCheonController, _incomeBaekController, _incomeSipController);
    final int totalAssets = _calculateAmountFromControllers(_assetEokController, _assetCheonController, _assetBaekController, _assetSipController);

    final Map<String, dynamic> dataToUpdate = {
      'annualIncome': annualIncome,
      'totalAssets': totalAssets,
      'realEstateValue': _realEstateValue,
      'carValue': _carValue,
      'debt': _debt,
      'financialDescription': _descriptionController.text.trim(),
    };

    try {
      await authService.updateParentsFinancialProfile(userId, dataToUpdate);
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

  int _calculateAmountFromControllers(TextEditingController e, TextEditingController c, TextEditingController b, TextEditingController s) {
    final eok = int.tryParse(e.text) ?? 0;
    final cheon = int.tryParse(c.text) ?? 0;
    final baek = int.tryParse(b.text) ?? 0;
    final sip = int.tryParse(s.text) ?? 0;
    return (eok * 10000) + (cheon * 1000) + (baek * 100) + (sip * 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('부모님 경제 정보 변경'),
        actions: [
          TextButton(onPressed: _isLoading ? null : _saveChanges, child: Text('저장'))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(24),
          children: [
            _buildUnitInput('연소득', _incomeEokController, _incomeCheonController, _incomeBaekController, _incomeSipController),
            SizedBox(height: 16),
            _buildUnitInput('자산', _assetEokController, _assetCheonController, _assetBaekController, _assetSipController),
            _buildDropdownField('부동산', _realEstateOptions, _realEstateValue, (val) => setState(() => _realEstateValue = val)),
            _buildDropdownField('자동차', _carOptions, _carValue, (val) => setState(() => _carValue = val)),
            _buildDropdownField('부채', _debtOptions, _debt, (val) => setState(() => _debt = val), optional: true),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '경제력 설명 (선택)', border: OutlineInputBorder(), alignLabelWithHint: true),
              maxLength: 100, maxLines: 3,
            ),
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
              unitTextField(c, '천'),
              unitTextField(b, '백'),
              unitTextField(s, '십만원'),
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
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        value: currentValue,
        items: options.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
        onChanged: onChanged,
        validator: (value) => !optional && (value == null || value.isEmpty) ? '$label을(를) 선택해주세요.' : null,
      ),
    );
  }
}
