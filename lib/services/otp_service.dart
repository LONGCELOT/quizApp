import '../services/api_service.dart';
import 'token_service.dart';

/// Custom exception for invalid phone number
class InvalidPhoneNumberException implements Exception {
  final String message;
  InvalidPhoneNumberException(this.message);
  
  @override
  String toString() => message;
}

/// Custom exception for network/server errors
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

/// Custom exception for user already exists
class UserAlreadyExistsException implements Exception {
  final String message;
  UserAlreadyExistsException(this.message);
  
  @override
  String toString() => message;
}

/// Custom exception for invalid credentials
class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException(this.message);
  
  @override
  String toString() => message;
}

/// Service for handling OTP operations
class OtpService {
  /// Send OTP for signup
  static Future<void> sendSignupOTP({
    required String countryCode,
    required String phone,
  }) async {
    // Validate input before making API call
    if (!isValidCountryCode(countryCode)) {
      throw InvalidPhoneNumberException(
        'Invalid country code. Please enter a valid country code.'
      );
    }
    
    if (!isValidPhoneNumber(phone)) {
      throw InvalidPhoneNumberException(
        'Invalid phone number. Please enter a valid phone number (8-15 digits).'
      );
    }

    try {
      await ApiService.sendOTP(
        countryCode: countryCode,
        phone: phone,
      );
    } catch (e) {
      String errorMessage = e.toString().toLowerCase();
      
      // Check for network/server errors
      if (errorMessage.contains('502') || 
          errorMessage.contains('bad gateway') ||
          errorMessage.contains('500') ||
          errorMessage.contains('503') ||
          errorMessage.contains('504')) {
        throw NetworkException(
          'Server is temporarily unavailable. Please try again later.'
        );
      }
      
      // Check for invalid phone number from API
      if (errorMessage.contains('invalid phone') || 
          errorMessage.contains('invalid number') ||
          errorMessage.contains('phone number is invalid') ||
          errorMessage.contains('invalid mobile')) {
        throw InvalidPhoneNumberException(
          'The phone number you entered is not valid. Please check and try again.'
        );
      }
      
      // Check if error indicates user already exists
      if (errorMessage.contains('already exists') || 
          errorMessage.contains('user exists') || 
          errorMessage.contains('phone already registered') ||
          errorMessage.contains('already registered')) {
        throw UserAlreadyExistsException(
          'This phone number is already registered. Please login instead.'
        );
      }
      
      // Handle other API errors more gracefully
      if (errorMessage.contains('api error') || errorMessage.contains('<html>')) {
        throw NetworkException(
          'Unable to send OTP. Please check your internet connection and try again.'
        );
      }
      
      // Re-throw other errors as-is
      rethrow;
    }
  }
  
  /// Send OTP for password reset
  static Future<void> sendResetPasswordOTP({
    required String countryCode,
    required String phone,
  }) async {
    // Validate input before making API call
    if (!isValidCountryCode(countryCode)) {
      throw InvalidPhoneNumberException(
        'Invalid country code. Please enter a valid country code.'
      );
    }
    
    if (!isValidPhoneNumber(phone)) {
      throw InvalidPhoneNumberException(
        'Invalid phone number. Please enter a valid phone number (8-15 digits).'
      );
    }

    try {
      await ApiService.sendOTP(
        countryCode: countryCode,
        phone: phone,
      );
    } catch (e) {
      String errorMessage = e.toString().toLowerCase();
      
      // Check for network/server errors
      if (errorMessage.contains('502') || 
          errorMessage.contains('bad gateway') ||
          errorMessage.contains('500') ||
          errorMessage.contains('503') ||
          errorMessage.contains('504')) {
        throw NetworkException(
          'Server is temporarily unavailable. Please try again later.'
        );
      }
      
      // Check for invalid phone number from API
      if (errorMessage.contains('invalid phone') || 
          errorMessage.contains('invalid number') ||
          errorMessage.contains('phone number is invalid') ||
          errorMessage.contains('invalid mobile')) {
        throw InvalidPhoneNumberException(
          'The phone number you entered is not valid. Please check and try again.'
        );
      }
      
      // Handle other API errors more gracefully
      if (errorMessage.contains('api error') || errorMessage.contains('<html>')) {
        throw NetworkException(
          'Unable to send OTP. Please check your internet connection and try again.'
        );
      }
      
      rethrow;
    }
  }
  
  /// Resend OTP (can be used for both signup and reset)
  static Future<void> resendOTP({
    required String countryCode,
    required String phone,
  }) async {
    // Validate input before making API call
    if (!isValidCountryCode(countryCode)) {
      throw InvalidPhoneNumberException(
        'Invalid country code. Please enter a valid country code.'
      );
    }
    
    if (!isValidPhoneNumber(phone)) {
      throw InvalidPhoneNumberException(
        'Invalid phone number. Please enter a valid phone number (8-15 digits).'
      );
    }

    try {
      await ApiService.sendOTP(
        countryCode: countryCode,
        phone: phone,
      );
    } catch (e) {
      String errorMessage = e.toString().toLowerCase();
      
      // Check for network/server errors
      if (errorMessage.contains('502') || 
          errorMessage.contains('bad gateway') ||
          errorMessage.contains('500') ||
          errorMessage.contains('503') ||
          errorMessage.contains('504')) {
        throw NetworkException(
          'Server is temporarily unavailable. Please try again later.'
        );
      }
      
      // Check for invalid phone number from API
      if (errorMessage.contains('invalid phone') || 
          errorMessage.contains('invalid number') ||
          errorMessage.contains('phone number is invalid') ||
          errorMessage.contains('invalid mobile')) {
        throw InvalidPhoneNumberException(
          'The phone number you entered is not valid. Please check and try again.'
        );
      }
      
      // Handle other API errors more gracefully
      if (errorMessage.contains('api error') || errorMessage.contains('<html>')) {
        throw NetworkException(
          'Unable to send OTP. Please check your internet connection and try again.'
        );
      }
      
      rethrow;
    }
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
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('invalid') || 
          errorMessage.contains('incorrect') || 
          errorMessage.contains('wrong')) {
        throw InvalidCredentialsException(
          'Invalid credentials. Please check your phone number, password, or OTP.'
        );
      }
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
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('invalid') || 
          errorMessage.contains('incorrect') || 
          errorMessage.contains('wrong')) {
        throw InvalidCredentialsException(
          'Invalid phone number or password. Please check your credentials.'
        );
      }
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
    // Remove any spaces, dashes, or other non-digit characters for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's empty after cleaning
    if (cleanPhone.isEmpty) return false;
    
    // Cambodia phone numbers are typically 8-9 digits
    // International format can be 8-15 digits
    return cleanPhone.length >= 8 && cleanPhone.length <= 15;
  }
  
  /// Validate country code format
  static bool isValidCountryCode(String countryCode) {
    // Remove any non-digit characters
    final cleanCode = countryCode.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's empty after cleaning
    if (cleanCode.isEmpty) return false;
    
    // Country codes are typically 1-4 digits
    return cleanCode.length >= 1 && cleanCode.length <= 4;
  }
}
