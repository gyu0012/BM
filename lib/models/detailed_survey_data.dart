// models/detailed_survey_data.dart (UPDATED)
// 경로: lib/models/detailed_survey_data.dart
// 설문 구조와 모든 질문 데이터를 관리하는 파일

// 질문 유형 정의
enum QuestionType {
  none, // 점수 없음 (답변만 저장)
  fixed, // 고정 점수 (내 프로필 가치관 점수에 합산)
  variable, // 변동 점수 (상대방과의 궁합 점수 계산에 사용, 현재 로직에서는 사용되지 않음)
}

// 답변 클래스
class Answer {
  final String text;
  final int? fixedScore;
  final List<int>? variableScores;

  Answer({ required this.text, this.fixedScore, this.variableScores });
}

// 질문 클래스
class SurveyQuestion {
  final String id;
  final String category;
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
class DetailedSurveyRepository {
  // [추가] 생활관 질문 데이터 중앙 관리
  static const Map<String, List<String>> lifestyleQuestions = {
    '선호하는 연락 빈도는?': [
      '필요할 때만',
      '하루 2~3번, 안부 물을 정도',
      '틈틈이 자주 (일상 공유)',
      '정해진 시간에 규칙적으로 (아침/저녁 등)',
      '딱히 정해두진 않음'
    ],
    '만났을 때 선호하는 장소는?': [
      '부담 없이 카페',
      '간단한 식사',
      '분위기 좋은 레스토랑/술집',
      '함께 즐길 거리가 있는 곳 (보드게임, 공원 산책 등)',
      '데이트처럼 (맛집, 카페, 영화 등 풀코스)'
    ],
    '선호하는 데이트 유형은?': [
      '맛집 탐방',
      '영화/공연/전시 관람',
      '액티비티 (스포츠, 방탈출 등)',
      '조용한 카페에서 대화',
      '함께하는 취미생활 (운동, 쇼핑, 드라이브 등)'
    ],
    '다퉜을 때 나는 어떻게 화해하는 편?': [
      '그 자리에서 바로 대화로 풀어야 함',
      '서로 감정이 가라앉은 뒤 차분하게 대화',
      '먼저 사과하고 넘어가는 편',
      '자연스럽게 아무 일 없었다는 듯이 풀림',
      '맛있는 음식을 먹으면서 화해'
    ],
    '데이트 비용은 어떻게 하는 게 편해?': [
      '번갈아 가면서 자연스럽게 내는 편',
      '공동의 목표! 데이트 통장을 만들어서 사용',
      '각자 쓴 비용은 확실하게 더치페이',
      '그때그때 상황에 따라 여유 있는 사람이 내기',
      '한 사람이 주도적으로 내는 게 편함'
    ]
  };

  static List<SurveyQuestion> get allQuestions {
    return [
      // --- 배경(A) ---
      SurveyQuestion(id: 'A1', category: '배경', questionText: '나의 가정환경은 어떻게 되나요?', type: QuestionType.fixed, answers: [ Answer(text: '부모님 두분 다 있음', fixedScore: 10), Answer(text: '한부모가정', fixedScore: 3), Answer(text: '할머니 및 친척 등 기타 환경', fixedScore: 5), Answer(text: '부모님이 두분 다 안계심', fixedScore: 1), ]),
      SurveyQuestion(id: 'A2', category: '배경', questionText: '나와 가족과의 관계는 어떻게 되나요?', type: QuestionType.fixed, answers: [ Answer(text: '관계가 좋고 화목', fixedScore: 10), Answer(text: '평범', fixedScore: 6), Answer(text: '불화가 있고, 만나지 않음', fixedScore: 4), Answer(text: '단절', fixedScore: 1), ]),
      SurveyQuestion(id: 'A3', category: '배경', questionText: '형제자매는 어떻게 되나요?', type: QuestionType.none, answers: [ Answer(text: '없음'), Answer(text: '1명'), Answer(text: '2명'), Answer(text: '3명 이상'), ]),
      SurveyQuestion(id: 'A4', category: '배경', questionText: '나의 부모님을 소개한다면?', type: QuestionType.fixed, answers: [ Answer(text: '가정적인 아버지와 어머니', fixedScore: 10), Answer(text: '관계는 좋지만 소통이 안될때가 있음', fixedScore: 7), Answer(text: '관계는 평범하고 소통이 안될때가 많음', fixedScore: 4), Answer(text: '관계가 매우 안좋음', fixedScore: 1), ]),
      SurveyQuestion(id: 'A5', category: '배경', questionText: '부모님은 나에게 어떤 의미인가요?', type: QuestionType.none, answers: [ Answer(text: '적극적인 지원과 꾸준한 믿음'), Answer(text: '부모님이 원하는 것을 따르고 싶음'), Answer(text: '자수성가해 부모님을 돕고 싶음'), Answer(text: '부모님과 나의 인생은 별개'), ]),
      SurveyQuestion(id: 'A6', category: '배경', questionText: '나의 거주 상태는요', type: QuestionType.none, answers: [ Answer(text: '부모님과 함께'), Answer(text: '부모님과 따로: 혼자'), Answer(text: '부모님과 따로: 동거 (형제자매 또는 친구)'), Answer(text: '집단 생활: 회사 또는 학교 기숙사/하숙'), ]),
      SurveyQuestion(id: 'A7', category: '배경', questionText: '나는 해외 여행을', type: QuestionType.none, answers: [ Answer(text: '거의 가지 않아요'), Answer(text: '평균 연 1회 정도 가는거 같아요'), Answer(text: '기회가 될때 마다 가요 (연 3회~5회 정도)'), Answer(text: '1달에 1번 정도 가요 (연 5회 이상)'), ]),
      SurveyQuestion(id: 'A8', category: '배경', questionText: '나는 해외에서 거주한적이', type: QuestionType.none, answers: [ Answer(text: '있어요 : 유학'), Answer(text: '있어요 : 부모님 이직'), Answer(text: '있어요 : 이민 또는 기타'), Answer(text: '없어요'), ]),
      SurveyQuestion(id: 'A9', category: '배경', questionText: '반려동물을 키워보거나 키우고 있나요?', type: QuestionType.none, answers: [ Answer(text: '아니오'), Answer(text: '강아지'), Answer(text: '고양이'), Answer(text: '기타 동물'), ]),
      SurveyQuestion(id: 'A10', category: '배경', questionText: '나의 정치 성향은 어떻게 되나요?', type: QuestionType.none, answers: [ Answer(text: '진보'), Answer(text: '보수'), Answer(text: '중도'), Answer(text: '관심없음'), ]),

      // --- 일상(B) ---
      SurveyQuestion(id: 'B1', category: '일상', questionText: '나는 취미생활을', type: QuestionType.none, answers: [ Answer(text: '거의 안 함'), Answer(text: '일주일에 1회 이상'), Answer(text: '한 달에 1~2회'), Answer(text: '어쩌다 한 번'), ]),
      SurveyQuestion(id: 'B2', category: '일상', questionText: '나는 동호회 활동을', type: QuestionType.none, answers: [ Answer(text: '해본적 없어요'), Answer(text: '해본적 없지만 궁금하긴 해요'), Answer(text: '1 ~ 2개'), Answer(text: '3개 이상'), ]),
      SurveyQuestion(id: 'B3', category: '일상', questionText: '나는 친구가', type: QuestionType.none, answers: [ Answer(text: '있긴 하지만 혼자 보내요'), Answer(text: '적지 않지만 바빠서 자주 못만남'), Answer(text: '1 ~ 2명의 친구를 주기적으로 만나요'), Answer(text: '많고 자주 만나요'), ]),
      SurveyQuestion(id: 'B4', category: '일상', questionText: '나는 친구를 만나면', type: QuestionType.none, answers: [ Answer(text: '술을 마셔요'), Answer(text: '활동적인 액티비티를 해요'), Answer(text: '맛집에서 밥먹고 커피숍에서 대화를 해요'), Answer(text: '문화를 즐겨요'), ]),
      SurveyQuestion(id: 'B5', category: '일상', questionText: '나는 청소나 정리정돈을 얼마나 자주하나요?', type: QuestionType.none, answers: [ Answer(text: '일주일에 한번 정도'), Answer(text: '다른 사람이 해주는 편'), Answer(text: '날마다 깨끗이 하죠'), Answer(text: '시간이 될때마다 해요'), ]),
      SurveyQuestion(id: 'B6', category: '일상', questionText: '나는 스트레스를 받을 때', type: QuestionType.none, answers: [ Answer(text: '운동을 해요'), Answer(text: '독서, 드라마 또는 넷플릭스를 봐요'), Answer(text: '잠을 자거나 멍 때려요'), Answer(text: '친구를 만나요'), ]),
      SurveyQuestion(id: 'B7', category: '일상', questionText: '나는 이럴때 성취감을 느껴요', type: QuestionType.none, answers: [ Answer(text: '인정 (회사, 운동 등)'), Answer(text: '관계 (사랑하는 사람)'), Answer(text: '재력 (연봉 상승, 투자 성공 등)'), Answer(text: '호감 (이성으로부터)'), ]),
      SurveyQuestion(id: 'B8', category: '일상', questionText: '일주일에 운동은 몇 번 하나요?', type: QuestionType.none, answers: [ Answer(text: '전혀 안함'), Answer(text: '주 1 ~ 2회'), Answer(text: '주 3 ~ 4회'), Answer(text: '거의 매일'), ]),
      SurveyQuestion(id: 'B9', category: '일상', questionText: '주말에 쉴 때 뭐해요?', type: QuestionType.none, answers: [ Answer(text: '주로 집에서 쉬어요'), Answer(text: '친구들을 만나러 밖에 나가요'), Answer(text: '취미활동을 해요'), Answer(text: '자기계발'), ]),
      SurveyQuestion(id: 'B10', category: '일상', questionText: '종교활동 자주 하세요?', type: QuestionType.none, answers: [ Answer(text: '전혀 안 함'), Answer(text: '월 1회 이상'), Answer(text: '월 2회 이상'), Answer(text: '매주 활동'), ]),

      // --- 만남(C) ---
      SurveyQuestion(id: 'C1', category: '만남', questionText: '만남에 있어 가장 중요하게 보는 가치는?', type: QuestionType.fixed, answers: [ Answer(text: '외모', fixedScore: 7), Answer(text: '집안', fixedScore: 4), Answer(text: '성격', fixedScore: 7), Answer(text: '재력', fixedScore: 5), ]),
      SurveyQuestion(id: 'C2', category: '만남', questionText: '나의 가장 큰 매력 포인트는?', type: QuestionType.fixed, answers: [ Answer(text: '외모', fixedScore: 7), Answer(text: '지식', fixedScore: 5), Answer(text: '성격', fixedScore: 7), Answer(text: '재력', fixedScore: 6), ]),
      SurveyQuestion(id: 'C3', category: '만남', questionText: '나는 장거리 연애가', type: QuestionType.none, answers: [ Answer(text: '불가능해요'), Answer(text: '해봐야 알 것 같아요'), Answer(text: '상대에 따라 달라요'), Answer(text: '가능해요'), ]),
      SurveyQuestion(id: 'C4', category: '만남', questionText: '만남에 있어 상대방과 나이차에 대해', type: QuestionType.none, answers: [ Answer(text: '상관없어요'), Answer(text: '연하가 좋아요'), Answer(text: '연상이 좋아요'), Answer(text: '동갑이 좋아요'), ]),
      SurveyQuestion(id: 'C5', category: '만남', questionText: '헤어지고 새로운 인연을 만드는데 걸리는 기간', type: QuestionType.none, answers: [ Answer(text: '만난 기간 이상'), Answer(text: '3~6개월'), Answer(text: '좋은 사람이 있다면'), Answer(text: '헤어지고 다음 날 바로'), ]),
      SurveyQuestion(id: 'C6', category: '만남', questionText: '전 애인과의 재회 가능한가요?', type: QuestionType.fixed, answers: [ Answer(text: '절대 불가', fixedScore: 8), Answer(text: '이유가 해결되면 가능', fixedScore: 5), Answer(text: '상대방이 원하면 고려', fixedScore: 3), Answer(text: '교제 기간에 따라 다름', fixedScore: 1), ]),
      SurveyQuestion(id: 'C7', category: '만남', questionText: '스킨십에 대한 생각은 어떤가요?', type: QuestionType.none, answers: [ Answer(text: '결혼 전 관계 불가'), Answer(text: '상의 후 결정'), Answer(text: '천천히 발전'), Answer(text: '화끈한 스킨십'), ]),
      SurveyQuestion(id: 'C8', category: '만남', questionText: '종교 극복할 수 있나요?', type: QuestionType.none, answers: [ Answer(text: '종교인과 교제 X'), Answer(text: '상대 종교 존중'), Answer(text: '상관 없음'), Answer(text: '같은 종교 선호'), ]),
      SurveyQuestion(id: 'C9', category: '만남', questionText: '나는 보통 연애를 이렇게 시작해요', type: QuestionType.none, answers: [ Answer(text: '자연스러운 만남'), Answer(text: '지인 소개'), Answer(text: '만남 앱'), Answer(text: '결혼정보회사'), ]),
      SurveyQuestion(id: 'C10', category: '만남', questionText: '상대방과 썸타는 기간이 어떻게 되나요?', type: QuestionType.none, answers: [ Answer(text: '1~2주'), Answer(text: '2~4주'), Answer(text: '1달 이상'), Answer(text: '3개월 이상'), ]),

      // --- 연애(D) ---
      SurveyQuestion(id: 'D1', category: '연애', questionText: '나에게 사랑이란?', type: QuestionType.none, answers: [ Answer(text: '인정과 응원'), Answer(text: '경제적 공동체'), Answer(text: '편안한 휴식'), Answer(text: '육체적 관계'), ]),
      SurveyQuestion(id: 'D2', category: '연애', questionText: '나의 연애 시작 기준은?', type: QuestionType.fixed, answers: [ Answer(text: '나 혼자 좋아해도 연애', fixedScore: 1), Answer(text: '서로 호감 인지', fixedScore: 3), Answer(text: '스킨십 시작', fixedScore: 6), Answer(text: '교제 약속', fixedScore: 8), ]),
      SurveyQuestion(id: 'D3', category: '연애', questionText: '나의 연애 스타일은?', type: QuestionType.none, answers: [ Answer(text: '열정적'), Answer(text: '방목형'), Answer(text: '친구 같은'), Answer(text: '헌신적'), ]),
      SurveyQuestion(id: 'D4', category: '연애', questionText: '일주일에 얼마나 자주 만나고 싶나요?', type: QuestionType.none, answers: [ Answer(text: '주말에만'), Answer(text: '주 1 ~ 2회'), Answer(text: '주 3 ~ 4회'), Answer(text: '익숙해지면 가끔'), ]),
      SurveyQuestion(id: 'D5', category: '연애', questionText: '나는 연애 경험이', type: QuestionType.none, answers: [ Answer(text: '없어요'), Answer(text: '1 ~ 2회'), Answer(text: '3 ~ 4회'), Answer(text: '5회 이상'), ]),
      SurveyQuestion(id: 'D6', category: '연애', questionText: '연애를 가장 오래 지속한 기간은', type: QuestionType.fixed, answers: [ Answer(text: '3개월 미만', fixedScore: 3), Answer(text: '3개월 ~ 1년 미만', fixedScore: 6), Answer(text: '1년 이상 ~ 3년 미만', fixedScore: 8), Answer(text: '3년 이상', fixedScore: 9), ]),
      SurveyQuestion(id: 'D7', category: '연애', questionText: '나의 마지막 연애는', type: QuestionType.none, answers: [ Answer(text: '3개월 이내'), Answer(text: '3개월 ~ 1년 사이'), Answer(text: '1년 초과'), Answer(text: '2년 초과'), ]),
      SurveyQuestion(id: 'D8', category: '연애', questionText: '연애 상대방으로 어떤 스타일이 좋나요?', type: QuestionType.fixed, answers: [ Answer(text: '연애 경험 없는 사람', fixedScore: 0), Answer(text: '연애 경험 자주 있는 사람', fixedScore: 0), Answer(text: '1년 전후 경험 다수', fixedScore: 8), Answer(text: '긴 연애 1-2번', fixedScore: 9), ]),
      SurveyQuestion(id: 'D9', category: '연애', questionText: '나는 남사친/여사친을 단둘이 만나는 것에', type: QuestionType.fixed, answers: [ Answer(text: '절대 안됨', fixedScore: 10), Answer(text: '식사/커피 외 불가', fixedScore: 8), Answer(text: '소개해주면 괜찮음', fixedScore: 5), Answer(text: '친구라면 괜찮음', fixedScore: 1), ]),
      SurveyQuestion(id: 'D10', category: '연애', questionText: '데이트 비용은', type: QuestionType.fixed, answers: [ Answer(text: '내고 싶지 않아요', fixedScore: 1), Answer(text: '커피정도는 살게요', fixedScore: 3), Answer(text: '상황에 맞춰 내고 싶어요', fixedScore: 6), Answer(text: '제가 전부 다 내고 싶어요', fixedScore: 10), ]),

      // --- 결혼(E) ---
      SurveyQuestion(id: 'E1', category: '결혼', questionText: '나는 결혼에 대해', type: QuestionType.fixed, answers: [ Answer(text: '필요 없다고 생각해요', fixedScore: 1), Answer(text: '깊이 생각해본적 없어요', fixedScore: 3), Answer(text: '상대에 따라 다르다 생각해요', fixedScore: 6), Answer(text: '인생에 반드시 필요하다 생각해요', fixedScore: 8), ]),
      SurveyQuestion(id: 'E2', category: '결혼', questionText: '나의 결혼 가치관은', type: QuestionType.fixed, answers: [ Answer(text: '결혼제도는 없어도 되요', fixedScore: 1), Answer(text: '손해를 보는 결혼은 싫어요', fixedScore: 3), Answer(text: '반반 결혼이면 할거에요', fixedScore: 6), Answer(text: '손해를 감수하고도 하고 싶어요', fixedScore: 9), ]),
      SurveyQuestion(id: 'E3', category: '결혼', questionText: '결혼 시 가장 중요하게 보는 것은', type: QuestionType.none, answers: [ Answer(text: '정량적인 기준'), Answer(text: '가치관'), Answer(text: '사랑과 행복'), Answer(text: '반반추구'), ]),
      SurveyQuestion(id: 'E4', category: '결혼', questionText: '저는 결혼을 이 때 하고 싶어요', type: QuestionType.fixed, answers: [ Answer(text: '하고 싶지 않아요', fixedScore: 1), Answer(text: '경제적 능력이 갖춰졌을 때', fixedScore: 7), Answer(text: '조건 없이 사람만 괜찮다면', fixedScore: 9), Answer(text: '조건만 맞다면 하고 싶어요', fixedScore: 7), ]),
      SurveyQuestion(id: 'E5', category: '결혼', questionText: '내가 선호하는 결혼식은', type: QuestionType.none, answers: [ Answer(text: '생략할 수 있어요'), Answer(text: '상대방 의견에 따름'), Answer(text: '스몰웨딩'), Answer(text: '남부럽지 않게'), ]),
      SurveyQuestion(id: 'E6', category: '결혼', questionText: '결혼 전 경제관념에 대해 어떻게 생각하나요?', type: QuestionType.none, answers: [ Answer(text: '빚이 있다면 결혼 X'), Answer(text: '아낌없이 소비'), Answer(text: '아끼면서 생활'), Answer(text: '빚이 있다면 같이 상환'), ]),
      SurveyQuestion(id: 'E7', category: '결혼', questionText: '결혼하면 가사 분담은', type: QuestionType.fixed, answers: [ Answer(text: '배우자가 전담', fixedScore: 3), Answer(text: '여유로운 사람이', fixedScore: 8), Answer(text: '내가 더 할 수 있음', fixedScore: 10), Answer(text: '공평하게 반반', fixedScore: 3), ]),
      SurveyQuestion(id: 'E8', category: '결혼', questionText: '자녀 계획은 어떻게 되나요?', type: QuestionType.fixed, answers: [ Answer(text: '딩크 : 낳고 싶지 않아요', fixedScore: 1), Answer(text: '1명', fixedScore: 5), Answer(text: '2명 이상', fixedScore: 9), Answer(text: '배우자와 상의 후 결정', fixedScore: 7), ]),
      SurveyQuestion(id: 'E9', category: '결혼', questionText: '만약, 부모가 된다면', type: QuestionType.fixed, answers: [ Answer(text: '자녀와 나의 인생은 별개', fixedScore: 1), Answer(text: '성인까지만 지원', fixedScore: 6), Answer(text: '모든 것을 지원', fixedScore: 9), Answer(text: '친구처럼 편안하게', fixedScore: 7), ]),
      SurveyQuestion(id: 'E10', category: '결혼', questionText: '결혼 후 맞벌이에 대해서', type: QuestionType.none, answers: [ Answer(text: '배우자는 가사 집중'), Answer(text: '배우자 소득 높으면 안 함'), Answer(text: '육아 시 안 함'), Answer(text: '맞벌이 상관 없음'), ]),
    ];
  }
}