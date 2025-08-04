# API Integration Implementation Summary

## Overview
This document summarizes the implementation of five key API integrations for the Quiz Test app:

1. **General Quiz Questions API** - `/api/questions/list/by-category/1`
2. **Top Users/Leaderboard API** - `/api/report/top10/player`
3. **Get User Profile API** - `/api/profile/info`
4. **Update User Profile API** - `/api/profile/info/update`
5. **Change Password API** - `/api/profile/password/change`

## 1. General Quiz Questions API (`/api/questions/list/by-category/1`)

### Implementation Details
- **Endpoint**: `/api/questions/list/by-category/1`
- **Method**: GET
- **Authentication**: Bearer token (optional)
- **Location**: Already integrated in `ApiService.getQuestionsByCategory()`

### Usage Flow
1. User opens the app and navigates to Home Screen
2. User clicks on "General Quiz" category (ID: 1)
3. Home Screen shows loading indicator
4. API call is made to fetch questions for category 1
5. If successful, user is navigated to Quiz Screen with the questions
6. If API fails, fallback to local JSON data (for General Quiz only)

### Files Modified/Created
- ✅ `lib/constants/api_constants.dart` - Added comments for clarity
- ✅ `lib/services/api_service.dart` - Already had the implementation
- ✅ Home Screen already handles the navigation correctly

### How It Works
```dart
// Called when user clicks General Quiz
final questions = await ApiService.getQuestionsByCategory(
  categoryId: 1,  // General Quiz category ID
  token: token,   // User authentication token
);

// Navigate to quiz screen with questions
Navigator.push(context, MaterialPageRoute(
  builder: (_) => QuizScreen(
    questions: questions,
    categoryName: 'General Quiz',
    categoryId: 1,
  ),
));
```

## 2. Top Users/Leaderboard API (`/api/report/top10/player`)

### Implementation Details
- **Endpoint**: `/api/report/top10/player`
- **Method**: GET
- **Authentication**: Bearer token (optional)
- **Response Format**: Array of user objects with structure:
  ```json
  [
    {
      "userId": 10,
      "totalScore": "780",
      "id": 10,
      "firstName": null,
      "lastName": null
    },
    ...
  ]
  ```

### Usage Flow
1. User navigates to "Top Users" tab in bottom navigation
2. TopUsersScreen automatically fetches leaderboard data on load
3. Loading indicator is shown while API call is in progress
4. If successful, real leaderboard data is displayed
5. If API fails, fallback to mock/demo data with warning message
6. User can refresh data using the refresh button in app bar

### Files Created/Modified
- ✅ `lib/models/leaderboard.dart` - New model for leaderboard data
- ✅ `lib/services/api_service.dart` - Updated `getLeaderboard()` method
- ✅ `lib/screens/top_users_screen.dart` - Completely rewritten to use real API

### Key Features
- **Real-time Data**: Fetches actual leaderboard from API
- **Fallback Support**: Shows demo data if API fails
- **Loading States**: Proper loading indicators and error handling
- **Refresh Function**: Pull-to-refresh and manual refresh button
- **Anonymous Users**: Handles users with null names as "Anonymous User"
- **League System**: Automatically assigns leagues based on score ranges:
  - Diamond: 2500+ points
  - Gold: 2000-2499 points
  - Silver: 1500-1999 points
  - Bronze: Below 1500 points

### How It Works
```dart
// Fetch leaderboard data
final leaderboardData = await ApiService.getLeaderboard(token: token);

// Convert to typed objects
final users = leaderboardData
    .map((userData) => LeaderboardUser.fromJson(userData))
    .toList();

// Display in UI with proper ranking and styling
```

### Model Structure
```dart
class LeaderboardUser {
  final int userId;
  final int id;
  final String totalScore;
  final String? firstName;
  final String? lastName;
  
  // Helper methods
  String get displayName; // Handles null names
  int get scoreAsInt;     // Converts string score to int
}
```

## Testing

### Test Helpers Created
- `lib/utils/api_test_helper.dart` - Helper functions to test quiz and leaderboard APIs
- `lib/utils/profile_api_test_helper.dart` - Helper functions to test profile APIs

### Usage
```dart
// Test quiz and leaderboard APIs
await APITestHelper.testBothAPIs();
await APITestHelper.testGeneralQuizAPI();
await APITestHelper.testLeaderboardAPI();

// Test profile APIs
await ProfileAPITestHelper.testAllProfileAPIs();
await ProfileAPITestHelper.testReadOnlyAPIs(); // Safe, no modifications
await ProfileAPITestHelper.testGetUserProfileAPI();
await ProfileAPITestHelper.testUpdateUserProfileAPI();
// ProfileAPITestHelper.testChangePasswordAPI(); // Use with caution
```

## Error Handling

### General Quiz API
- If API fails for General Quiz (category 1), falls back to local JSON
- Shows loading indicator during API call
- Displays error message if no questions available

### Leaderboard API
- If API fails, shows demo data with warning indicator
- Displays "Using demo data" badge in header
- Loading states and empty state handling
- Refresh functionality to retry failed requests

### Profile APIs
- If API fails, shows error message with retry option
- Demo mode fallback for profile display
- Form validation before API calls
- Secure error messages for password operations
- Loading states during all operations
- Automatic profile refresh after successful updates

## Authentication
All APIs support authentication via Bearer tokens:
- Token is automatically retrieved from `TokenService.getToken()`
- Profile APIs require authentication (will show error if no token)
- Quiz and Leaderboard APIs work with or without authentication
- Token is included in Authorization header when available

## Navigation
- **General Quiz**: Home Screen → General Quiz Category → Quiz Screen
- **Top Users**: Bottom Navigation → Top Users Tab → Leaderboard Screen
- **Profile**: Bottom Navigation → Profile Tab → Profile Screen

## 3. Profile APIs Implementation

### 3.1 Get User Profile API (`/api/profile/info`)

#### Implementation Details
- **Endpoint**: `/api/profile/info`
- **Method**: GET
- **Authentication**: Required (Bearer token)
- **Response Format**: User profile object with structure:
  ```json
  {
    "id": 5,
    "username": null,
    "countryCode": "855",
    "phone": "974976736",
    "firstName": "LONGCELOT",
    "lastName": "Ninja",
    "status": null,
    "lastSeenAt": null,
    "createdAt": "2025-07-21T02:50:02.000Z",
    "updatedAt": "2025-08-03T06:57:47.000Z"
  }
  ```

#### Usage Flow
1. User navigates to Profile tab
2. ProfileScreen automatically fetches user profile on load
3. Loading indicator is shown while API call is in progress
4. If successful, real user data is displayed
5. If API fails, shows error message with retry option

### 3.2 Update User Profile API (`/api/profile/info/update`)

#### Implementation Details
- **Endpoint**: `/api/profile/info/update`
- **Method**: PUT
- **Authentication**: Required (Bearer token)
- **Request Body**: Only editable fields (firstName, lastName) - **username is read-only**
- **Response**: Updated user profile object

#### Usage Flow
1. User clicks edit icon in Profile screen
2. Editable fields (firstName, lastName) become text inputs
3. Username field remains read-only (cannot be edited)
4. User modifies firstName or lastName
5. User clicks save (checkmark icon)
6. Form validation occurs
7. API call is made with only modified fields
8. Profile is refreshed with updated data
9. Success/error message is shown

### 3.3 Change Password API (`/api/profile/password/change`)

#### Implementation Details
- **Endpoint**: `/api/profile/password/change`
- **Method**: PUT
- **Authentication**: Required (Bearer token)
- **Request Body**: 
  ```json
  {
    "password": "Hello World!"
  }
  ```

#### Usage Flow
1. User clicks "Change Password" in Profile screen
2. Modal dialog opens with password fields
3. User enters new password and confirmation
4. Form validation ensures passwords match and meet requirements
5. API call is made with new password
6. Success/error message is shown
7. Dialog closes on success

### Files Created/Modified for Profile APIs
- ✅ `lib/models/user_profile.dart` - New model for user profile data
- ✅ `lib/services/api_service.dart` - Added profile-related methods:
  - `getUserProfile(token)` - Enhanced existing method
  - `updateUserProfile(token, firstName, lastName)` - **Updated to remove username field**
  - `changePassword(token, newPassword)` - New method
- ✅ `lib/screens/profile_screen.dart` - Completely rewritten to use real APIs
- ✅ `lib/utils/profile_api_test_helper.dart` - Test utilities for profile APIs

### Profile Screen Features
- **Real-time Data**: Fetches and displays actual user profile from API
- **Edit Mode**: In-place editing with form validation (firstName and lastName only)
- **Read-only Fields**: Username, phone number, user ID (cannot be edited)
- **Password Change**: Secure password update functionality
- **Loading States**: Proper loading indicators during API calls
- **Error Handling**: Graceful error handling with retry options
- **Refresh Function**: Manual refresh button to reload profile data
- **Demo Mode**: Fallback support if API fails
- **Field Validation**: Proper validation for editable fields
- **User Experience**: 
  - Avatar with user initials
  - Clean, organized layout
  - Read-only fields for sensitive data (phone, ID)
  - Formatted dates for created/updated timestamps

### Model Structure
```dart
class UserProfile {
  final int id;
  final String? username;
  final String countryCode;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? status;
  final String? lastSeenAt;
  final String createdAt;
  final String updatedAt;
  
  // Helper methods
  String get displayName;      // Smart name display
  String get fullPhoneNumber;  // +countryCode+phone
  UserProfile copyWith(...);   // For immutable updates
  Map<String, dynamic> toUpdatePayload(); // For API calls
}
```

### Security Features
- **Authentication Required**: All profile APIs require valid Bearer token
- **Input Validation**: Client-side validation before API calls
- **Password Security**: 
  - Minimum 6 character requirement
  - Password confirmation validation
  - Obscured password input fields
- **Error Handling**: Secure error messages without exposing sensitive data

## UI/UX Improvements
- Loading indicators during API calls
- Error states with fallback data
- Refresh functionality
- Proper ranking display (1st, 2nd, 3rd with special styling)
- League badges and scoring system
- Responsive design for different screen sizes
- **Profile Screen Enhancements**:
  - Clean, modern profile layout
  - In-place editing with visual feedback
  - Avatar with user initials
  - Organized sections (Account Info, Actions, Details)
  - Secure password change dialog
  - Demo mode indicators
  - Formatted date displays
  - Field validation and error handling

## API Response Handling
All APIs are designed to handle various response formats:
- Direct array responses (leaderboard)
- Standard object responses (profile)
- Error responses with proper status codes
- Empty responses and malformed data
- Authentication failures and token expiration
