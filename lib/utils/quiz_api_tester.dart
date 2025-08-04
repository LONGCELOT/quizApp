import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test General Quiz API with the specific token provided by user
class QuizAPITester {
  
  static const String testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTAsInBob25lIjoiODY1ODU4OTEiLCJpYXQiOjE3NTMwNjc3NTksImV4cCI6MTc4NDYyNTM1OX0.eDzD5qw-TZW2BytukHGAghibMY0jaomL4KqgQvOT2Lc';
  
  /// Test the specific General Quiz API endpoint with the provided token
  static Future<void> testGeneralQuizWithToken() async {
    print('🧪 TESTING GENERAL QUIZ API WITH PROVIDED TOKEN');
    print('=' * 60);
    print('🔗 URL: ${ApiConstants.baseUrl}${ApiConstants.generalQuizEndpoint}');
    print('🔑 Token: ${testToken.substring(0, 20)}...');
    print('=' * 60);
    
    try {
      // Direct HTTP call
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.generalQuizEndpoint}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $testToken',
      };
      
      print('📡 Making HTTP GET request...');
      final response = await http.get(url, headers: headers);
      
      print('📊 Status Code: ${response.statusCode}');
      print('📋 Response Length: ${response.body.length} characters');
      
      if (response.statusCode == 200) {
        print('✅ API Response: SUCCESS');
        
        // Parse the response
        final jsonData = json.decode(response.body);
        print('🎯 Response Type: ${jsonData.runtimeType}');
        
        if (jsonData is List) {
          print('✅ Response is a List (Array) with ${jsonData.length} items');
          
          if (jsonData.isNotEmpty) {
            print('📝 First question sample:');
            print('   ID: ${jsonData[0]['id']}');
            print('   Code: ${jsonData[0]['code']}');
            print('   Question (EN): ${jsonData[0]['questionEn']}');
            print('   Answer Code: ${jsonData[0]['answerCode']}');
            print('   Options: ${jsonData[0]['optionEn']}');
          }
          
          print('\\n🎉 GENERAL QUIZ API IS WORKING CORRECTLY!');
          print('📚 Found ${jsonData.length} questions');
          
        } else {
          print('⚠️ Response is not a List, its a ${jsonData.runtimeType}');
          print('📋 Response: $jsonData');
        }
        
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('📋 Error Response: ${response.body}');
        
        if (response.statusCode == 401) {
          print('💡 401 Unauthorized - Token might be expired or invalid');
        } else if (response.statusCode == 404) {
          print('💡 404 Not Found - Endpoint might not exist');
        }
      }
      
    } catch (e) {
      print('❌ Test Failed: $e');
    }
    
    print('\n' + '=' * 60);
  }
  
  /// Test using the ApiService method
  static Future<void> testApiServiceMethod() async {
    print('🔧 TESTING API SERVICE METHOD');
    print('-' * 30);
    
    try {
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: 1,
        token: testToken,
      );
      
      print('✅ ApiService Success: Got ${questions.length} questions');
      
      if (questions.isNotEmpty) {
        print('📝 Sample question: ${questions[0]}');
      }
      
    } catch (e) {
      print('❌ ApiService Failed: $e');
    }
  }
  
  /// Run both tests
  static Future<void> runFullTest() async {
    await testGeneralQuizWithToken();
    await testApiServiceMethod();
  }
}
