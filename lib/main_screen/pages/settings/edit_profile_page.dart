// =================================================================
// =================================================================

// main_screen/pages/settings/edit_profile_page.dart (UPDATED)
// 경로: lib/main_screen/pages/settings/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'edit_photos_page.dart';
import 'edit_basic_info_page.dart';
import 'edit_personality_page.dart';
import 'edit_lifestyle_page.dart';
import 'edit_ability_page.dart'; // [추가]
import 'edit_financial_info_page.dart'; // [추가]
import 'edit_parents_financial_info_page.dart'; // [추가]
import 'edit_survey_page.dart'; // [추가]

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _buildSectionHeader(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
      );
    }

    Widget _buildListTile(String title, {VoidCallback? onTap}) {
      return ListTile(
        title: Text(title, style: TextStyle(fontSize: 16)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('프로필 변경')),
      body: ListView(
        children: [
          _buildSectionHeader('프로필'),
          _buildListTile('프로필/활동 사진', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditPhotosPage()));
          }),
          _buildListTile('프로필 정보 변경', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditBasicInfoPage()));
          }),
          _buildListTile('성격/취미/관심사', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditPersonalityPage()));
          }),
          _buildListTile('생활관', onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditLifestylePage()));
          }),

          Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),

          _buildSectionHeader('어빌리티'),
          _buildListTile('학력 및 직업', onTap: () {
            // [수정] 학력 및 직업 변경 페이지로 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditAbilityPage()));
          }),
          _buildListTile('경제력 정보 (본인)', onTap: () {
            // [수정] 본인 경제력 정보 변경 페이지로 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditFinancialInfoPage()));
          }),
          _buildListTile('경제력 정보 (부모님)', onTap: () {
            // [수정] 부모님 경제력 정보 변경 페이지로 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditParentsFinancialInfoPage()));
          }),

          Divider(height: 32, thickness: 1, indent: 16, endIndent: 16),

          _buildSectionHeader('가치관'),
          _buildListTile('가치관 설문', onTap: () {
            // [수정] 가치관 설문 변경 페이지로 이동
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditSurveyPage()));
          }),
        ],
      ),
    );
  }
}