import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'app_logger.dart';

class QuizTestHelper {
  static Future<void> testQuizAPIs() async {
    AppLogger.info('🧪 Testing Quiz APIs...');
    
    // Test each category
    for (int categoryId = 1; categoryId <= 8; categoryId++) {
      try {
        AppLogger.info('📋 Testing Category $categoryId...');
        final questions = await ApiService.getQuestionsByCategory(categoryId: categoryId);
        AppLogger.info('✅ Category $categoryId: ${questions.length} questions loaded');
        
        if (questions.isNotEmpty) {
          final firstQuestion = questions.first;
          print('   Sample question: ${firstQuestion['question']?.toString().substring(0, 50)}...');
          print('   Options: ${firstQuestion['options']?.length ?? 0}');
        }
      } catch (e) {
        print('❌ Category $categoryId failed: $e');
      }
    }
    
    print('🧪 API Testing complete!');
  }
  
  static void logQuestionStructure(dynamic question) {
    if (question is Map) {
      print('Question structure:');
      print('  - id: ${question['id']}');
      print('  - question: ${question['question']}');
      print('  - answer: ${question['answer']}');
      print('  - options: ${question['options']}');
      print('  - keys: ${question.keys.toList()}');
    }
  }
  
  static Future<void> testAPIEndpoints() async {
    print('🔗 Testing API Endpoints...');
    
    final endpoints = [
      'Category 1 (General): ${ApiConstants.generalQuizEndpoint}',
      'Category 2 (IQ): ${ApiConstants.iqTestEndpoint}',
      'Category 3 (EQ): ${ApiConstants.eqTestEndpoint}',
      'Category 4 (World History): ${ApiConstants.worldHistoryEndpoint}',
      'Category 5 (Khmer History): ${ApiConstants.khmerHistoryEndpoint}',
      'Category 6 (English Grammar): ${ApiConstants.englishGrammarEndpoint}',
      'Category 7 (Math): ${ApiConstants.mathTestEndpoint}',
      'Category 8 (Physics): ${ApiConstants.physicTestEndpoint}',
    ];
    
    for (String endpoint in endpoints) {
      print('📌 $endpoint');
    }
  }
}
