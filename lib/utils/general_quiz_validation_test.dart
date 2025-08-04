import '../services/api_service.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';
import 'dart:convert';

/// Test the General Quiz API with the exact data format from Postman
class GeneralQuizValidationTest {
  
  /// Sample data from Postman - exact format returned by API
  static const String postmanResponseSample = '''
[
    {
        "id": 1,
        "code": "PAMSZ99A",
        "questionEn": "How many continents are there?",
        "questionKh": "មានទ្វីបប៉ុន្មាននៅលើពិភពលោក?",
        "questionZh": "世界上有几个大洲？",
        "answerCode": "7",
        "optionEn": ["5", "6", "7", "8"],
        "optionKh": ["5", "6", "7", "8"],
        "optionZh": ["5", "6", "7", "8"],
        "categoryId": 1
    },
    {
        "id": 2,
        "code": "XF24JSVP",
        "questionEn": "What is the capital of France?",
        "questionKh": "ទីក្រុងរបស់ប្រទេសបារាំងគឺអ្វី?",
        "questionZh": "法国的首都是哪里？",
        "answerCode": "Paris",
        "optionEn": ["Paris", "London", "Berlin", "Madrid"],
        "optionKh": ["Paris", "London", "Berlin", "Madrid"],
        "optionZh": ["Paris", "London", "Berlin", "Madrid"],
        "categoryId": 1
    }
]
''';

  /// Test if our current API service can parse the Postman response
  static Future<void> testPostmanDataParsing() async {
    print('🧪 TESTING POSTMAN DATA PARSING');
    print('=' * 50);
    
    try {
      // Parse the sample response exactly as our API service would
      final jsonData = json.decode(postmanResponseSample);
      print('🎯 Parsed Data Type: ${jsonData.runtimeType}');
      
      if (jsonData is List) {
        print('✅ Response is a List with ${jsonData.length} items');
        
        // Test converting to our expected format
        final questions = List<dynamic>.from(jsonData);
        print('✅ Successfully converted to List<dynamic>');
        
        // Verify question structure
        if (questions.isNotEmpty) {
          final firstQuestion = questions[0];
          print('📝 First Question Structure:');
          print('   ID: ${firstQuestion['id']}');
          print('   Code: ${firstQuestion['code']}');
          print('   Question (EN): ${firstQuestion['questionEn']}');
          print('   Answer Code: ${firstQuestion['answerCode']}');
          print('   Options (EN): ${firstQuestion['optionEn']}');
          print('   Category ID: ${firstQuestion['categoryId']}');
        }
        
        print('🎉 POSTMAN DATA PARSING: SUCCESS');
        
      } else {
        print('❌ Response is not a List: ${jsonData.runtimeType}');
      }
      
    } catch (e) {
      print('❌ Postman data parsing failed: $e');
    }
    
    print('=' * 50);
  }
  
  /// Test the actual API call
  static Future<void> testRealAPICall() async {
    print('🌐 TESTING REAL API CALL');
    print('-' * 30);
    
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No token available');
        return;
      }
      
      print('🔑 Token available');
      print('🔗 Calling: ${ApiConstants.baseUrl}${ApiConstants.generalQuizEndpoint}');
      
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: 1,
        token: token,
      );
      
      print('✅ API Call Success: ${questions.length} questions received');
      
      if (questions.isNotEmpty) {
        print('📝 Sample question from API:');
        print('   ${questions[0]}');
      }
      
    } catch (e) {
      print('❌ Real API call failed: $e');
      
      // Provide debugging info
      if (e.toString().contains('List<dynamic>')) {
        print('💡 This suggests the API is returning a List but our code expects a Map');
      } else if (e.toString().contains('Map<String, dynamic>')) {
        print('💡 This suggests a type conversion issue');
      }
    }
  }
  
  /// Run both tests
  static Future<void> runFullValidation() async {
    print('🔬 GENERAL QUIZ API VALIDATION TEST');
    print('🎯 Based on Postman Response Data');
    print('=' * 60);
    
    await testPostmanDataParsing();
    print('');
    await testRealAPICall();
    
    print('=' * 60);
    print('🏁 VALIDATION TEST COMPLETED');
  }
}
