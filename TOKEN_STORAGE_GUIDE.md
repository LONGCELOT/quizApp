# Token Storage & Auto-Login Implementation

This document explains the token storage system that has been implemented in your Flutter quiz app to provide persistent login functionality.

## What's New

Your app now automatically saves authentication tokens to local storage, so users don't need to login every time they open the app.

## Files Added/Modified

### New Files:
- `lib/services/token_service.dart` - Handles saving/retrieving tokens from local storage
- `lib/services/auth_manager.dart` - Manages authentication state
- `lib/utils/auth_utils.dart` - Utility functions for authentication

### Modified Files:
- `lib/services/otp_service.dart` - Now automatically saves tokens after successful login/registration
- `lib/services/api_service.dart` - Added support for authenticated requests with stored tokens
- `lib/widgets/auth_wrapper.dart` - Updated to use new authentication system
- `lib/examples/otp_examples.dart` - Added examples for new token functionality

## How It Works

### 1. **Token Storage**
When users successfully login or register, their authentication token is automatically saved to device storage using `shared_preferences`.

### 2. **Auto-Login Check**
When the app starts, `AuthWrapper` checks if a valid token exists:
- If valid token exists → User goes directly to main app
- If no token → User sees login screen

### 3. **Persistent Authentication**
Once logged in, users stay logged in until they manually logout or the token expires.

## Key Features

### Automatic Token Management
```dart
// After successful login, token is saved automatically
final response = await OtpService.loginWithOTP(
  countryCode: '855',
  phone: '974976736',
  otp: '123456',
  password: 'password',
);
// Token is now saved - user won't need to login again
```

### Authentication Status Check
```dart
// Check if user is logged in
bool isLoggedIn = await AuthManager.isAuthenticated();

// Get current user data
Map<String, dynamic>? userData = await AuthManager.getCurrentUser();
```

### Logout
```dart
// Logout and clear all stored data
await OtpService.logout();
```

### Authenticated API Requests
```dart
// Make API requests with stored token automatically
final response = await ApiService.authenticatedRequest('/protected-endpoint', 'GET');
```

## Benefits

1. **Better User Experience**: Users don't need to login repeatedly
2. **Automatic Token Handling**: Tokens are saved and used automatically
3. **Secure Storage**: Uses Flutter's `shared_preferences` for local storage
4. **Token Expiration Handling**: Automatically clears invalid tokens
5. **Easy Logout**: Simple logout functionality that clears all data

## Usage Examples

### Check Authentication in Your Screens
```dart
@override
void initState() {
  super.initState();
  _checkAuthStatus();
}

Future<void> _checkAuthStatus() async {
  final isAuthenticated = await AuthManager.isAuthenticated();
  if (!isAuthenticated) {
    // Redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

### Add Logout to Your App
```dart
ElevatedButton(
  onPressed: () async {
    await OtpService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  },
  child: Text('Logout'),
)
```

## Technical Details

- **Storage**: Uses `shared_preferences` package for local storage
- **Token Format**: Supports JWT or any string-based tokens
- **User Data**: Stores user information as JSON
- **Security**: Tokens are stored locally on device (standard for mobile apps)
- **Expiration**: Handles token expiration by clearing storage on 401 responses

## Migration

Your existing authentication flow will continue to work, but now with automatic token storage. No changes needed to your login screens - the token saving happens automatically in the background.

The `AuthWrapper` component now handles the initial authentication check, so users with valid tokens will skip the login screen entirely.
