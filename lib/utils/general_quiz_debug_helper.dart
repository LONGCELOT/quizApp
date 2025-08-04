import '../services/api_service.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Debug helper specifically for General Quiz API
class GeneralQuizAPIDebugHelper {
  
  /// Test the General Quiz API endpoint specifically
  static Future<void> testGeneralQuizAPI() async {
    print('🧪 TESTING GENERAL QUIZ API');
    print('=' * 60);
    print('📍 Endpoint: ${ApiConstants.generalQuizEndpoint}');
    print('🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.generalQuizEndpoint}');
    print('🎯 Method: GET');
    print('=' * 60);
    
    try {
      // Get token
      final token = await TokenService.getToken();
      print('🔑 Token: ${token != null ? 'Available' : 'No token found'}');
      
      // Test 1: Direct HTTP call
      print('\n📡 TEST 1: Direct HTTP GET call');
      await _testDirectCall(token);
      
      // Test 2: Using ApiService method
      print('\n🔧 TEST 2: Using ApiService.getQuestionsByCategory()');
      await _testApiServiceCall(token);
      
      // Test 3: Test without authentication
      print('\n🚫 TEST 3: Without authentication (no token)');
      await _testDirectCall(null);
      
    } catch (e) {
      print('❌ General Quiz API test failed: $e');
    }
    
    print('\n' + '=' * 60);
    print('🏁 GENERAL QUIZ API TEST COMPLETED');
    print('=' * 60);
  }
  
  static Future<void> _testDirectCall(String? token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.generalQuizEndpoint}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      print('   🌐 URL: $url');
      print('   📝 Headers: $headers');
      
      final response = await http.get(url, headers: headers);
      
      print('   📊 Status Code: ${response.statusCode}');
      print('   📄 Response Headers: ${response.headers}');
      
      if (response.body.length < 1000) {
        print('   📋 Response Body: ${response.body}');
      } else {
        print('   📋 Response Body: ${response.body.substring(0, 500)}... (truncated)');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('   ✅ Direct call: SUCCESS');
        
        // Try to parse the response
        try {
          final data = json.decode(response.body);
          print('   🔍 Response type: ${data.runtimeType}');
          if (data is Map) {
            print('   🗂️ Response keys: ${data.keys.toList()}');
            
            // Check for questions
            if (data['questions'] != null) {
              print('   📚 Found questions: ${data['questions'].length} items');
            } else if (data['data'] != null) {
              print('   📚 Found data: ${data['data'].length} items');
            } else {
              print('   ⚠️ No questions or data array found');
            }
          }
        } catch (parseError) {
          print('   ❌ Failed to parse JSON: $parseError');
        }
      } else {
        print('   ❌ Direct call: FAILED (${response.statusCode})');
        if (response.statusCode == 401) {
          print('   💡 401 Unauthorized - Check authentication token');
        } else if (response.statusCode == 404) {
          print('   💡 404 Not Found - Check endpoint URL');
        } else if (response.statusCode == 500) {
          print('   💡 500 Server Error - Backend issue');
        }
      }
      
    } catch (e) {
      print('   ❌ Direct call: ERROR - $e');
    }
  }
  
  static Future<void> _testApiServiceCall(String? token) async {
    try {
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: 1, // General Quiz category
        token: token,
      );
      
      print('   ✅ ApiService call: SUCCESS');
      print('   📚 Received ${questions.length} questions');
      
      if (questions.isNotEmpty) {
        print('   🔍 First question sample: ${questions[0]}');
      }
      
    } catch (e) {
      print('   ❌ ApiService call: FAILED - $e');
    }
  }
  
  /// Quick test specifically for category 1 (General Quiz)
  static Future<void> quickTest() async {
    print('⚡ QUICK GENERAL QUIZ TEST');
    print('-' * 30);
    
    try {
      final token = await TokenService.getToken();
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: 1,
        token: token,
      );
      
      print('✅ SUCCESS: Got ${questions.length} questions');
      
    } catch (e) {
      print('❌ FAILED: $e');
    }
  }
}
