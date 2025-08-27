/// Example usage of OTP API integration with automatic token storage
/// 
/// This file shows how to use the OTP API in your Flutter app
library;

import '../services/otp_service.dart';
import '../services/api_service.dart';
import '../services/auth_manager.dart';
import '../utils/app_logger.dart';

class OtpExamples {
  /// Example 1: Send OTP for signup with comprehensive error handling
  static Future<void> sendSignupOtpExample() async {
    try {
      await OtpService.sendSignupOTP(
        countryCode: '855',  // Cambodia country code
        phone: '974976736',  // Phone number without country code
      );
      AppLogger.info('Signup OTP sent successfully!');
    } on InvalidPhoneNumberException catch (e) {
      AppLogger.warning('Invalid phone number', e);
      // In a real app, you might show a blue message to user
    } on NetworkException catch (e) {
      AppLogger.error('Network error', e);
      // In a real app, you might show a retry option
    } on UserAlreadyExistsException catch (e) {
      AppLogger.warning('User already exists', e);
      // In a real app, you might redirect to login screen
    } catch (e) {
      AppLogger.error('Failed to send signup OTP', e);
    }
  }
  
  /// Example 2: Send OTP for password reset
  static Future<void> sendResetOtpExample() async {
    try {
      await OtpService.sendResetPasswordOTP(
        countryCode: '855',
        phone: '974976736',
      );
      AppLogger.info('Reset OTP sent successfully!');
    } catch (e) {
      AppLogger.error('Failed to send reset OTP', e);
    }
  }
  
  /// Example 3: Resend OTP
  static Future<void> resendOtpExample() async {
    try {
      await OtpService.resendOTP(
        countryCode: '855',
        phone: '974976736',
      );
      AppLogger.info('OTP resent successfully!');
    } catch (e) {
      AppLogger.error('Failed to resend OTP', e);
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
      AppLogger.info('Registration successful', response);
    } catch (e) {
      AppLogger.error('Registration failed', e);
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
      AppLogger.info('Login successful', response);
    } catch (e) {
      AppLogger.error('Login failed', e);
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
      AppLogger.info('Login successful', response);
    } catch (e) {
      AppLogger.error('Login failed (may require OTP)', e);
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
      AppLogger.info('Password reset successful', response);
    } catch (e) {
      AppLogger.error('Password reset failed', e);
    }
  }
  
  /// Example 7: Direct API service usage
  static Future<void> directApiExample() async {
    try {
      final response = await ApiService.sendOTP(
        countryCode: '855',
        phone: '974976736',
      );
      AppLogger.info('API Response', response);
    } catch (e) {
      AppLogger.error('API Error', e);
    }
  }
  
  /// Example 8: Validate phone number before sending with comprehensive validation
  static Future<void> validatedOtpExample(String countryCode, String phone) async {
    // Validate inputs
    if (!OtpService.isValidCountryCode(countryCode)) {
      AppLogger.warning('Invalid country code', {'countryCode': countryCode});
      return;
    }
    
    if (!OtpService.isValidPhoneNumber(phone)) {
      AppLogger.warning('Invalid phone number', {'phone': phone});
      return;
    }
    
    try {
      await OtpService.sendSignupOTP(
        countryCode: countryCode,
        phone: phone,
      );
      
      // Format for display
      String displayNumber = OtpService.formatPhoneNumber(countryCode, phone);
      AppLogger.info('OTP sent to', {'displayNumber': displayNumber});
    } on InvalidPhoneNumberException catch (e) {
      AppLogger.warning('Phone validation failed', e);
    } on NetworkException catch (e) {
      AppLogger.error('Network issue', e);
    } on UserAlreadyExistsException catch (e) {
      AppLogger.warning('User exists', e);
    } catch (e) {
      AppLogger.error('Failed to send OTP', e);
    }
  }

  /// Example 9: Check authentication status
  static Future<void> checkAuthStatusExample() async {
    try {
      final isAuthenticated = await AuthManager.isAuthenticated();
      if (isAuthenticated) {
        final userData = await AuthManager.getCurrentUser();
        AppLogger.info('User is authenticated', userData);
      } else {
        AppLogger.info('User needs to login');
      }
    } catch (e) {
      AppLogger.error('Error checking auth status', e);
    }
  }

  /// Example 10: Logout user
  static Future<void> logoutExample() async {
    try {
      await OtpService.logout();
      AppLogger.info('User logged out successfully');
    } catch (e) {
      AppLogger.error('Logout failed', e);
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
      AppLogger.info('OTP sent');

      // Step 2: Login with OTP (token will be saved automatically)
      final response = await OtpService.loginWithOTP(
        countryCode: '855',
        phone: '974976736',
        otp: '123456',
        password: 'securepassword',
      );
      AppLogger.info('Login successful, token saved automatically', response);

      // Step 3: Check if user is now authenticated
      final isAuth = await AuthManager.isAuthenticated();
      AppLogger.info('Authentication status', {'isAuthenticated': isAuth});

    } catch (e) {
      AppLogger.error('Login flow failed', e);
    }
  }
}
