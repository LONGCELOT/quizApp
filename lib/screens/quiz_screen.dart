import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../utils/app_logger.dart';

class QuizScreen extends StatefulWidget {
  final List<dynamic> questions;
  final String? categoryName;
  final int? categoryId;
  
  const QuizScreen({
    super.key, 
    required this.questions,
    this.categoryName,
    this.categoryId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  Map<int, String> answers = {};
  int timer = 15;
  Timer? countdown;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdown?.cancel();
    timer = 15;
    countdown = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      setState(() {
        if (timer > 0) {
          timer--;
        } else {
          timerTick.cancel();
          nextQuestion();
        }
      });
    });
  }

  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
      });
      startTimer();
    } else {
      countdown?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(answers: answers, questions: widget.questions),
        ),
      );
    }
  }

  void prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      startTimer();
    }
  }

  void selectAnswer(String answer) {
    setState(() {
      answers[widget.questions[currentIndex]['id']] = answer;
    });
  }

  void skipQuestion() {
    nextQuestion();
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName != null 
            ? '${widget.categoryName} - Question ${currentIndex + 1}/${widget.questions.length}'
            : 'Question ${currentIndex + 1}/${widget.questions.length}',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: skipQuestion,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Title under the question box
            Text(
              'Choose the correct answer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Card container for question + options
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 138, 224),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        question['questionEn'] ?? question['question'] ?? 'Question not available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: timer / 15,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(4, (i) {
                      // Use optionEn from API, fallback to options for compatibility
                      List<dynamic> options = question['optionEn'] ?? question['options'] ?? [];
                      if (i >= options.length) return Container(); // Skip if not enough options
                      
                      String opt = options[i]?.toString() ?? '';
                      String optLabel = String.fromCharCode(65 + i);
                      bool isSelected = answers[question['id']] == opt;
                      return GestureDetector(
                        onTap: () => selectAnswer(opt),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected ? Colors.blue.shade50 : Colors.white,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                                child: Text(optLabel, style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentIndex > 0 ? prevQuestion : null,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    child: const Text('Next'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final Map<int, String> answers;
  final List<dynamic> questions;

  const ResultScreen({super.key, required this.answers, required this.questions});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submitMessage;

  @override
  Widget build(BuildContext context) {
    int correct = 0;
    for (var q in widget.questions) {
      // Use answerCode from API, fallback to answer for compatibility
      String correctAnswer = q['answerCode'] ?? q['answer'] ?? '';
      if (widget.answers[q['id']] == correctAnswer) correct++;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You scored $correct / ${widget.questions.length}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (_submitMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: _isSubmitted ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isSubmitted ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _submitMessage!,
                  style: TextStyle(
                    color: _isSubmitted ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (!_isSubmitted) ...[
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitResults,
                child: _isSubmitting
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Submit Results'),
              ),
              const SizedBox(height: 10),
            ],
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _submitResults() async {
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });

    try {
      // Get the token
      final token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          _isSubmitting = false;
          _submitMessage = 'Please login to submit results';
        });
        return;
      }

      // Calculate correct answers
      int correct = 0;
      for (var q in widget.questions) {
        String correctAnswer = q['answerCode'] ?? q['answer'] ?? '';
        if (widget.answers[q['id']] == correctAnswer) correct++;
      }

      // Submit the results (categoryId 1 for General Quiz)
      final result = await ApiService.submitQuiz(
        categoryId: 1,
        totalQuestions: widget.questions.length,
        totalCorrect: correct,
        token: token,
      );

      AppLogger.info('🎯 Quiz Submit Response: ', result);
      
      // The API now returns the submitted data, including our calculated score
      final apiScore = result['score'];
      final submittedCorrect = result['totalCorrect'];
      final submittedTotal = result['totalQuestion'];

      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
        _submitMessage = 'Results submitted successfully!\nScore: $apiScore%\n($submittedCorrect/$submittedTotal correct)';
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _submitMessage = 'Failed to submit results: ${e.toString()}';
      });
    }
  }
}
