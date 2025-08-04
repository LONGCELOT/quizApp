# General Quiz API - Issue & Fix Summary

## 🔍 **ISSUE IDENTIFIED:**

### Problem:
- **Error**: `type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'`
- **API Endpoint**: `/api/questions/list/by-category/1` (General Quiz)
- **HTTP Method**: GET ✅ (Correct)
- **Authentication**: Bearer token ✅ (Working)
- **API Response**: HTTP 200 ✅ (Success)

### Root Cause:
The API returns a **direct JSON array** of questions:
```json
[
  {
    "id": 1,
    "code": "PAMSZ99A", 
    "questionEn": "How many continents are there?",
    "questionKh": "មានទ្វីបប៉ុន្មាននៅលើពិភពលោក?",
    "answerCode": "7",
    "optionEn": ["5","6","7","8"]
  },
  ...
]
```

But our `ApiService.getQuestionsByCategory()` method was using `handleResponse()` which expects a **Map/Object**, not a direct array.

## 🔧 **FIX APPLIED:**

### Modified `ApiService.getQuestionsByCategory()` method:
1. **Removed** `handleResponse()` call 
2. **Added** direct JSON parsing with `json.decode()`
3. **Added** proper type checking for List vs Map responses
4. **Added** robust error handling

### Code Changes:
```dart
// OLD (Broken):
final data = handleResponse(response); // Expected Map, got List
if (data['questions'] != null) { ... }

// NEW (Fixed):
final jsonData = json.decode(response.body); // Parse directly
if (jsonData is List) { // Handle direct array
  return List<dynamic>.from(jsonData);
} else if (jsonData is Map) { // Handle wrapped object
  // Check for questions/data/results arrays
}
```

## ✅ **CURRENT STATUS:**

### API Details:
- **URL**: `https://quiz-api.camtech-dev.online/api/questions/list/by-category/1`
- **Method**: GET
- **Headers**: `Authorization: Bearer [token]`
- **Response**: Direct JSON array (200 OK)
- **Content**: 3827 characters, multiple question objects

### Token Status:
- **Provided Token**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` ✅
- **Authentication**: Working (API returns 200)

### Fix Status:
- **Applied**: ✅ Modified API service method
- **Testing**: Ready for verification

## 🧪 **VERIFICATION:**

The General Quiz API should now work correctly:
1. User taps "General Quiz" in home screen
2. API calls `/api/questions/list/by-category/1` with Bearer token
3. Receives direct JSON array of questions
4. Parses correctly as `List<dynamic>`
5. Navigates to quiz screen with real questions

## 📝 **NEXT STEPS:**

1. **Test**: Try the General Quiz functionality in the app
2. **Verify**: Questions load from API instead of fallback JSON
3. **Confirm**: No more type conversion errors

The fix ensures the API integration works correctly with the actual response format from your backend.
