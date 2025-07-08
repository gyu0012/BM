// models/survey_data_model.dart (NEW FILE)
// 설문 구조와 데이터를 관리하기 위한 모델 파일
// 경로: lib/models/survey_data_model.dart

// 질문 유형 정의
enum QuestionType {
  none, // 점수 없음
  fixed, // 고정 점수
  variable, // 변동 점수 (상대방 답변에 따라)
  match, // 일치/불일치 점수 (변동 점수의 특수한 형태)
}

// 답변 클래스
class Answer {
  final String text;
  final int? fixedScore; // 고정 점수
  final List<int>? variableScores; // 변동 점수표 (내가 이 답변을 선택했을 때, 상대방의 답변에 대한 점수)

  Answer({
    required this.text,
    this.fixedScore,
    this.variableScores,
  });
}

// 질문 클래스
class SurveyQuestion {
  final String id;
  final String category; // 배경(A), 일상(B) 등
  final String questionText;
  final QuestionType type;
  final List<Answer> answers;

  SurveyQuestion({
    required this.id,
    required this.category,
    required this.questionText,
    required this.type,
    required this.answers,
  });
}

// 전체 설문 데이터를 관리하는 클래스
class SurveyRepository {

  // [추가] 생활관 질문 데이터
  static const Map<String, List<String>> lifestyleQuestions = {
    '주말 활동 스타일은?': ['주로 집에서 휴식', '친구/지인과 만남', '취미 활동', '여행/나들이', '자기계발'],
    '선호하는 데이트 유형은?': ['맛집 탐방', '영화/공연 관람', '활동적인 액티비티', '조용한 카페 데이트', '함께하는 취미생활'],
    '갈등 발생 시 해결 방식은?': ['즉시 대화로 해결', '시간을 갖고 생각 정리 후 대화', '주변에 조언 구함', '상대방에게 맞춰주는 편'],
  };

  static List<SurveyQuestion> get allQuestions {
    return [
      // --- 배경(A) ---
      SurveyQuestion(
        id: 'A1',
        category: '배경',
        questionText: '나의 가정환경은 어떻게 되나요?',
        type: QuestionType.fixed,
        answers: [
          Answer(text: '부모님 두분 다 있음', fixedScore: 10),
          Answer(text: '한부모 가정', fixedScore: 5),
          Answer(text: '할머니 및 친척 등 기타 환경', fixedScore: 7),
          Answer(text: '부모님이 두분 다 안계심', fixedScore: 0),
        ],
      ),
      SurveyQuestion(
        id: 'A2',
        category: '배경',
        questionText: '나와 가족과의 관계는 어떻게 되나요?',
        type: QuestionType.fixed,
        answers: [
          Answer(text: '관계가 좋고 화목', fixedScore: 10),
          Answer(text: '보통', fixedScore: 6),
          Answer(text: '불화가 있고, 만나지 않음', fixedScore: 1),
          Answer(text: '단절', fixedScore: 0),
        ],
      ),
      SurveyQuestion(
        id: 'A3',
        category: '배경',
        questionText: '형제자매는 어떻게 되나요?',
        type: QuestionType.none,
        answers: [
          Answer(text: '없음'),
          Answer(text: '1명'),
          Answer(text: '2명'),
          Answer(text: '3명 이상'),
        ],
      ),
      // ... 문서에 있는 나머지 질문들을 위와 같은 형식으로 추가 ...

      // --- 만남(C) - 변동 점수 예시 ---
      SurveyQuestion(
        id: 'C1',
        category: '만남',
        questionText: '만남에 있어 가장 중요하게 보는 가치는?',
        type: QuestionType.variable,
        answers: [
          Answer(text: '외모 (얼굴, 몸매 등)', variableScores: [10, 5, 5, 5]),
          Answer(text: '집안 (분위기, 자산 규모)', variableScores: [5, 10, 5, 5]),
          Answer(text: '성격 (편안함, 대화)', variableScores: [5, 5, 10, 5]),
          Answer(text: '재력 (소득, 직장)', variableScores: [5, 5, 5, 10]),
        ],
      ),
      // --- 결혼(E) - 일치/불일치(match) 점수 예시 ---
      SurveyQuestion(
        id: 'E1',
        category: '결혼',
        questionText: '나는 결혼에 대해',
        type: QuestionType.match,
        answers: [
          Answer(text: '필요 없다고 생각해요', variableScores: [10, 5, 3, 1]),
          Answer(text: '깊이 생각해본적 없어요', variableScores: [5, 10, 7, 3]),
          Answer(text: '상대에 따라 다르다 생각해요', variableScores: [3, 7, 10, 5]),
          Answer(text: '인생에 반드시 필요하다 생각해요', variableScores: [1, 3, 5, 10]),
        ],
      ),
      // --- 기존 예시 질문들 ---
      SurveyQuestion(
          id: 'q1',
          category: '결혼',
          questionText: '자녀 계획은 어떻게 되시나요?',
          type: QuestionType.fixed, // 내 가치관 점수에만 반영
          answers: [
            Answer(text: '2~3년 내 1명 이상 희망', fixedScore: 10),
            Answer(text: '4~5년 내 1명 이상 희망', fixedScore: 7),
            Answer(text: '구체적인 계획은 없으나 긍정적', fixedScore: 5),
            Answer(text: '자녀 계획 없음 (딩크족)', fixedScore: 2),
            Answer(text: '절대 자녀를 원하지 않음', fixedScore: 0),
          ]),
      // ... (나머지 4개 질문도 여기에 추가)
    ];
  }
}
