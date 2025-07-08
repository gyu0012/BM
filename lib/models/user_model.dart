import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final int? cubes;
  final String? gender;
  final String? email;
  final String? nickname;
  final String? phoneNumber;
  final String? maritalStatus;
  final String? marriagePlanDetails;
  final String? residenceArea;
  final String? activityArea;
  final String? educationLevel;
  final String? schoolName;
  final String? companyName;
  final String? jobTitle;
  final int? height;
  final String? bodyType;
  final String? religion;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? drinkingAmount;
  final String? mbti;
  final List<String>? personalityTraits;
  final List<String>? hobbies;
  final List<String>? interests;
  final String? selfIntroduction;
  final List<String>? profileImageUrls;
  final List<String>? activityImageUrls;
  final Map<String, dynamic>? userAssets;
  final Map<String, dynamic>? parentsAssets;
  final List<String>? coreValues;
  final Map<String, String>? lifestyleChoices;
  final Map<String, int>? surveyAnswers;
  final int? myFixedValuesScore;
  final Map<String, double>? abilityScores;
  final Timestamp? createdAt;
  final Timestamp? lastUpdatedAt;
  // [추가] 알림 설정 필드
  final Map<String, bool>? notificationSettings;
  // [추가] 소프트 삭제를 위한 필드
  final String? status; // 예: "active", "withdrawn"
  final Timestamp? withdrawnAt;

  UserModel({
    required this.uid,
    this.cubes,
    this.gender,
    this.email,
    this.nickname,
    this.phoneNumber,
    this.maritalStatus,
    this.marriagePlanDetails,
    this.residenceArea,
    this.activityArea,
    this.educationLevel,
    this.schoolName,
    this.companyName,
    this.jobTitle,
    this.height,
    this.bodyType,
    this.religion,
    this.smokingHabits,
    this.drinkingHabits,
    this.drinkingAmount,
    this.mbti,
    this.personalityTraits,
    this.hobbies,
    this.interests,
    this.selfIntroduction,
    this.profileImageUrls,
    this.activityImageUrls,
    this.userAssets,
    this.parentsAssets,
    this.coreValues,
    this.lifestyleChoices,
    this.surveyAnswers,
    this.myFixedValuesScore,
    this.abilityScores,
    this.createdAt,
    this.lastUpdatedAt,
    // [추가] 생성자에 추가
    this.notificationSettings,
    // [추가] 생성자에 추가
    this.status,
    this.withdrawnAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      cubes: data['cubes'] as int?,
      gender: data['gender'] as String?,
      email: data['email'] as String?,
      nickname: data['nickname'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      maritalStatus: data['maritalStatus'] as String?,
      marriagePlanDetails: data['marriagePlanDetails'] as String?,
      residenceArea: data['residenceArea'] as String?,
      activityArea: data['activityArea'] as String?,
      educationLevel: data['educationLevel'] as String?,
      schoolName: data['schoolName'] as String?,
      companyName: data['companyName'] as String?,
      jobTitle: data['jobTitle'] as String?,
      height: data['height'] as int?,
      bodyType: data['bodyType'] as String?,
      religion: data['religion'] as String?,
      smokingHabits: data['smokingHabits'] as String?,
      drinkingHabits: data['drinkingHabits'] as String?,
      drinkingAmount: data['drinkingAmount'] as String?,
      mbti: data['mbti'] as String?,
      personalityTraits: data['personalityTraits'] != null ? List<String>.from(data['personalityTraits']) : null,
      hobbies: data['hobbies'] != null ? List<String>.from(data['hobbies']) : null,
      interests: data['interests'] != null ? List<String>.from(data['interests']) : null,
      selfIntroduction: data['selfIntroduction'] as String?,
      profileImageUrls: data['profileImageUrls'] != null ? List<String>.from(data['profileImageUrls']) : null,
      activityImageUrls: data['activityImageUrls'] != null ? List<String>.from(data['activityImageUrls']) : null,
      userAssets: data['userAssets'] != null ? Map<String, dynamic>.from(data['userAssets']) : null,
      parentsAssets: data['parentsAssets'] != null ? Map<String, dynamic>.from(data['parentsAssets']) : null,
      coreValues: data['coreValues'] != null ? List<String>.from(data['coreValues']) : null,
      lifestyleChoices: data['lifestyleChoices'] != null ? Map<String, String>.from(data['lifestyleChoices']) : null,
      surveyAnswers: data['surveyAnswers'] != null ? Map<String, int>.from(data['surveyAnswers']) : null,
      myFixedValuesScore: data['myFixedValuesScore'] as int?,
      abilityScores: data['abilityScores'] != null ? Map<String, double>.from(data['abilityScores']) : null,
      createdAt: data['createdAt'] as Timestamp?,
      lastUpdatedAt: data['lastUpdatedAt'] as Timestamp?,
      // [추가] Firestore 데이터를 모델로 변환
      notificationSettings: data['notificationSettings'] != null ? Map<String, bool>.from(data['notificationSettings']) : null,
      // [추가] Firestore 데이터를 모델로 변환
      status: data['status'] as String?,
      withdrawnAt: data['withdrawnAt'] as Timestamp?,
    );
  }
}