import '../services/api_service.dart';
import 'token_service.dart';

/// Service for handling OTP operations
class OtpService {
  /// Send OTP for signup
  static Future<void> sendSignupOTP({
    required String countryCode,
    required String phone,
  }) async {
    await ApiService.sendOTP(
      countryCode: countryCode,
      phone: phone,
    );
  }
  
  /// Send OTP for password reset
  static Future<void> sendResetPasswordOTP({
    required String countryCode,
    required String phone,
  }) async {
    await ApiService.sendOTP(
      countryCode: countryCode,
      phone: phone,
    );
  }
  
  /// Resend OTP (can be used for both signup and reset)
  static Future<void> resendOTP({
    required String countryCode,
    required String phone,
  }) async {
    await ApiService.sendOTP(
      countryCode: countryCode,
      phone: phone,
    );
  }
  
  /// Complete registration with OTP
  static Future<Map<String, dynamic>> completeRegistration({
    required String countryCode,
    required String phone,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await ApiService.register(
        countryCode: countryCode,
        phone: phone,
        otp: otp,
        password: password,
      );

      // Save token if registration successful
      if (response['token'] != null) {
        await TokenService.saveToken(response['token']);
        if (response['user'] != null) {
          await TokenService.saveUserData(response['user']);
        }
      }

      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  /// Login with OTP and password
  static Future<Map<String, dynamic>> loginWithOTP({
    required String countryCode,
    required String phone,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await ApiService.login(
        countryCode: countryCode,
        phone: phone,
        otp: otp,
        password: password,
      );

      // Save token if login successful
      if (response['token'] != null) {
        await TokenService.saveToken(response['token']);
        if (response['user'] != null) {
          await TokenService.saveUserData(response['user']);
        }
      }

      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  /// Login with password only (no OTP)
  static Future<Map<String, dynamic>> loginWithPassword({
    required String countryCode,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await ApiService.loginWithPassword(
        countryCode: countryCode,
        phone: phone,
        password: password,
      );

      // Save token if login successful
      if (response['token'] != null) {
        await TokenService.saveToken(response['token']);
        if (response['user'] != null) {
          await TokenService.saveUserData(response['user']);
        }
      }

      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  /// Reset password with OTP
  static Future<Map<String, dynamic>> resetPasswordWithOTP({
    required String countryCode,
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    return await ApiService.resetPassword(
      countryCode: countryCode,
      phone: phone,
      otp: otp,
      password: newPassword,
    );
  }

  /// Logout user and clear stored data
  static Future<void> logout() async {
    await TokenService.clearStorage();
  }
  
  /// Format phone number for display
  static String formatPhoneNumber(String countryCode, String phone) {
    return '+$countryCode$phone';
  }
  
  /// Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    // Basic validation - adjust based on your requirements
    return phone.isNotEmpty && phone.length >= 8 && phone.length <= 15;
  }
  
  /// Validate country code format
  static bool isValidCountryCode(String countryCode) {
    // Basic validation - adjust based on your requirements
    return countryCode.isNotEmpty && countryCode.isNotEmpty && countryCode.length <= 4;
  }
}
