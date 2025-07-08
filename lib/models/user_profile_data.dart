import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // UserModel을 사용하기 위해 import 추가

class UserProfileData {
  // Step 0: 약관 동의
  bool agreedTerms = false;
  bool agreedPrivacy = false;
  bool agreedMarketing = false;

  // Step 1: 성별 및 계정 정보
  String? gender;
  String phoneNumber = '';
  String email = '';
  String password = '';
  String nickname = '';

  /// 재화: 큐브 (회원가입 시 기본 10개 지급)
  int cubes = 10;

  // Step 2-5: 프로필 정보
  String? maritalStatus;
  String? marriagePlanDetails;
  String? residenceArea;
  String? activityArea;
  String? educationLevel;
  String? schoolName;
  String? companyName;
  String? jobTitle;
  int? height;
  String? bodyType;
  String? religion;
  String? smokingHabits;
  String? drinkingHabits;
  String? drinkingAmount;
  String? mbti;
  List<String> personalityTraits = [];
  List<String> hobbies = [];
  List<String> interests = [];
  String selfIntroduction = '';

  // Step 6: 사진
  List<File> profileImageFiles = [];
  List<File> activityImageFiles = [];
  List<String> profileImageUrls = [];
  List<String> activityImageUrls = [];

  // Step 7: 본인 경제력
  int? annualIncome;
  int? totalAssets;
  String? realEstateValue;
  String? carValue;
  String? debt;
  String financialDescription = '';

  // Step 8: 부모님 경제력
  int? parentsAnnualIncome;
  int? parentsTotalAssets;
  String? parentsRealEstateValue;
  String? parentsCarValue;
  String? parentsDebt;
  String parentsFinancialDescription = '';

  // Step 9-10: 가치관 및 설문
  List<String> coreValues = [];
  Map<String, String> lifestyleChoices = {};
  Map<String, int> surveyAnswers = {};
  int myFixedValuesScore = 0;
  Map<String, double> abilityScores = {};

  // 알림 설정 필드 및 기본값 정의
  Map<String, bool> notificationSettings = {
    "allNotifications": true,
    "general_notice": true,
    "general_push": true,
    "matching_profileView": true,
    "matching_like": true,
    "matching_likeResponse": true,
    "matching_contactView": true,
  };

  // 기본 생성자
  UserProfileData();

  // Firestore에 저장할 데이터가 누락되지 않도록 모든 필드 포함
  Map<String, dynamic> toFirestoreMap(String uid) {
    return {
      'uid': uid,
      'gender': gender,
      'email': email,
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'cubes': cubes, // Firestore에 저장할 데이터에 cubes 추가
      'maritalStatus': maritalStatus,
      'marriagePlanDetails': marriagePlanDetails,
      'residenceArea': residenceArea,
      'activityArea': activityArea,
      'educationLevel': educationLevel,
      'schoolName': schoolName,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'height': height,
      'bodyType': bodyType,
      'religion': religion,
      'smokingHabits': smokingHabits,
      'drinkingHabits': drinkingHabits,
      'drinkingAmount': drinkingAmount,
      'mbti': mbti,
      'personalityTraits': personalityTraits,
      'hobbies': hobbies,
      'interests': interests,
      'selfIntroduction': selfIntroduction,
      'profileImageUrls': profileImageUrls,
      'activityImageUrls': activityImageUrls,
      'userAssets': {
        'annualIncome': annualIncome,
        'totalAssets': totalAssets,
        'realEstateValue': realEstateValue,
        'carValue': carValue,
        'debt': debt,
        'financialDescription': financialDescription,
      },
      'parentsAssets': {
        'annualIncome': parentsAnnualIncome,
        'totalAssets': parentsTotalAssets,
        'realEstateValue': parentsRealEstateValue,
        'carValue': parentsCarValue,
        'debt': parentsDebt,
        'financialDescription': parentsFinancialDescription,
      },
      'coreValues': coreValues,
      'lifestyleChoices': lifestyleChoices,
      'surveyAnswers': surveyAnswers,
      'myFixedValuesScore': myFixedValuesScore,
      'abilityScores': abilityScores,
      'agreedMarketing': agreedMarketing,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdatedAt': FieldValue.serverTimestamp(),
      // Firestore에 저장할 데이터에 notificationSettings 추가
      'notificationSettings': notificationSettings,
    };
  }

  /// UserModel 객체로부터 UserProfileData 인스턴스를 생성하는 팩토리 생성자입니다.
  factory UserProfileData.fromModel(UserModel model) {
    // 기존 사용자의 알림 설정값이 없을 경우 사용할 기본값
    final defaultSettings = {
      "allNotifications": true,
      "general_notice": true,
      "general_push": true,
      "matching_profileView": true,
      "matching_like": true,
      "matching_likeResponse": true,
      "matching_contactView": true,
    };

    return UserProfileData()
    // 기존 유저의 큐브 정보를 불러옵니다. 만약 데이터가 없다면 기본값 10을 유지합니다.
      ..cubes = model.cubes ?? 10
      ..educationLevel = model.educationLevel
      ..myFixedValuesScore = model.myFixedValuesScore ?? 0
      ..annualIncome = model.userAssets?['annualIncome']
      ..totalAssets = model.userAssets?['totalAssets']
      ..parentsAnnualIncome = model.parentsAssets?['annualIncome']
      ..parentsTotalAssets = model.parentsAssets?['totalAssets']
      ..parentsRealEstateValue = model.parentsAssets?['realEstateValue']
      ..parentsCarValue = model.parentsAssets?['carValue']
      ..surveyAnswers = model.surveyAnswers ?? {}
    // 모델로부터 알림 설정 로드 (없으면 기본값 사용)
      ..notificationSettings = model.notificationSettings ?? defaultSettings;
  }

  /// Map<String, dynamic> 데이터로 현재 UserProfileData 인스턴스의 필드를 업데이트합니다.
  void updateWith(Map<String, dynamic> data) {
    if (data.containsKey('cubes')) {
      cubes = data['cubes'];
    }
    if (data.containsKey('userAssets')) {
      annualIncome = data['userAssets']['annualIncome'];
      totalAssets = data['userAssets']['totalAssets'];
    }
    if (data.containsKey('parentsAssets')) {
      parentsAnnualIncome = data['parentsAssets']['annualIncome'];
      parentsTotalAssets = data['parentsAssets']['totalAssets'];
      parentsRealEstateValue = data['parentsAssets']['realEstateValue'];
      parentsCarValue = data['parentsAssets']['carValue'];
    }
    if (data.containsKey('surveyAnswers')) {
      surveyAnswers = Map<String, int>.from(data['surveyAnswers']);
    }
    // 알림 설정 업데이트 로직
    if (data.containsKey('notificationSettings')) {
      notificationSettings = Map<String, bool>.from(data['notificationSettings']);
    }
  }
}