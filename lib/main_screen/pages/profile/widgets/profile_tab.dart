// main_screen/pages/profile/widgets/profile_tab.dart (UPDATED)
// 경로: lib/main_screen/pages/profile/widgets/profile_tab.dart
import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

class ProfileTab extends StatelessWidget {
  final UserModel user;
  const ProfileTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- [START] Helper Widgets and Logic ---
    final pPhotos = user.profileImageUrls ?? [];
    final aPhotos = user.activityImageUrls ?? [];

    final profilePhoto1 = pPhotos.isNotEmpty ? pPhotos[0] : null;
    final profilePhoto2 = pPhotos.length > 1 ? pPhotos[1] : null;
    final profilePhoto3 = pPhotos.length > 2 ? pPhotos[2] : null;

    final activityPhoto1 = aPhotos.isNotEmpty ? aPhotos[0] : null;

    final thirdImageToShow = profilePhoto3 ?? activityPhoto1;

    List<String> hobbyPhotosForGrid = [];
    if (aPhotos.length > 1) {
      hobbyPhotosForGrid.add(aPhotos[1]);
    }
    if (aPhotos.length > 2) {
      hobbyPhotosForGrid.add(aPhotos[2]);
    }

    Widget _buildInfoRow(String label, String? value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100, // 라벨 너비 조정
              child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            ),
            Expanded(child: Text(value ?? '-', style: TextStyle(fontSize: 16))),
          ],
        ),
      );
    }

    Widget _buildChipSection(String label, List<String>? items) {
      if (items == null || items.isEmpty) return SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: items.map((item) => Chip(
                label: Text(item),
                backgroundColor: Colors.pink.shade50,
                side: BorderSide(color: Colors.pink.shade100),
              )).toList(),
            ),
          ],
        ),
      );
    }

    Widget _buildLifestyleSection() {
      final lifestyleAnswers = user.lifestyleChoices;
      if (lifestyleAnswers == null || lifestyleAnswers.isEmpty) {
        return SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text("나의 생활관", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...lifestyleAnswers.entries.map((entry) {
            return _buildInfoRow(entry.key, entry.value);
          }).toList(),
        ],
      );
    }

    Widget _buildProfileImage(String? imageUrl) {
      return AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.person, size: 80, color: Colors.grey.shade400)
                : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400);
              },
            ),
          ),
        ),
      );
    }

    Widget _buildActivityImage(String imageUrl) {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.error_outline, size: 50, color: Colors.grey.shade400);
            },
          ),
        ),
      );
    }
    // --- [END] Helper Widgets and Logic ---

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileImage(profilePhoto1),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.nickname ?? '닉네임 없음', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text(user.selfIntroduction ?? '자기소개가 없습니다.', style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 16)),
                ],
              ),
            ),
          ),
          _buildInfoRow('결혼상태', user.maritalStatus),
          _buildInfoRow('결혼계획', user.marriagePlanDetails),
          _buildInfoRow('거주지역', user.residenceArea),
          _buildInfoRow('활동지역', user.activityArea),
          _buildProfileImage(profilePhoto2),

          // --- [수정된 부분 시작] ---
          Divider(height: 32, indent: 16, endIndent: 16),
          _buildChipSection('핵심 가치관', user.coreValues), // [추가]
          _buildLifestyleSection(), // 생활관
          Divider(height: 32, indent: 16, endIndent: 16),
          // --- [수정된 부분 끝] ---

          _buildInfoRow('키', user.height != null ? '${user.height} cm' : null),
          _buildInfoRow('체형', user.bodyType),
          _buildInfoRow('종교', user.religion),
          _buildInfoRow('흡연', user.smokingHabits),
          _buildInfoRow('음주', user.drinkingHabits),
          _buildInfoRow('주량', user.drinkingAmount),
          _buildInfoRow('MBTI', user.mbti),

          if (thirdImageToShow != null)
            _buildProfileImage(thirdImageToShow),

          Divider(height: 32, indent: 16, endIndent: 16),
          _buildChipSection('성격', user.personalityTraits),
          _buildChipSection('취미', user.hobbies),
          _buildChipSection('관심사', user.interests),
          Divider(height: 32, indent: 16, endIndent: 16),

          if (hobbyPhotosForGrid.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("활동 사진", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemCount: hobbyPhotosForGrid.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    hobbyPhotosForGrid[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error_outline, size: 50, color: Colors.grey.shade400);
                    },
                  ),
                );
              },
            ),
          ],
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
