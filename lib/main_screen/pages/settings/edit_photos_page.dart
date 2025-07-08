// =================================================================
// =================================================================

// main_screen/pages/settings/edit_photos_page.dart (NEW FILE)
// 경로: lib/main_screen/pages/settings/edit_photos_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class EditPhotosPage extends StatefulWidget {
  const EditPhotosPage({Key? key}) : super(key: key);

  @override
  _EditPhotosPageState createState() => _EditPhotosPageState();
}

class _EditPhotosPageState extends State<EditPhotosPage> {
  late Future<UserModel?> _userProfileFuture;

  List<String> _profileImageUrls = [];
  List<String> _activityImageUrls = [];
  List<File> _newProfileImageFiles = [];
  List<File> _newActivityImageFiles = [];
  List<String> _deletedUrls = [];

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;
    if (userId != null) {
      _userProfileFuture = authService.getUserProfile(userId);
      _userProfileFuture.then((user) {
        if(user != null && mounted) {
          setState(() {
            _profileImageUrls = List.from(user.profileImageUrls ?? []);
            _activityImageUrls = List.from(user.activityImageUrls ?? []);
          });
        }
      });
    } else {
      _userProfileFuture = Future.value(null);
    }
  }

  Future<void> _pickAndCompressImage({required bool isProfilePhoto}) async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File compressedFile = await _compressImage(File(pickedFile.path));
        setState(() {
          if (isProfilePhoto) {
            _newProfileImageFiles.add(compressedFile);
          } else {
            _newActivityImageFiles.add(compressedFile);
          }
        });
      }
    } catch (e) {
      print('Image picking/compressing error: $e');
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  Future<File> _compressImage(File file) async {
    img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) return file;
    img.Image resizedImage = (image.width > 1080) ? img.copyResize(image, width: 1080) : image;
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(tempPath)..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));
  }

  void _deleteImage(dynamic image, bool isProfilePhoto) {
    setState(() {
      if (image is String) {
        _deletedUrls.add(image);
        if (isProfilePhoto) _profileImageUrls.remove(image);
        else _activityImageUrls.remove(image);
      } else if (image is File) {
        if (isProfilePhoto) _newProfileImageFiles.remove(image);
        else _newActivityImageFiles.remove(image);
      }
    });
  }

  Future<void> _saveChanges() async {
    setState(() { _isLoading = true; });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.getCurrentUser()?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사용자 정보가 없습니다.')));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await authService.updateUserPhotos(
        userId: userId,
        existingProfileUrls: _profileImageUrls,
        newProfileFiles: _newProfileImageFiles,
        existingActivityUrls: _activityImageUrls,
        newActivityFiles: _newActivityImageFiles,
        deletedUrls: _deletedUrls,
      );
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진이 성공적으로 변경되었습니다.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진 변경 중 오류가 발생했습니다.')));
      }
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필/활동 사진 변경'),
     actions: [
      TextButton(
        onPressed: _isLoading ? null : _saveChanges,
        child: Text('저장'),
      )
    ],
  ),
      body: FutureBuilder<UserModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return Center(child: Text('프로필 정보를 불러올 수 없습니다.'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildImageSection('프로필 사진 (필수 2장, 최대 3장)', _profileImageUrls, _newProfileImageFiles, true),
                    SizedBox(height: 30),
                    _buildImageSection('취미/활동 사진 (최대 3장)', _activityImageUrls, _newActivityImageFiles, false),
                    SizedBox(height: 40),
                    ElevatedButton(onPressed: _saveChanges, child: Text('저장하기')),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSection(String title, List<String> urls, List<File> files, bool isProfile) {
    final combinedList = [...urls, ...files];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (combinedList.length < 3)
              IconButton(icon: Icon(Icons.add_a_photo_outlined, color: Colors.pinkAccent), onPressed: () => _pickAndCompressImage(isProfilePhoto: isProfile)),
          ],
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: combinedList.length,
          itemBuilder: (context, index) {
            final item = combinedList[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item is String
                      ? Image.network(item, fit: BoxFit.cover)
                      : Image.file(item as File, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4, right: 4,
                  child: InkWell(
                    onTap: () => _deleteImage(item, isProfile),
                    child: CircleAvatar(backgroundColor: Colors.black54, radius: 12, child: Icon(Icons.close, size: 16, color: Colors.white)),
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
