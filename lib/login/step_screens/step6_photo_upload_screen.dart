// =================================================================
// =================================================================

// login/step_screens/step6_photo_upload_screen.dart (UPDATED)
// 경로: lib/login/step_screens/step6_photo_upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // image 패키지를 img 라는 별칭으로 사용
import 'package:path_provider/path_provider.dart';
import '../../models/user_profile_data.dart';

class Step6PhotoUploadScreen extends StatefulWidget {
  final UserProfileData userProfileData;
  final VoidCallback onNext;
  final VoidCallback onBack;

  Step6PhotoUploadScreen({required this.userProfileData, required this.onNext, required this.onBack});

  @override
  _Step6PhotoUploadScreenState createState() => _Step6PhotoUploadScreenState();
}

class _Step6PhotoUploadScreenState extends State<Step6PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  // [수정] URL 대신 실제 파일(File) 객체를 담을 리스트
  List<File> _profileImageFiles = [];
  List<File> _activityImageFiles = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때, 이전 단계에서 이미 선택된 파일이 있으면 불러옴
    _profileImageFiles.addAll(widget.userProfileData.profileImageFiles);
    _activityImageFiles.addAll(widget.userProfileData.activityImageFiles);
  }

  // --- [수정] 실제 이미지 선택 및 압축 기능 구현 ---
  Future<void> _pickAndCompressImage({required bool isProfilePhoto}) async {
    if (_isProcessing) return; // 중복 실행 방지
    setState(() { _isProcessing = true; });

    try {
      // 1. 갤러리에서 이미지 선택
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // 2. 이미지 압축
        final File compressedFile = await _compressImage(File(pickedFile.path));

        // 3. UI 상태 업데이트
        setState(() {
          if (isProfilePhoto) {
            if (_profileImageFiles.length < 3) {
              _profileImageFiles.add(compressedFile);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프로필 사진은 최대 3장까지 등록 가능합니다.')));
            }
          } else {
            if (_activityImageFiles.length < 3) {
              _activityImageFiles.add(compressedFile);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('취미/활동 사진은 최대 3장까지 등록 가능합니다.')));
            }
          }
        });
      }
    } catch (e) {
      print('Image picking/compressing error: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지를 처리하는 중 오류가 발생했습니다.')));
      }
    } finally {
      if(mounted) {
        setState(() { _isProcessing = false; });
      }
    }
  }

  // --- [추가] 이미지 압축 함수 ---
  Future<File> _compressImage(File file) async {
    // 1. 파일을 읽어 이미지 객체로 디코딩
    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) return file; // 디코딩 실패 시 원본 파일 반환

    // 2. 이미지 크기 조절 (가로 1080px 기준으로 리사이즈)
    img.Image resizedImage;
    if (image.width > 1080) {
      resizedImage = img.copyResize(image, width: 1080);
    } else {
      resizedImage = image;
    }

    // 3. 임시 디렉토리에 압축된 JPEG 파일로 저장 (품질 85%)
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    File compressedFile = File(tempPath)..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

    return compressedFile;
  }

  void _submitStep() {
    if (_profileImageFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프로필 사진은 최소 2장 등록해야 합니다.')));
      return;
    }
    // 선택된 파일들을 UserProfileData에 저장
    widget.userProfileData.profileImageFiles = _profileImageFiles;
    widget.userProfileData.activityImageFiles = _activityImageFiles;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold를 추가하여 SnackBar가 올바르게 표시되도록 함
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('사진 등록', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.pinkAccent), textAlign: TextAlign.center),
                SizedBox(height: 20),
                _buildImageSection('프로필 사진 (필수 2장, 최대 3장)', _profileImageFiles, true),
                SizedBox(height: 30),
                _buildImageSection('취미/활동 사진 (최대 3장)', _activityImageFiles, false),
                SizedBox(height: 40),
                ElevatedButton(onPressed: _submitStep, child: Text('다음')),
                SizedBox(height: 10),
                TextButton(onPressed: widget.onBack, child: Text('이전단계로')),
              ],
            ),
          ),
          // 처리 중일 때 화면 전체에 로딩 오버레이 표시
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('이미지 처리 중...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String title, List<File> imageFiles, bool isProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (imageFiles.length < 3)
              IconButton(icon: Icon(Icons.add_a_photo_outlined, color: Colors.pinkAccent), onPressed: () => _pickAndCompressImage(isProfilePhoto: isProfile)),
          ],
        ),
        SizedBox(height: 8),
        imageFiles.isEmpty
            ? InkWell(
          onTap: () => _pickAndCompressImage(isProfilePhoto: isProfile),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade500, size: 40)),
          ),
        )
            : GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: imageFiles.length,
          itemBuilder: (context, index) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFiles[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Positioned(
                  top: 2, right: 2,
                  child: InkWell(
                    onTap: () {
                      setState(() { imageFiles.removeAt(index); });
                    },
                    child: CircleAvatar(backgroundColor: Colors.black.withOpacity(0.6), radius: 12, child: Icon(Icons.close, size: 16, color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
