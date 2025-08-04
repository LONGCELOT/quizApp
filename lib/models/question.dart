class Question {
  final int id;
  final String question;
  final String answer;
  final List<String> options;

  Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'options': options,
    };
  }
}

class QuizData {
  final List<Question> questions;
  final String categoryName;
  final int categoryId;

  QuizData({
    required this.questions,
    required this.categoryName,
    required this.categoryId,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      questions: (json['questions'] as List? ?? [])
          .map((questionJson) => Question.fromJson(questionJson))
          .toList(),
      categoryName: json['categoryName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
    );
  }
}
