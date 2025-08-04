/// Example usage of OTP API integration with automatic token storage
/// 
/// This file shows how to use the OTP API in your Flutter app
library;

import '../services/otp_service.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';

class OtpExamples {
  /// Example 1: Send OTP for signup
  static Future<void> sendSignupOtpExample() async {
    try {
      await OtpService.sendSignupOTP(
        countryCode: '855',  // Cambodia country code
        phone: '974976736',  // Phone number without country code
      );
      print('Signup OTP sent successfully!');
    } catch (e) {
      print('Failed to send signup OTP: $e');
    }
  }
  
  /// Example 2: Send OTP for password reset
  static Future<void> sendResetOtpExample() async {
    try {
      await OtpService.sendResetPasswordOTP(
        countryCode: '855',
        phone: '974976736',
      );
      print('Reset OTP sent successfully!');
    } catch (e) {
      print('Failed to send reset OTP: $e');
    }
  }
  
  /// Example 3: Resend OTP
  static Future<void> resendOtpExample() async {
    try {
      await OtpService.resendOTP(
        countryCode: '855',
        phone: '974976736',
      );
      print('OTP resent successfully!');
    } catch (e) {
      print('Failed to resend OTP: $e');
    }
  }
  
  /// Example 4: Complete Registration with OTP
  static Future<void> completeRegistrationExample() async {
    try {
      final response = await OtpService.completeRegistration(
        countryCode: '855',
        phone: '974976736',
        otp: '123456',  // The OTP code received
        password: 'securepassword',
      );
      print('Registration successful: $response');
    } catch (e) {
      print('Registration failed: $e');
    }
  }
  
  /// Example 5: Login with OTP and password
  static Future<void> loginWithOtpExample() async {
    try {
      final response = await OtpService.loginWithOTP(
        countryCode: '855',
        phone: '974976736',
        otp: '123456',  // The OTP code received
        password: 'securepassword',
      );
      print('Login successful: $response');
    } catch (e) {
      print('Login failed: $e');
    }
  }
  
  /// Example 5b: Login with password only (no OTP)
  static Future<void> loginWithPasswordExample() async {
    try {
      final response = await OtpService.loginWithPassword(
        countryCode: '855',
        phone: '974976736',
        password: 'securepassword',
      );
      print('Login successful: $response');
    } catch (e) {
      print('Login failed (may require OTP): $e');
    }
  }
  
  /// Example 6: Reset password with OTP
  static Future<void> resetPasswordExample() async {
    try {
      final response = await OtpService.resetPasswordWithOTP(
        countryCode: '855',
        phone: '974976736',
        otp: '123456',  // The OTP code received
        newPassword: 'newSecurePassword',
      );
      print('Password reset successful: $response');
    } catch (e) {
      print('Password reset failed: $e');
    }
  }
  
  /// Example 7: Direct API service usage
  static Future<void> directApiExample() async {
    try {
      final response = await ApiService.sendOTP(
        countryCode: '855',
        phone: '974976736',
      );
      print('API Response: $response');
    } catch (e) {
      print('API Error: $e');
    }
  }
  
  /// Example 8: Validate phone number before sending
  static Future<void> validatedOtpExample(String countryCode, String phone) async {
    // Validate inputs
    if (!OtpService.isValidCountryCode(countryCode)) {
      print('Invalid country code: $countryCode');
      return;
    }
    
    if (!OtpService.isValidPhoneNumber(phone)) {
      print('Invalid phone number: $phone');
      return;
    }
    
    try {
      await OtpService.sendSignupOTP(
        countryCode: countryCode,
        phone: phone,
      );
      
      // Format for display
      String displayNumber = OtpService.formatPhoneNumber(countryCode, phone);
      print('OTP sent to: $displayNumber');
    } catch (e) {
      print('Failed to send OTP: $e');
    }
  }

  /// Example 9: Check authentication status
  static Future<void> checkAuthStatusExample() async {
    try {
      final isAuthenticated = await AuthManager.isAuthenticated();
      if (isAuthenticated) {
        final userData = await AuthManager.getCurrentUser();
        print('User is authenticated: $userData');
      } else {
        print('User needs to login');
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  /// Example 10: Logout user
  static Future<void> logoutExample() async {
    try {
      await OtpService.logout();
      print('User logged out successfully');
    } catch (e) {
      print('Logout failed: $e');
    }
  }

  /// Example 11: Complete login flow with automatic token storage
  static Future<void> completeLoginFlowExample() async {
    try {
      // Step 1: Send OTP
      await OtpService.sendSignupOTP(
        countryCode: '855',
        phone: '974976736',
      );
      print('OTP sent');

      // Step 2: Login with OTP (token will be saved automatically)
      final response = await OtpService.loginWithOTP(
        countryCode: '855',
        phone: '974976736',
        otp: '123456',
        password: 'securepassword',
      );
      print('Login successful, token saved automatically. Response: $response');

      // Step 3: Check if user is now authenticated
      final isAuth = await AuthManager.isAuthenticated();
      print('Is authenticated: $isAuth');

    } catch (e) {
      print('Login flow failed: $e');
    }
  }
}
