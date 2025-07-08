// main_screen/pages/profile/widgets/ability_tab.dart (UPDATED)
// 경로: lib/main_screen/pages/profile/widgets/ability_tab.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../models/user_model.dart';

class AbilityTab extends StatefulWidget {
  final UserModel? myProfile;
  final UserModel targetUser;
  const AbilityTab({Key? key, this.myProfile, required this.targetUser}) : super(key: key);

  @override
  State<AbilityTab> createState() => _AbilityTabState();
}

class _AbilityTabState extends State<AbilityTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '-';
    int amountInt;
    if (amount is String) {
      amountInt = int.tryParse(amount) ?? 0;
    } else if (amount is int) {
      amountInt = amount;
    } else {
      return '-';
    }

    if (amountInt == 0) return '0만원';
    final eok = amountInt ~/ 10000;
    final man = amountInt % 10000;
    if (eok > 0 && man > 0) return '${eok}억 ${man}만원';
    if (eok > 0) return '${eok}억원';
    return '${man}만원';
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade600))),
          Expanded(child: Text(value ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildChartPage(String title, List<Map<String, double>> datasets, List<String> labels, List<Color> colors) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // 범례 추가
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(labels.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, color: colors[index]),
                      const SizedBox(width: 4),
                      Text(labels[index]),
                    ],
                  ),
                );
              }),
            ),
            Expanded(
              child: AbilityRadarChart(
                datasets: datasets,
                colors: colors,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyProfile = widget.myProfile?.uid == widget.targetUser.uid;

    final targetScores = widget.targetUser.abilityScores ?? {'학력': 0.0, '연소득': 0.0, '자산': 0.0, '가치관': 0.0, '부모님': 0.0};
    final myScores = widget.myProfile?.abilityScores ?? {'학력': 0.0, '연소득': 0.0, '자산': 0.0, '가치관': 0.0, '부모님': 0.0};

    // 합산 점수 계산
    final combinedScores = <String, double>{};
    if (!isMyProfile) {
      final keys = targetScores.keys.toSet()..addAll(myScores.keys);
      for (var key in keys) {
        double combinedValue = (targetScores[key] ?? 0.0) + (myScores[key] ?? 0.0);
        combinedScores[key] = combinedValue.clamp(0.0, 100.0);
      }
    }

    final List<Widget> chartPages = [
      _buildChartPage(
          '종합 어빌리티',
          [targetScores],
          [widget.targetUser.nickname ?? '상대방'],
          [Colors.pinkAccent]
      ),
      if (!isMyProfile) ...[
        _buildChartPage(
            '적합성 분석',
            [targetScores, myScores],
            [widget.targetUser.nickname ?? '상대방', '나'],
            [Colors.pinkAccent, Colors.blueAccent]
        ),
        _buildChartPage(
            '결혼 후 예상 어빌리티',
            [combinedScores],
            ['우리'],
            [Colors.greenAccent]
        ),
      ]
    ];

    final userAssets = widget.targetUser.userAssets ?? {};
    final parentsAssets = widget.targetUser.parentsAssets ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 400, // 슬라이드 영역 높이 고정
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: chartPages,
            ),
          ),
          if (chartPages.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(chartPages.length, (index) {
                return Container(
                  width: 8.0, height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.pinkAccent : Colors.grey.shade400,
                  ),
                );
              }),
            ),

          _buildSection('학력 및 직업', [
            _buildInfoRow('학력', widget.targetUser.educationLevel),
            _buildInfoRow('학교', widget.targetUser.schoolName),
            _buildInfoRow('직장', widget.targetUser.companyName),
            _buildInfoRow('직급', widget.targetUser.jobTitle),
          ]),
          _buildSection('나의 경제력', [
            _buildInfoRow('연소득', _formatCurrency(userAssets['annualIncome'])),
            _buildInfoRow('자산', _formatCurrency(userAssets['totalAssets'])),
            _buildInfoRow('부동산', userAssets['realEstateValue']),
            _buildInfoRow('자동차', userAssets['carValue']),
            if(userAssets['financialDescription'] != null && userAssets['financialDescription']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('"${userAssets['financialDescription']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
          ]),
          _buildSection('부모님 경제력', [
            _buildInfoRow('연소득', _formatCurrency(parentsAssets['annualIncome'])),
            _buildInfoRow('자산', _formatCurrency(parentsAssets['totalAssets'])),
            _buildInfoRow('부동산', parentsAssets['realEstateValue']),
            _buildInfoRow('자동차', parentsAssets['carValue']),
            if(parentsAssets['financialDescription'] != null && parentsAssets['financialDescription']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('"${parentsAssets['financialDescription']}"', style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
          ]),
        ],
      ),
    );
  }
}

class AbilityRadarChart extends StatelessWidget {
  final List<Map<String, double>> datasets;
  final List<Color> colors;

  const AbilityRadarChart({Key? key, required this.datasets, required this.colors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> abilityKeys = ['학력', '연소득', '자산', '가치관', '부모님'];

    // 모든 데이터셋에서 키의 순서를 abilityKeys에 따라 고정
    final List<List<double>> processedData = datasets.map((dataset) {
      return abilityKeys.map((key) => dataset[key] ?? 0.0).toList();
    }).toList();

    return CustomPaint(
      painter: _RadarChartPainter(
        data: processedData,
        labels: abilityKeys,
        colors: colors,
      ),
      size: Size.infinite,
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<List<double>> data;
  final List<String> labels;
  final List<Color> colors;

  _RadarChartPainter({required this.data, required this.labels, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY) * 0.75; // 라벨 공간 확보를 위해 약간 줄임
    final sides = labels.length;

    // 1. 배경 그리드 그리기
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 동심원 그리기
    for (var i = 1; i <= 4; i++) {
      final r = radius * i / 4;
      final path = Path();
      for (var j = 0; j <= sides; j++) {
        final angle = (2 * pi / sides) * j - pi / 2;
        final x = centerX + r * cos(angle);
        final y = centerY + r * sin(angle);
        if (j == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      canvas.drawPath(path, gridPaint);
    }

    // 중심에서 꼭지점으로 선 그리기
    for (var i = 0; i < sides; i++) {
      final angle = (2 * pi / sides) * i - pi / 2;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      canvas.drawLine(Offset(centerX, centerY), Offset(x, y), gridPaint);
    }

    // 2. 데이터셋 그리기 (여러 개)
    for (var i = 0; i < data.length; i++) {
      final dataset = data[i];
      final color = colors[i % colors.length]; // 색상 순환 사용

      final dataPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final dataStrokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final dataPath = Path();
      for (var j = 0; j < dataset.length; j++) {
        final score = dataset[j].clamp(0.0, 100.0);
        final r = radius * score / 100;
        final angle = (2 * pi / sides) * j - pi / 2;
        final x = centerX + r * cos(angle);
        final y = centerY + r * sin(angle);
        if (j == 0) dataPath.moveTo(x, y);
        else dataPath.lineTo(x, y);
      }
      dataPath.close();
      canvas.drawPath(dataPath, dataPaint);
      canvas.drawPath(dataPath, dataStrokePaint);

      // 데이터 포인트에 원 그리기
      final pointPaint = Paint()..color = color;
      for (var j = 0; j < dataset.length; j++) {
        final score = dataset[j].clamp(0.0, 100.0);
        final r = radius * score / 100;
        final angle = (2 * pi / sides) * j - pi / 2;
        final x = centerX + r * cos(angle);
        final y = centerY + r * sin(angle);
        canvas.drawCircle(Offset(x,y), 4.0, pointPaint);
      }
    }

    // 3. 라벨 그리기
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final textStyle = TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold);

    for (var i = 0; i < sides; i++) {
      final angle = (2 * pi / sides) * i - pi / 2;
      final r = radius * 1.2; // 라벨 위치 조정
      final x = centerX + r * cos(angle);
      final y = centerY + r * sin(angle);

      textPainter.text = TextSpan(text: labels[i], style: textStyle);
      textPainter.layout();

      double offsetX = x;
      double offsetY = y;

      if (x < centerX - textPainter.width/2) {
        offsetX = x - textPainter.width;
      } else if (x > centerX + textPainter.width/2) {
        // No change needed
      } else {
        offsetX = x - textPainter.width / 2;
      }

      if (y < centerY - textPainter.height/2) {
        offsetY = y - textPainter.height;
      } else if (y > centerY + textPainter.height/2) {
        // No change needed
      } else {
        offsetY = y - textPainter.height / 2;
      }

      // Fine-tuning for vertices
      if (angle > -pi/2 && angle < pi/2) { // Right
        offsetX = x + 5;
      } else if (angle < -pi/2 || angle > pi/2) { // Left
        offsetX = x - textPainter.width - 5;
      }

      if (angle > 0 && angle < pi) { // Bottom
        offsetY = y + 5;
      } else if (angle < 0 && angle > -pi) { // Top
        offsetY = y - textPainter.height - 5;
      }

      // Center align top and bottom labels
      if ((angle - (-pi / 2)).abs() < 0.01 || (angle - (pi / 2)).abs() < 0.01) {
        offsetX = x - textPainter.width / 2;
      }
      // Middle align left and right labels
      if((angle).abs() < 0.01 || (angle-pi).abs() < 0.01 || (angle+pi).abs() < 0.01) {
        offsetY = y - textPainter.height/2;
      }

      textPainter.paint(canvas, Offset(offsetX, offsetY));
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) =>
      oldDelegate.data != data ||
          oldDelegate.labels != labels ||
          oldDelegate.colors != colors;
}