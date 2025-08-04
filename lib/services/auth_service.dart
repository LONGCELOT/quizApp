import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class AuthService {
  static const String _authDataPath = 'assets/auth.json';
  static Map<String, dynamic> _authData = {};
  static String? _currentUser;
  
  // Simulate API delay
  static Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // Load auth data from JSON file (only load base data, preserve runtime data)
  static Future<void> _loadAuthData() async {
    try {
      final String response = await rootBundle.loadString(_authDataPath);
      final jsonData = json.decode(response);
      
      // Preserve existing OTP codes and runtime data
      final existingOtpCodes = _authData['otpCodes'] ?? {};
      final existingResetTokens = _authData['resetTokens'] ?? {};
      
      _authData = jsonData;
      
      // Restore runtime data
      _authData['otpCodes'] = existingOtpCodes;
      _authData['resetTokens'] = existingResetTokens;
      
    } catch (e) {
      // If file doesn't exist or error, initialize empty data (but preserve runtime data)
      if (_authData.isEmpty) {
        _authData = {
          'users': [],
          'otpCodes': {},
          'resetTokens': {}
        };
      }
    }
  }

  // Generate random OTP
  static String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;
  
  static String? get currentUser => _currentUser;

  // SIGN UP PROCESS
  
  // Step 1: Send OTP to phone number
  static Future<AuthResult> sendSignUpOTP(String phoneNumber) async {
    await _simulateDelay();
    await _loadAuthData();
    
    // Check if phone number already exists
    final users = _authData['users'] as List;
    final existingUser = users.any((user) => user['phoneNumber'] == phoneNumber);
    
    if (existingUser) {
      return AuthResult(
        success: false,
        message: 'Phone number already registered',
      );
    }
    
    // Generate and store OTP
    final otp = _generateOTP();
    
    // Ensure otpCodes exists
    _authData['otpCodes'] ??= {};
    
    _authData['otpCodes'][phoneNumber] = {
      'code': otp,
      'expiry': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
      'type': 'signup'
    };
    
    // In real implementation, send SMS here
    print('DEBUG: OTP for $phoneNumber is $otp'); // For testing
    
    return AuthResult(
      success: true,
      message: 'OTP sent successfully',
      data: {'otp': otp}, // Remove this in production
    );
  }
  
  // Step 2: Complete sign up with username, password, and OTP
  static Future<AuthResult> signUp({
    required String phoneNumber,
    required String username,
    required String password,
    required String otp,
  }) async {
    await _simulateDelay();
    await _loadAuthData();
    
    // Verify OTP
    final otpData = _authData['otpCodes'][phoneNumber];
    if (otpData == null) {
      return AuthResult(success: false, message: 'No OTP found for this phone number');
    }
    
    if (otpData['code'] != otp) {
      return AuthResult(success: false, message: 'Invalid OTP');
    }
    
    if (DateTime.now().millisecondsSinceEpoch > otpData['expiry']) {
      return AuthResult(success: false, message: 'OTP has expired');
    }
    
    if (otpData['type'] != 'signup') {
      return AuthResult(success: false, message: 'Invalid OTP type');
    }
    
    // Check if username already exists
    final users = _authData['users'] as List;
    final existingUsername = users.any((user) => user['username'] == username);
    
    if (existingUsername) {
      return AuthResult(success: false, message: 'Username already exists');
    }
    
    // Create new user
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': username,
      'phoneNumber': phoneNumber,
      'password': password, // In production, hash this password
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    users.add(newUser);
    
    // Remove used OTP
    _authData['otpCodes'].remove(phoneNumber);
    
    return AuthResult(
      success: true,
      message: 'Account created successfully',
      data: {'user': newUser},
    );
  }

  // LOGIN
  static Future<AuthResult> login({
    required String identifier, // username or phone number
    required String password,
  }) async {
    print('[DEBUG] Login attempt - identifier: "$identifier", password: "$password"');
    
    await _simulateDelay();
    await _loadAuthData();
    
    print('[DEBUG] Loaded auth data: $_authData');
    
    final users = _authData['users'] as List;
    print('[DEBUG] Users found: ${users.length}');
    
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      print('[DEBUG] User $i: username="${user['username']}", phone="${user['phoneNumber']}", password="${user['password']}"');
    }
    
    // Find user by username or phone number
    final user = users.firstWhere(
      (user) {
        final usernameMatch = user['username'] == identifier;
        final phoneMatch = user['phoneNumber'] == identifier;
        final passwordMatch = user['password'] == password;
        
        print('[DEBUG] Checking user: username="$usernameMatch" (${user['username']} == $identifier), phone="$phoneMatch" (${user['phoneNumber']} == $identifier), password="$passwordMatch"');
        
        return (usernameMatch || phoneMatch) && passwordMatch;
      },
      orElse: () => null,
    );
    
    print('[DEBUG] Found user: $user');
    
    if (user == null) {
      print('[DEBUG] Login failed - no matching user found');
      return AuthResult(success: false, message: 'Invalid credentials');
    }
    
    _currentUser = user['username'];
    
    return AuthResult(
      success: true,
      message: 'Login successful',
      data: {'user': user},
    );
  }

  // RESET PASSWORD PROCESS
  
  // Step 1: Send OTP for password reset
  static Future<AuthResult> sendResetOTP(String phoneNumber) async {
    await _simulateDelay();
    await _loadAuthData();
    
    // Check if phone number exists
    final users = _authData['users'] as List;
    final user = users.any((user) => user['phoneNumber'] == phoneNumber);
    
    if (!user) {
      return AuthResult(success: false, message: 'Phone number not found');
    }
    
    // Generate and store OTP
    final otp = _generateOTP();
    
    // Ensure otpCodes exists
    _authData['otpCodes'] ??= {};
    
    _authData['otpCodes'][phoneNumber] = {
      'code': otp,
      'expiry': DateTime.now().add(const Duration(minutes: 5)).millisecondsSinceEpoch,
      'type': 'reset'
    };
    
    print('DEBUG: Reset OTP for $phoneNumber is $otp'); // For testing
    
    return AuthResult(
      success: true,
      message: 'Reset OTP sent successfully',
      data: {'otp': otp}, // Remove this in production
    );
  }
  
  // Step 2: Verify OTP and reset password
  static Future<AuthResult> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    await _simulateDelay();
    await _loadAuthData();
    
    // Verify OTP
    final otpData = _authData['otpCodes'][phoneNumber];
    if (otpData == null) {
      return AuthResult(success: false, message: 'No OTP found for this phone number');
    }
    
    if (otpData['code'] != otp) {
      return AuthResult(success: false, message: 'Invalid OTP');
    }
    
    if (DateTime.now().millisecondsSinceEpoch > otpData['expiry']) {
      return AuthResult(success: false, message: 'OTP has expired');
    }
    
    if (otpData['type'] != 'reset') {
      return AuthResult(success: false, message: 'Invalid OTP type');
    }
    
    // Find and update user password
    final users = _authData['users'] as List;
    final userIndex = users.indexWhere((user) => user['phoneNumber'] == phoneNumber);
    
    if (userIndex == -1) {
      return AuthResult(success: false, message: 'User not found');
    }
    
    users[userIndex]['password'] = newPassword; // Hash in production
    
    // Remove used OTP
    _authData['otpCodes'].remove(phoneNumber);
    
    return AuthResult(success: true, message: 'Password reset successfully');
  }

  // CHANGE PASSWORD (from profile)
  static Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _simulateDelay();
    await _loadAuthData();
    
    if (_currentUser == null) {
      return AuthResult(success: false, message: 'User not logged in');
    }
    
    final users = _authData['users'] as List;
    final userIndex = users.indexWhere((user) => user['username'] == _currentUser);
    
    if (userIndex == -1) {
      return AuthResult(success: false, message: 'User not found');
    }
    
    final user = users[userIndex];
    
    if (user['password'] != currentPassword) {
      return AuthResult(success: false, message: 'Current password is incorrect');
    }
    
    users[userIndex]['password'] = newPassword; // Hash in production
    
    return AuthResult(success: true, message: 'Password changed successfully');
  }

  // LOGOUT
  static Future<void> logout() async {
    _currentUser = null;
  }

  // Get debug OTP for testing purposes
  static String? getDebugOTP(String phoneNumber) {
    final otpData = _authData['otpCodes']?[phoneNumber];
    final otp = otpData?['code'];
    print('DEBUG: getDebugOTP for $phoneNumber returns: $otp');
    return otp;
  }
  
  static Future<AuthResult> verifyOTP({
    required String phoneNumber,
    required String otp,
    required String type,
  }) async {
    await _simulateDelay();
    await _loadAuthData();
    
    print('DEBUG: Verifying OTP for $phoneNumber');
    print('DEBUG: Entered OTP: $otp');
    print('DEBUG: Expected type: $type');
    
    // Ensure otpCodes exists
    _authData['otpCodes'] ??= {};
    
    final otpData = _authData['otpCodes'][phoneNumber];
    print('DEBUG: Stored OTP data: $otpData');
    print('DEBUG: All stored OTPs: ${_authData['otpCodes']}');
    
    if (otpData == null) {
      print('DEBUG: No OTP data found in storage');
      return AuthResult(success: false, message: 'No OTP found for this phone number');
    }
    
    final storedOTP = otpData['code'];
    print('DEBUG: Stored OTP: $storedOTP');
    
    if (otpData['code'] != otp) {
      print('DEBUG: OTP mismatch - entered: $otp, stored: ${otpData['code']}');
      return AuthResult(success: false, message: 'Invalid OTP');
    }
    
    if (DateTime.now().millisecondsSinceEpoch > otpData['expiry']) {
      print('DEBUG: OTP expired');
      _authData['otpCodes'].remove(phoneNumber); // Clean up expired OTP
      return AuthResult(success: false, message: 'OTP has expired');
    }
    
    if (otpData['type'] != type) {
      print('DEBUG: OTP type mismatch - expected: $type, stored: ${otpData['type']}');
      return AuthResult(success: false, message: 'Invalid OTP type');
    }
    
    print('DEBUG: OTP verification successful!');
    return AuthResult(
      success: true,
      message: 'OTP verified successfully',
    );
  }
  
  static void setCurrentUser(Map<String, dynamic>? user) {
    _currentUser = user?['username'];
    print('[DEBUG] Current user set to: $_currentUser');
    print('[DEBUG] isLoggedIn now returns: $isLoggedIn');
  }
}

class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    required this.message,
    this.data,
  });
}
