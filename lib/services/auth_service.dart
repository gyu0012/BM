// 경로: lib/services/auth_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/like_model.dart';
import '../models/user_model.dart';
import '../models/user_profile_data.dart';
import 'ability_score_service.dart';
import '../models/history_log_model.dart';

// 추천 데이터를 담을 새로운 모델 클래스
class Recommendation {
  final UserModel user;
  final Timestamp createdAt;

  Recommendation({required this.user, required this.createdAt});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? getCurrentUser() => _auth.currentUser;

  // =================================================================
  // 호감/매칭 관련 메소드
  // =================================================================

  /// 내가 보낸 호감 목록 조회 (상대방이 아직 수락하지 않은)
  Stream<List<Like>> getSentLikes() {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return Stream.value([]);

    return _firestore
        .collection('likes')
        .where('fromUserId', isEqualTo: myUserId)
        .where('status', isEqualTo: 'sent')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Like.fromMap(doc.id, doc.data())).toList());
  }

  /// 내가 받은 호감 목록 조회 (내가 아직 수락하지 않은)
  Stream<List<Like>> getReceivedLikes() {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return Stream.value([]);

    return _firestore
        .collection('likes')
        .where('toUserId', isEqualTo: myUserId)
        .where('status', isEqualTo: 'sent')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Like.fromMap(doc.id, doc.data())).toList());
  }

  /// 매칭 완료된 사용자 ID 목록 조회
  Stream<List<String>> getMatchedUserIds() {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return Stream.value([]);

    return _firestore
        .collection('matches')
        .where('userIds', arrayContains: myUserId)
        .snapshots()
        .map((snapshot) {
      final List<String> matchedIds = [];
      for (var doc in snapshot.docs) {
        final userIds = List<String>.from(doc.data()['userIds']);
        // 자신을 제외한 다른 사용자의 ID를 찾음
        final otherUserId = userIds.firstWhere((id) => id != myUserId, orElse: () => '');
        if (otherUserId.isNotEmpty) {
          matchedIds.add(otherUserId);
        }
      }
      return matchedIds;
    });
  }

  /// 두 사용자 간의 관계 상태 확인 (없음, 내가 보냄, 내가 받음, 매칭 완료)
  Future<Map<String, dynamic>> getRelationshipStatus(String otherUserId) async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return {'status': 'none'};

    // 1. 매칭 완료 상태 확인
    final matchQuery = await _firestore
        .collection('matches')
        .where('userIds', arrayContains: myUserId)
        .get();

    final matchDoc = matchQuery.docs.where((doc) {
      final userIds = doc.data()['userIds'] as List;
      return userIds.contains(otherUserId);
    }).firstOrNull;

    if (matchDoc != null) {
      return {
        'status': 'matched',
        'contactInfoUnlocked': matchDoc.data()['contactInfoUnlocked'] ?? false
      };
    }

    // 2. 내가 보낸 호감 확인
    final sentLikeQuery = await _firestore
        .collection('likes')
        .where('fromUserId', isEqualTo: myUserId)
        .where('toUserId', isEqualTo: otherUserId)
        .limit(1)
        .get();

    if (sentLikeQuery.docs.isNotEmpty) {
      return {'status': 'like_sent'};
    }

    // 3. 내가 받은 호감 확인
    final receivedLikeQuery = await _firestore
        .collection('likes')
        .where('fromUserId', isEqualTo: otherUserId)
        .where('toUserId', isEqualTo: myUserId)
        .limit(1)
        .get();

    if (receivedLikeQuery.docs.isNotEmpty) {
      final likeDoc = receivedLikeQuery.docs.first;
      final likeId = likeDoc.id;
      final reasons = List<String>.from(likeDoc.data()['reasons'] ?? []);

      return {
        'status': 'like_received',
        'likeId': likeId,
        'reasons': reasons,
      };
    }

    return {'status': 'none'};
  }

  /// 호감 보내기
  Future<void> sendLike(String toUserId, List<String> reasons) async {
    final fromUserId = getCurrentUser()?.uid;
    if (fromUserId == null) return;

    await _firestore.collection('likes').add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'reasons': reasons,
      'status': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 호감 수락하기
  Future<void> acceptLike(String likeId, String fromUserId) async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return;

    await _firestore.collection('likes').doc(likeId).update({'status': 'accepted'});

    await _firestore.collection('matches').add({
      'userIds': [myUserId, fromUserId]..sort(),
      'createdAt': FieldValue.serverTimestamp(),
      'contactInfoUnlocked': false,
    });
  }

  /// 연락처 열람
  Future<void> unlockContact(String otherUserId) async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return;

    final sortedUserIds = [myUserId, otherUserId]..sort();

    final matchQuery = await _firestore
        .collection('matches')
        .where('userIds', isEqualTo: sortedUserIds)
        .limit(1)
        .get();

    if (matchQuery.docs.isNotEmpty) {
      await matchQuery.docs.first.reference.update({'contactInfoUnlocked': true});
    }
  }

  // =================================================================
  // 추천 및 프로필 열람 관련 메소드 (로직 대폭 수정)
  // =================================================================

  /// [신규] 이번 주 추천 카드를 받을 수 있는지 확인합니다.
  Future<bool> canReceiveWeeklyCards() async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return false;

    final userDoc = await _firestore.collection('users').doc(myUserId).get();
    if (!userDoc.exists) return false;

    final lastReceived = userDoc.data()?['lastWeeklyCardsReceivedAt'] as Timestamp?;
    if (lastReceived == null) {
      // 한 번도 받은 적 없으면 받을 수 있음
      return true;
    }

    // 다음 주 월요일 오전 11시를 계산하는 로직
    DateTime lastReceivedDate = lastReceived.toDate();
    int daysUntilNextMonday = (8 - lastReceivedDate.weekday) % 7;
    if (daysUntilNextMonday == 0 && lastReceivedDate.hour >= 11) {
      daysUntilNextMonday = 7;
    } else if (daysUntilNextMonday == 0 && lastReceivedDate.hour < 11) {
      // 월요일 11시 이전에 받은 경우, 이번 주 월요일이 기준
      daysUntilNextMonday = 0;
    }

    DateTime nextMonday11AM = DateTime(
        lastReceivedDate.year,
        lastReceivedDate.month,
        lastReceivedDate.day + daysUntilNextMonday,
        11, 0, 0
    );

    // 현재 시간이 다음 카드 발급 시간 이후인지 확인
    return DateTime.now().isAfter(nextMonday11AM);
  }

  /// [신규] 이번 주 추천 카드를 생성하여 발급합니다.
  Future<void> getWeeklyCards() async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) throw Exception("로그인이 필요합니다.");

    // 1. 추천 대상 조회 (기존 로직과 유사)
    final myProfile = await getUserProfile(myUserId);
    final myGender = myProfile?.gender;
    if (myGender == null) throw Exception("내 성별 정보가 없습니다.");

    final targetGender = (myGender == '남자') ? '여자' : '남자';
    final querySnapshot = await _firestore
        .collection('users')
        .where('gender', isEqualTo: targetGender)
        .where('status', isEqualTo: 'active')
        .limit(20) // 성능을 위해 일부만 가져옴
        .get();

    final allPotentialUsers = querySnapshot.docs;
    allPotentialUsers.shuffle(); // 랜덤으로 섞음

    final finalRecommendations = allPotentialUsers.take(4).toList();

    if (finalRecommendations.isEmpty) {
      print("추천할 사용자가 없습니다.");
      return;
    }

    // 2. 기존 추천 카드를 삭제하고 새로 발급 (Batch Write)
    final batch = _firestore.batch();
    final recommendationCollectionRef = _firestore
        .collection('recommendations')
        .doc(myUserId)
        .collection('cards');

    // 기존 카드 삭제
    final oldCards = await recommendationCollectionRef.get();
    for (var doc in oldCards.docs) {
      batch.delete(doc.reference);
    }

    // 새 카드 추가
    for (var userDoc in finalRecommendations) {
      final recommendedUserId = userDoc.id;
      final cardRef = recommendationCollectionRef.doc(recommendedUserId);
      batch.set(cardRef, {
        'uid': recommendedUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 3. 사용자 문서에 카드 발급 시간 기록
    final userDocRef = _firestore.collection('users').doc(myUserId);
    batch.update(userDocRef, {'lastWeeklyCardsReceivedAt': FieldValue.serverTimestamp()});

    await batch.commit();
  }

  /// [로직 변경] 저장된 추천 사용자 목록을 그대로 가져옵니다.
  Stream<List<Recommendation>> getRecommendedUsers() {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return Stream.value([]);

    return _firestore
        .collection('recommendations')
        .doc(myUserId)
        .collection('cards')
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return [];

      List<Future<Recommendation?>> futures = snapshot.docs.map((doc) async {
        final data = doc.data();
        final recommendedUserId = data['uid'] as String?;
        final createdAt = data['createdAt'] as Timestamp?;

        if (recommendedUserId == null || createdAt == null) return null;

        final userProfile = await getUserProfile(recommendedUserId);

        if (userProfile != null && (userProfile.status == 'active' || userProfile.status == null)) {
          return Recommendation(user: userProfile, createdAt: createdAt);
        }
        return null;
      }).toList();

      final results = await Future.wait(futures);
      return results.where((rec) => rec != null).cast<Recommendation>().toList();
    });
  }

  /// 프로필 열람 상태 확인
  Future<List<String>> checkUnlockStatus(String targetId) async {
    final viewerId = getCurrentUser()?.uid;
    if (viewerId == null) return [];

    final unlockDocId = '${viewerId}_${targetId}';
    final docSnapshot = await _firestore.collection('unlocks').doc(unlockDocId).get();

    if (docSnapshot.exists && docSnapshot.data()!['unlockedTabs'] != null) {
      return List<String>.from(docSnapshot.data()!['unlockedTabs']);
    }
    return [];
  }

  /// 프로필 탭 열람 정보 저장
  Future<void> unlockProfileTab(String targetId, String tabName) async {
    final viewerId = getCurrentUser()?.uid;
    if (viewerId == null) return;

    final unlockDocId = '${viewerId}_${targetId}';
    final docRef = _firestore.collection('unlocks').doc(unlockDocId);

    await docRef.set({
      'viewerId': viewerId,
      'targetId': targetId,
      'unlockedTabs': FieldValue.arrayUnion([tabName]),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }


  // =================================================================
  // 회원가입, 로그인, 기본 정보 관리 메소드
  // =================================================================

  /// userId로 사용자 프로필 정보 가져오는 메소드
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// 이미지 업로드 및 URL 반환 로직
  Future<String> _uploadImageAndGetUrl(File imageFile, String userId) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef = _storage.ref().child('profile_images').child(userId).child(fileName);

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// 회원가입
  Future<UserCredential?> signUpWithEmailPassword(String email, String password, UserProfileData userProfileData) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String userId = userCredential.user!.uid;

      List<Future<String>> profileUploadFutures = userProfileData.profileImageFiles
          .map((file) => _uploadImageAndGetUrl(file, userId))
          .toList();
      userProfileData.profileImageUrls = await Future.wait(profileUploadFutures);

      List<Future<String>> activityUploadFutures = userProfileData.activityImageFiles
          .map((file) => _uploadImageAndGetUrl(file, userId))
          .toList();
      userProfileData.activityImageUrls = await Future.wait(activityUploadFutures);

      await _saveUserData(userId, userProfileData);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('회원가입 오류: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('회원가입 중 알 수 없는 오류: $e');
      rethrow;
    }
  }

  /// 사용자 정보 저장
  Future<void> _saveUserData(String userId, UserProfileData userProfileData) async {
    try {
      Map<String, dynamic> userDataMap = userProfileData.toFirestoreMap(userId);
      // 회원가입 시 기본 status를 'active'로 설정
      userDataMap['status'] = 'active';
      await _firestore.collection('users').doc(userId).set(userDataMap, SetOptions(merge: true));
    } catch (e) {
      print('사용자 데이터 저장 오류: $e');
      rethrow;
    }
  }

  /// 이메일 중복 확인
  Future<bool> checkEmailExists(String email) async {
    try {
      // 이메일은 Auth에서 관리하므로, status와 관계없이 중복 확인이 필요합니다.
      // (탈퇴한 유저가 같은 이메일로 재가입하는 것을 막을 수 있음)
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      rethrow;
    }
  }

  /// 전화번호 중복 확인
  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    try {
      // [수정] 'active' 상태인 사용자에 대해서만 전화번호 중복을 확인
      final querySnapshot = await _firestore.collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  /// 닉네임 중복 확인
  Future<bool> checkNicknameExists(String nickname) async {
    try {
      // [수정] 'active' 상태인 사용자에 대해서만 닉네임 중복을 확인
      final querySnapshot = await _firestore.collection('users')
          .where('nickname', isEqualTo: nickname)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  /// 로그인
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      // 1. Firebase Auth를 통해 먼저 로그인을 시도합니다.
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        // 2. 로그인 성공 후, Firestore에서 해당 유저의 프로필 정보를 가져옵니다.
        final userProfile = await getUserProfile(user.uid);

        // 3. 유저의 상태를 확인합니다.
        if (userProfile?.status == 'withdrawn') {
          // 4. 만약 '탈퇴한' 상태라면, 즉시 로그아웃시키고 에러를 발생시킵니다.
          await _auth.signOut();
          throw Exception('탈퇴한 계정입니다. 고객센터에 문의해주세요.');
        }
      }

      // 5. 계정이 활성 상태이면, 로그인 성공 결과를 반환합니다.
      return userCredential;

    } on FirebaseAuthException catch (e) {
      // Firebase Auth에서 발생하는 로그인 관련 오류 처리
      print('로그인 오류: ${e.message}');
      rethrow;
    } catch (e) {
      // '탈퇴한 계정입니다' 와 같은 커스텀 오류 처리
      print('로그인 처리 중 오류: $e');
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 현재 사용자의 비밀번호를 변경하고, 변경 기록을 Firestore에 남깁니다.
  ///
  /// 이 작업을 수행하려면 사용자를 다시 인증해야 합니다.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('로그인된 사용자 정보가 없거나 이메일이 등록되지 않았습니다.');
    }

    // 1. 현재 비밀번호로 사용자를 다시 인증합니다.
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('현재 비밀번호가 일치하지 않습니다.');
      }
      throw Exception('사용자 인증에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }

    // 2. 재인증이 성공하면, 새로운 비밀번호로 업데이트합니다.
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('새로운 비밀번호가 너무 취약합니다. 6자 이상으로 설정해주세요.');
      }
      throw Exception('비밀번호 변경에 실패했습니다.');
    }

    // [추가] 3. 비밀번호 변경 성공 후, Firestore 문서의 'lastUpdatedAt' 필드를 업데이트합니다.
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Firestore 업데이트 실패는 치명적인 오류는 아니므로 로그만 남깁니다.
      print('비밀번호 변경 후 Firestore 업데이트 실패: $e');
    }
  }

  /// 회원 탈퇴를 진행합니다. (소프트 삭제 방식)
  ///
  /// 사용자를 재인증한 후, Firestore 문서의 상태를 'withdrawn'으로 업데이트하고 로그아웃합니다.
  Future<void> deleteAccount(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('로그인된 사용자 정보가 없습니다.');
    }

    // 1. 현재 비밀번호로 사용자를 다시 인증합니다.
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('비밀번호가 일치하지 않습니다.');
      }
      throw Exception('사용자 인증에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }

    // 2. [수정] Firestore 문서의 상태를 업데이트하여 소프트 삭제를 수행합니다.
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'status': 'withdrawn',
        'withdrawnAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore 사용자 상태 업데이트 오류: $e');
      throw Exception('회원 탈퇴 처리 중 데이터베이스 오류가 발생했습니다.');
    }

    // 3. [수정] Auth 계정을 삭제하는 대신 로그아웃만 진행합니다.
    // 실제 서비스에서는 Cloud Function을 호출하여 Auth 계정을 '비활성화'하는 것이 가장 이상적입니다.
    // 클라이언트 SDK에서는 비활성화 기능이 없으므로, 로그아웃으로 대체합니다.
    try {
      await _auth.signOut();
    } catch(e) {
      print('소프트 삭제 후 로그아웃 실패: $e');
    }
  }

  // =================================================================
  // 프로필 업데이트 관련 메소드들
  // =================================================================

  /// 프로필 사진 업데이트
  Future<void> updateUserPhotos({
    required String userId,
    required List<String> existingProfileUrls,
    required List<File> newProfileFiles,
    required List<String> existingActivityUrls,
    required List<File> newActivityFiles,
    required List<String> deletedUrls,
  }) async {
    try {
      List<Future<String>> newProfileUploadFutures = newProfileFiles.map((file) => _uploadImageAndGetUrl(file, userId)).toList();
      final newProfileUrls = await Future.wait(newProfileUploadFutures);

      List<Future<String>> newActivityUploadFutures = newActivityFiles.map((file) => _uploadImageAndGetUrl(file, userId)).toList();
      final newActivityUrls = await Future.wait(newActivityUploadFutures);

      final finalProfileUrls = [...existingProfileUrls, ...newProfileUrls];
      final finalActivityUrls = [...existingActivityUrls, ...newActivityUrls];

      await _firestore.collection('users').doc(userId).update({
        'profileImageUrls': finalProfileUrls,
        'activityImageUrls': finalActivityUrls,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      for (var url in deletedUrls) {
        try {
          Reference photoRef = _storage.refFromURL(url);
          await photoRef.delete();
        } catch (e) {
          print('Error deleting photo from storage: $e');
        }
      }
    } catch (e) {
      print('Error updating user photos: $e');
      rethrow;
    }
  }

  /// 기본 프로필 정보 업데이트
  Future<void> updateUserBasicProfile(String userId, Map<String, dynamic> dataToUpdate) async {
    try {
      final updateData = {...dataToUpdate, 'lastUpdatedAt': FieldValue.serverTimestamp()};
      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      print('Error updating user basic profile: $e');
      rethrow;
    }
  }

  /// 성격/취미/관심사 업데이트
  Future<void> updateUserPersonalityAndInterests(String userId, {
    required List<String> personalityTraits,
    required List<String> hobbies,
    required List<String> interests,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'personalityTraits': personalityTraits,
        'hobbies': hobbies,
        'interests': interests,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating personality and interests: $e');
      rethrow;
    }
  }

  /// 생활관 정보 업데이트
  Future<void> updateUserLifestyle({
    required String userId,
    required List<String> coreValues,
    required Map<String, String> lifestyleChoices,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coreValues': coreValues,
        'lifestyleChoices': lifestyleChoices,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating lifestyle: $e');
      rethrow;
    }
  }

  /// 학력 및 직업 정보 업데이트
  Future<void> updateUserAbility({
    required String userId,
    required String educationLevel,
    required String schoolName,
    required String companyName,
    required String jobTitle,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'educationLevel': educationLevel,
        'schoolName': schoolName,
        'companyName': companyName,
        'jobTitle': jobTitle,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user ability info: $e');
      rethrow;
    }
  }

  /// 능력 점수 재계산 및 업데이트 로직을 위한 private 헬퍼 메소드
  Future<void> _recalculateScoresAndUpdate(String userId, Map<String, dynamic> dataToUpdate) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) throw Exception("User not found");
    final userModel = UserModel.fromMap(userDoc.data()!);

    final tempProfileData = UserProfileData.fromModel(userModel)
      ..updateWith(dataToUpdate);

    final scoreService = AbilityScoreService();
    if (dataToUpdate.containsKey('surveyAnswers')) {
      tempProfileData.myFixedValuesScore = scoreService.calculateFixedValuesScore(tempProfileData);
    }
    final newAbilityScores = scoreService.calculateScores(tempProfileData);

    final finalUpdateData = {
      ...dataToUpdate,
      if (dataToUpdate.containsKey('surveyAnswers')) 'myFixedValuesScore': tempProfileData.myFixedValuesScore,
      'abilityScores': newAbilityScores,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).update(finalUpdateData);
  }

  /// 본인 경제력 정보 업데이트 및 어빌리티 점수 재계산
  Future<void> updateUserFinancialProfile(String userId, Map<String, dynamic> newFinancialData) async {
    try {
      await _recalculateScoresAndUpdate(userId, {'userAssets': newFinancialData});
    } catch (e) {
      print('Error updating user financial profile: $e');
      rethrow;
    }
  }

  /// 부모님 경제력 정보 업데이트 및 어빌리티 점수 재계산
  Future<void> updateParentsFinancialProfile(String userId, Map<String, dynamic> newParentsFinancialData) async {
    try {
      await _recalculateScoresAndUpdate(userId, {'parentsAssets': newParentsFinancialData});
    } catch (e) {
      print('Error updating parents financial profile: $e');
      rethrow;
    }
  }

  /// 가치관 설문 정보 업데이트 및 어빌리티 점수 재계산
  Future<void> updateUserSurvey(String userId, Map<String, int> newSurveyAnswers) async {
    try {
      await _recalculateScoresAndUpdate(userId, {'surveyAnswers': newSurveyAnswers});
    } catch (e) {
      print('Error updating user survey: $e');
      rethrow;
    }
  }

  // =================================================================
  // [추가] 알림 설정 관련 메소드
  // =================================================================

  /// 사용자의 알림 설정을 가져오는 메서드
  Future<Map<String, bool>> getNotificationSettings(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('notificationSettings')) {
        final settingsData = docSnapshot.data()!['notificationSettings'] as Map<String, dynamic>;
        return settingsData.map((key, value) => MapEntry(key, value as bool));
      } else {
        // 설정값이 없는 경우 기본값 반환
        return {
          "allNotifications": true,
          "general_notice": true,
          "general_push": true,
          "matching_profileView": true,
          "matching_like": true,
          "matching_likeResponse": true,
          "matching_contactView": true,
        };
      }
    } catch (e) {
      print('Error fetching notification settings: $e');
      return {};
    }
  }

  /// 사용자의 알림 설정을 업데이트하는 메서드
  Future<void> updateNotificationSettings(String userId, Map<String, bool> settings) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notificationSettings': settings,
      });
    } catch (e) {
      print('Error updating notification settings: $e');
      rethrow;
    }
  }

  // =================================================================
  // [추가] 연락처 차단 관련 메소드
  // =================================================================

  /// 현재 사용자의 차단된 연락처 목록을 가져옵니다.
  Future<List<String>> getBlockedContacts() async {
    final userId = getCurrentUser()?.uid;
    if (userId == null) return [];

    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      // [수정] 필드명을 'blockedPhoneNumbers' -> 'blockedContacts'로 변경하여 일관성 유지
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('blockedContacts')) {
        // Firestore에서 가져온 List<dynamic>을 List<String>으로 안전하게 변환합니다.
        final blockedList = List<dynamic>.from(docSnapshot.data()!['blockedContacts']);
        return blockedList.map((item) => item.toString()).toList();
      }
    } catch (e) {
      print('차단된 연락처 로딩 오류: $e');
    }
    return [];
  }

  /// Firestore의 차단된 연락처 목록을 새로운 목록으로 완전히 교체(동기화)합니다.
  Future<void> syncBlockedContacts(List<String> newContactList) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("로그인된 사용자가 없습니다.");
    }

    try {
      final userDocRef = _firestore.collection('users').doc(user.uid);

      // [신규] 'blockedContacts' 필드에 newContactList를 그대로 덮어씁니다.
      // 이렇게 하면 기존의 모든 데이터는 사라지고 새로운 목록으로 대체됩니다.
      await userDocRef.update({
        'blockedContacts': newContactList,
      });
    } catch (e) {
      // 에러 처리
      print("차단된 연락처 동기화 실패: $e");
      rethrow;
    }
  }

  // =================================================================
  // [추가] 사용자 신고 및 차단 관련 메소드
  // =================================================================

  /// 사용자를 신고합니다. 신고 내용은 'reports' 컬렉션에 저장됩니다.
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? details,
  }) async {
    final reporterUserId = getCurrentUser()?.uid;
    if (reporterUserId == null) throw Exception('로그인이 필요합니다.');

    await _firestore.collection('reports').add({
      'reporterUserId': reporterUserId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'details': details ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'received', // 처리 상태 (예: received, in_review, resolved)
    });
  }

  /// 특정 사용자를 차단했는지 확인합니다.
  Future<bool> isUserBlocked(String targetUserId) async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return false;
    try {
      final myProfileDoc = await _firestore.collection('users').doc(myUserId).get();
      if (myProfileDoc.exists) {
        // 'blockedUsers' 필드가 없으면 빈 리스트로 처리
        final blockedUsers = List<String>.from(myProfileDoc.data()?['blockedUsers'] ?? []);
        return blockedUsers.contains(targetUserId);
      }
    } catch (e) {
      print("차단 상태 확인 오류: $e");
    }
    return false;
  }

  /// 특정 사용자를 차단 목록에 추가합니다.
  Future<void> blockUser(String targetUserId) async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return;
    await _firestore.collection('users').doc(myUserId).update({
      'blockedUsers': FieldValue.arrayUnion([targetUserId])
    });
  }

  /// 특정 사용자를 차단 목록에서 제거합니다.
  Future<void> unblockUser(String targetUserId) async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return;
    await _firestore.collection('users').doc(myUserId).update({
      'blockedUsers': FieldValue.arrayRemove([targetUserId])
    });
  }

  /// 현재 사용자가 차단한 모든 사용자의 ID 목록을 가져옵니다.
  Future<List<String>> getBlockedUserIds() async {
    final myUserId = getCurrentUser()?.uid;
    if (myUserId == null) return [];
    try {
      final myProfileDoc = await _firestore.collection('users').doc(myUserId).get();
      if (myProfileDoc.exists && myProfileDoc.data()!.containsKey('blockedUsers')) {
        return List<String>.from(myProfileDoc.data()!['blockedUsers']);
      }
    } catch (e) {
      print("차단 목록 조회 오류: $e");
    }
    return [];
  }
  /// [추가] 추천 생성을 트리거하는 함수
  ///
  /// Firebase Cloud Function의 'createWeeklyRecommendations'를 호출합니다.
  Future<void> triggerRecommendationGeneration() async {
    try {
      // 'createWeeklyRecommendations'는 실제 Cloud Function의 이름입니다.
      final HttpsCallable callable = _functions.httpsCallable('createWeeklyRecommendations');
      final result = await callable.call();
      print("Cloud Function 호출 완료: ${result.data}");
    } on FirebaseFunctionsException catch (e) {
      print('Cloud Function 호출 실패: ${e.code} - ${e.message}');
      // 사용자에게 보여줄 에러 메시지를 위해 예외를 다시 던질 수 있습니다.
      throw Exception('추천 생성에 실패했습니다. 잠시 후 다시 시도해주세요.');
    } catch (e) {
      print('알 수 없는 에러 발생: $e');
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  /// 사용자의 활동 로그를 타입에 따라 조회합니다.
  Stream<List<HistoryLog>> getHistoryLogs(List<LogType> logTypes) {
    final userId = getCurrentUser()?.uid;
    if (userId == null) return Stream.value([]);

    // LogType enum을 문자열 리스트로 변환
    final typeStrings = logTypes.map((type) => type.toString().split('.').last).toList();

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history_logs')
        .where('logType', whereIn: typeStrings)
        .orderBy('createdAt', descending: true)
        .limit(50) // 성능을 위해 최근 50개만 가져옴
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => HistoryLog.fromMap(doc.id, doc.data()))
        .toList());
  }

}