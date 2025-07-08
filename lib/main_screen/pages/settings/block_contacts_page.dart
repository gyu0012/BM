import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../services/auth_service.dart';

class BlockContactsPage extends StatefulWidget {
  const BlockContactsPage({Key? key}) : super(key: key);

  @override
  State<BlockContactsPage> createState() => _BlockContactsPageState();
}

class _BlockContactsPageState extends State<BlockContactsPage> {
  List<String> _blockedContacts = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadBlockedContacts();
  }

  // Firestore에서 차단된 연락처 목록을 불러옵니다.
  Future<void> _loadBlockedContacts() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final contacts = await authService.getBlockedContacts();
    if (mounted) {
      setState(() {
        _blockedContacts = contacts;
        _isLoading = false;
      });
    }
  }

  // 주소록을 가져와서 차단 목록을 '덮어쓰기'하는 메인 함수
  Future<void> _importAndBlockContacts() async {
    // 1. 연락처 접근 권한 요청
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('연락처 접근 권한이 필요합니다. 앱 설정에서 권한을 허용해주세요.')),
        );
      }
      return;
    }

    setState(() => _isSyncing = true);
    try {
      // 2. 기기에서 연락처 가져오기
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      final List<String> validPhoneNumbers = [];

      for (final contact in contacts) {
        for (final phone in contact.phones) {
          if (phone.number.isEmpty) continue;

          // 단계 1: 모든 공백, 하이픈, 괄호 등 특수문자를 제거하여 숫자만 남깁니다.
          String normalizedNumber = phone.number.replaceAll(RegExp(r'[^0-9]'), '');

          // 단계 2: 국제번호(+82)를 국내번호(010) 형식으로 변환합니다.
          if (normalizedNumber.startsWith('8210')) {
            normalizedNumber = '0' + normalizedNumber.substring(2);
          } else if (normalizedNumber.startsWith('82010')) {
            normalizedNumber = normalizedNumber.substring(2);
          }

          // 단계 3: 최종적으로 '010'으로 시작하고 11자리인 번호만 유효한 것으로 간주합니다.
          if (normalizedNumber.startsWith('010') && normalizedNumber.length == 11) {
            validPhoneNumbers.add(normalizedNumber);
          }
        }
      }

      // 중복 제거
      final uniquePhoneNumbers = validPhoneNumbers.toSet().toList();

      // 4. AuthService를 통해 Firestore에 새 목록으로 '교체(덮어쓰기)'합니다.
      final authService = Provider.of<AuthService>(context, listen: false);

      // [핵심 변경사항]
      // 기존의 addBlockedContacts 대신, 전체 목록을 교체하는 새로운 함수를 호출합니다.
      // 이 함수의 이름은 syncBlockedContacts로 가정합니다. (2번 항목 참고)
      await authService.syncBlockedContacts(uniquePhoneNumbers);

      if (mounted) {
        // 메시지를 현재 상태에 맞게 좀 더 명확하게 수정
        if (uniquePhoneNumbers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('주소록에 차단할 유효한 휴대폰 연락처가 없습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${uniquePhoneNumbers.length}개의 연락처로 전체 동기화되었습니다.')),
          );
        }
      }

      // 5. 화면 새로고침
      await _loadBlockedContacts();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('연락처를 동기화하는 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 코드는 변경사항 없음
    return Scaffold(
      appBar: AppBar(
        title: const Text('아는 사람 차단하기'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '내 연락처의 지인을 차단합니다.\n차단된 지인에게 알려지지 않아요.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildBlockedCountCard(),
                  const SizedBox(height: 24),
                  _buildInfoBox(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildBlockedCountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('차단된 연락처', style: TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 8),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Text(
              '${_blockedContacts.length}개',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '회원님의 휴대폰에 등록된 전화번호를 차단해 서로 추천되지 않도록 하는 기능입니다. 연락처 차단하기 기능을 이용하지 않을 경우 지인과 매칭이 될 수 있습니다. 010-xxxx-xxxx로 구성된 번호만 등록되며 휴대폰 연락처보다 적은 개수가 등록될 수 있습니다.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: ElevatedButton(
        onPressed: _isSyncing ? null : _importAndBlockContacts,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2C2C2C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSyncing
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          '연락처 다시 등록하기', // 버튼 텍스트 변경으로 기능 명시
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}