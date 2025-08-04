import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_data.dart';
import '../constants/api_constants.dart';
import 'token_service.dart';

class ApiService {
  // Common headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add authorization header when token is available
  static Map<String, String> _headersWithAuth(String? token) {
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get headers with stored token automatically
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenService.getToken();
    return _headersWithAuth(token);
  }

  // Make authenticated request using stored token
  static Future<http.Response> authenticatedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse(ApiConstants.buildUrl(endpoint));
    final headers = await _getAuthHeaders();

    http.Response response;
    
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // Handle token expiration
    if (response.statusCode == 401) {
      await TokenService.clearStorage();
      throw Exception('Authentication failed. Please login again.');
    }

    return response;
  }

  // GET request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    final url = Uri.parse(ApiConstants.buildUrl(endpoint));
    return await http.get(url, headers: _headersWithAuth(token));
  }

  // POST request
  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse(ApiConstants.buildUrl(endpoint));
    return await http.post(
      url,
      headers: _headersWithAuth(token),
      body: body != null ? json.encode(body) : null,
    );
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final url = Uri.parse(ApiConstants.buildUrl(endpoint));
    return await http.put(
      url,
      headers: _headersWithAuth(token),
      body: body != null ? json.encode(body) : null,
    );
  }

  // DELETE request
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    final url = Uri.parse(ApiConstants.buildUrl(endpoint));
    return await http.delete(url, headers: _headersWithAuth(token));
  }

  // Helper method to handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Fetch home data (keeping your existing functionality)
  static Future<Map<String, dynamic>> fetchHomeData() async {
    try {
      final response = await get(ApiConstants.homeEndpoint);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<Category> categories = (data['categories'] as List)
            .map((json) => Category.fromJson(json))
            .toList();

        List<BannerItem> banners = (data['banners'] as List)
            .map((json) => BannerItem.fromJson(json))
            .toList();

        List<Promotion> promotions = (data['promotions'] as List)
            .map((json) => Promotion.fromJson(json))
            .toList();

        return {
          'categories': categories,
          'banners': banners,
          'promotions': promotions,
        };
      } else {
        throw Exception('Failed to load home data');
      }
    } catch (e) {
      throw Exception('Failed to load home data: $e');
    }
  }

  // Authentication methods
  static Future<Map<String, dynamic>> login({
    required String countryCode,
    required String phone,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await post(
        ApiConstants.loginEndpoint,
        body: {
          'countryCode': countryCode,
          'phone': phone,
          'otp': otp,
          'password': password,
        },
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Login without OTP (for regular login)
  static Future<Map<String, dynamic>> loginWithPassword({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await post(
        ApiConstants.loginEndpoint,
        body: {
          'countryCode': countryCode,
          'phone': phone,
          'password': password,
        },
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String countryCode,
    required String phone,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await post(
        ApiConstants.registerEndpoint,
        body: {
          'countryCode': countryCode,
          'phone': phone,
          'otp': otp,
          'password': password,
        },
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String countryCode,
    required String phone,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await post(
        ApiConstants.resetPasswordEndpoint,
        body: {
          'countryCode': countryCode,
          'phone': phone,
          'otp': otp,
          'password': password,
        },
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  static Future<Map<String, dynamic>> sendOTP({
    required String countryCode,
    required String phone,
  }) async {
    try {
      final response = await post(
        ApiConstants.sendOtpEndpoint,
        body: {
          'countryCode': countryCode,
          'phone': phone,
        },
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Quiz methods
  static Future<Map<String, dynamic>> getQuizList({String? token}) async {
    try {
      final response = await get(ApiConstants.quizCategoriesListEndpoint, token: token);
      return handleResponse(response);
    } catch (e) {
      throw Exception('Failed to load quiz list: $e');
    }
  }

  static Future<List<dynamic>> getQuestionsByCategory({
    required int categoryId,
    String? token,
  }) async {
    try {
      final endpoint = ApiConstants.getQuestionsByCategoryEndpoint(categoryId);
      print('🔗 API Call: ${ApiConstants.baseUrl}$endpoint');
      print('🔑 Token: ${token ?? 'No token provided'}');
      
      final response = await get(endpoint, token: token);
      print('📊 Response Status: ${response.statusCode}');
      print('📋 Response Body Length: ${response.body.length} characters');
      print('📋 Response Body Preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      // Check if response is successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse JSON directly since API returns array
        final jsonData = json.decode(response.body);
        print('🎯 Parsed Data Type: ${jsonData.runtimeType}');
        
        // Check if it's a direct array (which it should be for this API)
        if (jsonData is List) {
          print('✅ Received direct questions array with ${jsonData.length} items');
          return List<dynamic>.from(jsonData);
        } else if (jsonData is Map) {
          // Fallback: if it's wrapped in an object, look for questions
          final data = jsonData as Map<String, dynamic>;
          print('🗂️ Response is object with keys: ${data.keys.toList()}');
          
          if (data['questions'] != null && data['questions'] is List) {
            final questions = data['questions'] as List;
            print('✅ Found questions array with ${questions.length} items');
            return List<dynamic>.from(questions);
          } else if (data['data'] != null && data['data'] is List) {
            final questions = data['data'] as List;
            print('✅ Found data array with ${questions.length} items');
            return List<dynamic>.from(questions);
          } else {
            print('⚠️ No questions or data array found in response');
            print('📋 Full response structure: $data');
          }
        } else {
          print('❌ Unexpected response format: ${jsonData.runtimeType}');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
      
      return [];
    } catch (e) {
      print('❌ API Error for category $categoryId: $e');
      throw Exception('Failed to load questions for category $categoryId: $e');
    }
  }

  // DEBUG: Test method to check API with a specific token (for testing only)
  static Future<List<dynamic>> testQuestionsByCategory({
    required int categoryId,
    required String testToken,
  }) async {
    try {
      final endpoint = ApiConstants.getQuestionsByCategoryEndpoint(categoryId);
      print('🧪 TEST API Call: ${ApiConstants.baseUrl}$endpoint');
      print('🔑 TEST Token: $testToken');
      
      final response = await get(endpoint, token: testToken);
      print('📊 TEST Response Status: ${response.statusCode}');
      print('📋 TEST Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = handleResponse(response);
        if (data['questions'] != null && data['questions'] is List) {
          final questions = data['questions'] as List;
          print('✅ TEST: Found ${questions.length} questions');
          return List<dynamic>.from(questions);
        }
      }
      
      return [];
    } catch (e) {
      print('❌ TEST API Error: $e');
      throw Exception('Test API failed: $e');
    }
  }

  static Future<Map<String, dynamic>> submitQuiz({
    required int categoryId,
    required int totalQuestions,
    required int totalCorrect,
    required String token,
  }) async {
    try {
      print('🚀 Submitting Quiz:');
      print('   CategoryId: $categoryId');
      print('   Total Questions: $totalQuestions');
      print('   Total Correct: $totalCorrect');
      
      // Calculate score as percentage
      final score = totalQuestions > 0 ? ((totalCorrect / totalQuestions) * 100).round() : 0;
      
      // Map category names based on categoryId
      String nameEn = "General Knowledge";
      String nameZh = "常识";
      String nameKh = "ចំណេះដឹងទូទៅ";
      
      switch (categoryId) {
        case 1:
          nameEn = "General Knowledge";
          nameZh = "常识";
          nameKh = "ចំណេះដឹងទូទៅ";
          break;
        case 2:
          nameEn = "IQ Test";
          nameZh = "智商测试";
          nameKh = "តេស្តវិឆ័យបញ្ញា";
          break;
        case 3:
          nameEn = "EQ Test";
          nameZh = "情商测试";
          nameKh = "តេស្តអារម្មណ៍";
          break;
        default:
          nameEn = "Quiz";
          nameZh = "测验";
          nameKh = "ការប្រលង";
      }
      
      final response = await post(
        ApiConstants.quizSubmitEndpoint,
        body: {
          'score': score,
          'totalQuestion': totalQuestions,
          'totalCorrect': totalCorrect,
          'nameEn': nameEn,
          'nameZh': nameZh,
          'nameKh': nameKh,
        },
        token: token,
      );
      
      print('📊 Submit Response Status: ${response.statusCode}');
      print('📋 Submit Response Body: ${response.body}');
      
      final result = handleResponse(response);
      print('✅ Parsed Submit Result: $result');
      
      return result;
    } catch (e) {
      print('❌ Submit Quiz Error: $e');
      throw Exception('Failed to submit quiz: $e');
    }
  }

  // User methods
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await get(ApiConstants.userProfileEndpoint, token: token);
      return handleResponse(response);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      // Only include non-null values in the request
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      
      final response = await post(
        ApiConstants.userUpdateProfileEndpoint,
        body: body,
        token: token,
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await post(
        ApiConstants.userUpdatePasswordEndpoint,
        body: {
          'password': newPassword,
        },
        token: token,
      );
      return handleResponse(response);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  // static Future<Map<String, dynamic>> getUserHistory(String token) async {
  //   try {
  //     final response = await get(ApiConstants.userHistoryEndpoint, token: token);
  //     return handleResponse(response);
  //   } catch (e) {
  //     throw Exception('Failed to load user history: $e');
  //   }
  // }

  static Future<List<dynamic>> getLeaderboard({String? token}) async {
    try {
      final response = await get(ApiConstants.leaderboardEndpoint, token: token);
      
      // Parse the JSON response manually to handle both array and object responses
      final responseBody = response.body;
      final decodedData = json.decode(responseBody);
      
      // Check if response is successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // The API should return an array directly based on the example provided
        if (decodedData is List) {
          return List<dynamic>.from(decodedData);
        } else if (decodedData is Map<String, dynamic>) {
          // If it's wrapped in an object, try to extract the array
          if (decodedData['data'] is List) {
            return List<dynamic>.from(decodedData['data']);
          } else if (decodedData['users'] is List) {
            return List<dynamic>.from(decodedData['users']);
          } else if (decodedData['leaderboard'] is List) {
            return List<dynamic>.from(decodedData['leaderboard']);
          }
        }
        
        // If the response structure is different, return empty list
        print('Unexpected leaderboard response structure: $decodedData');
        return [];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }
}
