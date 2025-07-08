// functions/index.js

 const functions = require("firebase-functions");
 const admin = require("firebase-admin");

 admin.initializeApp();

 const db = admin.firestore();

/**
  * 필드 값의 중복 여부를 확인하는 호출 가능한 함수.
  * @param {object} data - 클라이언트에서 전달한 데이터.
  * @param {string} data.field - 확인할 필드 이름 (e.g., 'phoneNumber', 'email', 'nickname').
  * @param {string} data.value - 확인할 값.
  * @returns {Promise<{isUnique: boolean}>} - 중복이 아니면 true, 중복이면 false를 반환.
*/
 exports.checkUniqueness = functions
   .region("asia-northeast3") // 서울 리전
   .https.onCall(async (data, context) => {
     const field = data.field;
     const value = data.value;

     if (!field || !value) {
       throw new functions.https.HttpsError(
         "invalid-argument",
         "The function must be called with two arguments 'field' and 'value'."
       );
     }

     try {
       const snapshot = await db.collection("users")
         .where(field, "==", value)
         .limit(1)
         .get();

       // 스냅샷이 비어있으면, 해당 값을 가진 문서가 없다는 의미이므로 고유함 (true).
       return { isUnique: snapshot.empty };

     } catch (error) {
       console.error("Error checking uniqueness:", error);
       throw new functions.https.HttpsError(
         "internal",
         "An error occurred while checking for uniqueness."
       );
     }
   });

 /**
  * 매주 월요일 오전 11시에 실행되어 주간 추천 프로필 카드를 생성하는 스케줄링 함수.
  */
 exports.generateWeeklyRecommendations = functions
   .region("asia-northeast3") // 서울 리전
   .pubsub.schedule("every monday 11:00")
   .timeZone("Asia/Seoul")
   .onRun(async (context) => {
     console.log("주간 프로필 카드 추천 생성을 시작합니다.");

     try {
       const usersSnapshot = await db.collection("users").get();
       if (usersSnapshot.empty) {
         console.log("추천할 사용자가 없습니다.");
         return null;
       }

       const allUsers = [];
       usersSnapshot.forEach(doc => {
         allUsers.push({ id: doc.id, ...doc.data() });
       });

       // 모든 사용자에 대해 추천 목록 생성
       const recommendationPromises = allUsers.map(user =>
         generateRecommendationsForUser(user, allUsers)
       );

       await Promise.all(recommendationPromises);
       console.log("모든 사용자에 대한 주간 프로필 카드 추천 생성을 완료했습니다.");

     } catch (error) {
       console.error("추천 생성 중 오류 발생:", error);
     }
     return null;
   });

 /**
  * 특정 사용자를 위한 추천 목록을 생성하는 헬퍼 함수.
  * @param {object} currentUser - 추천을 받을 사용자 객체.
  * @param {Array<object>} allUsers - 모든 사용자 목록.
  */
 async function generateRecommendationsForUser(currentUser, allUsers) {
   // 1. 본인 제외, 성별이 다른 사용자 필터링
   const targetGender = currentUser.gender === "남자" ? "여자" : "남자";
   const potentialMatches = allUsers.filter(user =>
     user.id !== currentUser.id && user.gender === targetGender
   );

   if (potentialMatches.length === 0) {
     console.log(`${currentUser.nickname}님에 대한 추천 대상이 없습니다.`);
     return;
   }

   // 2. 매칭 점수 계산 (단순화된 알고리즘 예시)
   // - 어빌리티 점수 차이의 합이 적을수록 높은 점수
   const scoredMatches = potentialMatches.map(targetUser => {
     let score = 0;
     const myScores = currentUser.abilityScores || {};
     const targetScores = targetUser.abilityScores || {};

     // 어빌리티 점수 차이 계산
     let diffSum = 0;
     const abilityKeys = Object.keys(myScores);
     for (const key of abilityKeys) {
       if (targetScores[key] != null) {
         diffSum += Math.abs(myScores[key] - targetScores[key]);
       }
     }
     // 차이가 적을수록 높은 점수 (최대 500점 가정)
     score = 500 - diffSum;

     // TODO: 여기에 더 복잡한 매칭 알고리즘을 추가할 수 있습니다.
     // (예: 가치관 답변 비교, 관심사 일치도 등)

     return {
       userId: targetUser.id,
       score: score,
     };
   });

   // 3. 점수 순으로 정렬 후 상위 4명 선택
   scoredMatches.sort((a, b) => b.score - a.score);
   const recommendedUserIds = scoredMatches.slice(0, 4).map(match => match.userId);

   // 4. Firestore에 추천 목록 저장
   const today = new Date();
   const expiryDate = new Date(today);
   expiryDate.setDate(today.getDate() + 7); // 유효기간 7일

   const recommendationDoc = {
     recommendedUserIds: recommendedUserIds,
     createdAt: admin.firestore.FieldValue.serverTimestamp(),
     expiryDate: admin.firestore.Timestamp.fromDate(expiryDate),
   };

   await db.collection("recommendations").doc(currentUser.id).set(recommendationDoc);
   console.log(`${currentUser.nickname}님에게 ${recommendedUserIds.length}개의 프로필 카드를 추천했습니다.`);
 }

 // functions/index.js 파일 하단에 이 함수를 추가하세요.

 /**
  * [추가] 특정 사용자에 대한 추천 생성을 수동으로 트리거하는 호출 가능한 함수.
  * (테스트 및 개발용)
  * @param {object} data - 클라이언트에서 전달한 데이터.
  * @param {string} data.userId - 추천을 생성할 사용자의 ID.
  * @returns {Promise<{success: boolean, message: string}>}
  */
 exports.generateRecommendationsForUserManually = functions
   .region("asia-northeast3")
   .https.onCall(async (data, context) => {
     // 인증된 사용자만 호출 가능하도록 확인
     if (!context.auth) {
       throw new functions.https.HttpsError(
         "unauthenticated",
         "The function must be called while authenticated."
       );
     }

     const userId = data.userId;
     if (!userId) {
        throw new functions.https.HttpsError(
         "invalid-argument",
         "The function must be called with a 'userId' argument."
       );
     }

     console.log(`수동 추천 생성을 시작합니다: ${userId}`);

     try {
         const usersSnapshot = await db.collection("users").get();
         if (usersSnapshot.empty) {
             return { success: false, message: "추천할 사용자가 없습니다." };
         }

         const allUsers = [];
         let currentUser = null;
         usersSnapshot.forEach(doc => {
             const userData = { id: doc.id, ...doc.data() };
             allUsers.push(userData);
             if (doc.id === userId) {
                 currentUser = userData;
             }
         });

         if (!currentUser) {
             return { success: false, message: `사용자를 찾을 수 없습니다: ${userId}` };
         }

         // 기존 헬퍼 함수를 사용하여 추천 생성
         await generateRecommendationsForUser(currentUser, allUsers);

         console.log(`수동 추천 생성 완료: ${userId}`);
         return { success: true, message: "추천이 성공적으로 생성되었습니다." };

     } catch (error) {
         console.error("수동 추천 생성 중 오류 발생:", error);
         throw new functions.https.HttpsError(
             "internal",
             "An error occurred while generating recommendations."
         );
     }
   });