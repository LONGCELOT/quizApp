import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _categories = ['All', 'General Knowledge', 'IQ Test', 'EQ Test', 'World History Test', 'Khmer History Test', 'Englsih Grammar Test', 'Math Test', 'Physics Test'];
  
  // Sample test history data
  final List<TestHistory> _testHistory = [
    TestHistory(
      id: 1,
      category: 'General Knowledge',
      title: 'General Knowledge Test #1',
      score: 8,
      totalQuestions: 10,
      percentage: 80,
      dateTaken: DateTime.now().subtract(const Duration(days: 1)),
      duration: '5:30',
      questions: [
        QuestionHistory(
          question: 'What is the capital of France?',
          options: ['London', 'Berlin', 'Paris', 'Madrid'],
          correctAnswer: 'Paris',
          userAnswer: 'Paris',
          isCorrect: true,
        ),
        QuestionHistory(
          question: 'Which planet is known as the Red Planet?',
          options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
          correctAnswer: 'Mars',
          userAnswer: 'Mars',
          isCorrect: true,
        ),
        QuestionHistory(
          question: 'Who painted the Mona Lisa?',
          options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Monet'],
          correctAnswer: 'Da Vinci',
          userAnswer: 'Picasso',
          isCorrect: false,
        ),
      ],
    ),
    TestHistory(
      id: 2,
      category: 'IQ Test',
      title: 'IQ Test #1',
      score: 7,
      totalQuestions: 10,
      percentage: 70,
      dateTaken: DateTime.now().subtract(const Duration(days: 3)),
      duration: '7:15',
      questions: [
        QuestionHistory(
          question: 'What is H2O?',
          options: ['Oxygen', 'Hydrogen', 'Water', 'Carbon'],
          correctAnswer: 'Water',
          userAnswer: 'Water',
          isCorrect: true,
        ),
        QuestionHistory(
          question: 'What is the speed of light?',
          options: ['300,000 km/s', '150,000 km/s', '450,000 km/s', '200,000 km/s'],
          correctAnswer: '300,000 km/s',
          userAnswer: '150,000 km/s',
          isCorrect: false,
        ),
      ],
    ),
    TestHistory(
      id: 3,
      category: 'Math',
      title: 'Math Challenge #1',
      score: 9,
      totalQuestions: 10,
      percentage: 90,
      dateTaken: DateTime.now().subtract(const Duration(days: 7)),
      duration: '4:45',
      questions: [
        QuestionHistory(
          question: 'What is 15 × 8?',
          options: ['120', '125', '130', '115'],
          correctAnswer: '120',
          userAnswer: '120',
          isCorrect: true,
        ),
      ],
    ),
    TestHistory(
      id: 4,
      category: 'History',
      title: 'World History Quiz',
      score: 6,
      totalQuestions: 10,
      percentage: 60,
      dateTaken: DateTime.now().subtract(const Duration(days: 10)),
      duration: '8:20',
      questions: [
        QuestionHistory(
          question: 'When did World War II end?',
          options: ['1944', '1945', '1946', '1947'],
          correctAnswer: '1945',
          userAnswer: '1944',
          isCorrect: false,
        ),
      ],
    ),
  ];

  List<TestHistory> get filteredHistory {
    if (_selectedFilter == 'All') {
      return _testHistory;
    }
    return _testHistory.where((test) => test.category == _selectedFilter).toList();
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Test History', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter by: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        bool isSelected = category == _selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = category;
                              });
                            },
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Test History List
          Expanded(
            child: filteredHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No test history found',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete a quiz to see your history here',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final test = filteredHistory[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TestDetailScreen(testHistory: test),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            test.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            test.category,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getScoreColor(test.percentage).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getScoreColor(test.percentage).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '${test.percentage}%',
                                        style: TextStyle(
                                          color: _getScoreColor(test.percentage),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.quiz, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${test.score}/${test.totalQuestions} correct',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      test.duration,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _formatDate(test.dateTaken),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TestDetailScreen extends StatelessWidget {
  final TestHistory testHistory;
  
  const TestDetailScreen({super.key, required this.testHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Test Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testHistory.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      testHistory.category,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryItem('Score', '${testHistory.score}/${testHistory.totalQuestions}', Icons.quiz),
                        const SizedBox(width: 24),
                        _buildSummaryItem('Percentage', '${testHistory.percentage}%', Icons.percent),
                        const SizedBox(width: 24),
                        _buildSummaryItem('Duration', testHistory.duration, Icons.access_time),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Questions and Answers
            const Text(
              'Questions & Answers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: testHistory.questions.length,
              itemBuilder: (context, index) {
                final question = testHistory.questions[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: question.isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    question.isCorrect ? Icons.check_circle : Icons.cancel,
                                    size: 16,
                                    color: question.isCorrect ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    question.isCorrect ? 'Correct' : 'Incorrect',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: question.isCorrect ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Q${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.question,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        ...question.options.asMap().entries.map((entry) {
                          int optionIndex = entry.key;
                          String option = entry.value;
                          bool isCorrect = option == question.correctAnswer;
                          bool isUserAnswer = option == question.userAnswer;
                          
                          Color backgroundColor = Colors.transparent;
                          Color borderColor = Colors.grey.shade300;
                          Color textColor = Colors.black87;
                          
                          if (isCorrect) {
                            backgroundColor = Colors.green.withOpacity(0.1);
                            borderColor = Colors.green;
                            textColor = Colors.green.shade700;
                          } else if (isUserAnswer && !isCorrect) {
                            backgroundColor = Colors.red.withOpacity(0.1);
                            borderColor = Colors.red;
                            textColor = Colors.red.shade700;
                          }
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              border: Border.all(color: borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${String.fromCharCode(65 + optionIndex)}.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(color: textColor),
                                  ),
                                ),
                                if (isCorrect)
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                if (isUserAnswer && !isCorrect)
                                  const Icon(Icons.cancel, color: Colors.red, size: 20),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// Data Models
class TestHistory {
  final int id;
  final String category;
  final String title;
  final int score;
  final int totalQuestions;
  final int percentage;
  final DateTime dateTaken;
  final String duration;
  final List<QuestionHistory> questions;

  TestHistory({
    required this.id,
    required this.category,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.dateTaken,
    required this.duration,
    required this.questions,
  });
}

class QuestionHistory {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String userAnswer;
  final bool isCorrect;

  QuestionHistory({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
  });
}
