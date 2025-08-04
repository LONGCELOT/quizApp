import '../services/api_service.dart';
import '../services/token_service.dart';
import '../constants/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileAPIDebugHelper {
  
  /// Test different HTTP methods and request formats for profile update
  static Future<void> debugProfileUpdateAPI() async {
    print('🔍 DEBUGGING PROFILE UPDATE API...');
    print('=' * 60);
    
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      
      print('🔑 Token: Available');
      print('🌐 Base URL: ${ApiConstants.baseUrl}');
      print('📍 Endpoint: ${ApiConstants.userUpdateProfileEndpoint}');
      print('🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.userUpdateProfileEndpoint}');
      
      // Test data
      final testData = {
        'firstName': 'TestFirst',
        'lastName': 'TestLast',
      };
      
      print('\n📝 Test Data: $testData');
      
      // Test 1: POST method
      print('\n🧪 TEST 1: POST method');
      await _testMethod('POST', token, testData);
      
      // Test 2: PUT method  
      print('\n🧪 TEST 2: PUT method');
      await _testMethod('PUT', token, testData);
      
      // Test 3: PATCH method
      print('\n🧪 TEST 3: PATCH method');
      await _testMethod('PATCH', token, testData);
      
      // Test 4: Check if endpoint exists with GET
      print('\n🧪 TEST 4: GET method (check if endpoint exists)');
      await _testMethod('GET', token, null);
      
    } catch (e) {
      print('❌ Debug error: $e');
    }
    
    print('\n' + '=' * 60);
    print('🏁 DEBUGGING COMPLETED');
    print('=' * 60);
  }
  
  static Future<void> _testMethod(String method, String token, Map<String, dynamic>? data) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.userUpdateProfileEndpoint}');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        default:
          throw Exception('Unsupported method: $method');
      }
      
      print('   📊 $method Response:');
      print('   📋 Status Code: ${response.statusCode}');
      print('   📄 Headers: ${response.headers}');
      
      if (response.body.length < 500) {
        print('   📝 Body: ${response.body}');
      } else {
        print('   📝 Body: ${response.body.substring(0, 200)}... (truncated)');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('   ✅ $method: SUCCESS');
      } else {
        print('   ❌ $method: FAILED (${response.statusCode})');
      }
      
    } catch (e) {
      print('   ❌ $method: ERROR - $e');
    }
  }
  
  /// Test with our current API service method
  static Future<void> testCurrentImplementation() async {
    print('🧪 Testing Current API Service Implementation...');
    
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return;
      }
      
      await ApiService.updateUserProfile(
        token: token,
        firstName: 'TestFirst_${DateTime.now().millisecondsSinceEpoch}',
        lastName: 'TestLast_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      print('✅ Current implementation: SUCCESS');
      
    } catch (e) {
      print('❌ Current implementation: FAILED - $e');
    }
  }
  
  /// Comprehensive test
  static Future<void> runFullDiagnostic() async {
    print('🏥 PROFILE UPDATE API DIAGNOSTIC');
    print('=' * 60);
    
    await debugProfileUpdateAPI();
    
    print('\n🔬 Testing Current Implementation:');
    await testCurrentImplementation();
    
    print('\n💡 RECOMMENDATIONS:');
    print('1. Check which HTTP method returned success (POST/PUT/PATCH)');
    print('2. Verify the exact endpoint URL with your backend team');
    print('3. Check if additional headers or authentication is required');
    print('4. Validate the request body format expected by the API');
  }
}
