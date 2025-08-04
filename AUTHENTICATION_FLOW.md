# Updated Authentication Flow

## 📱 **Signup Process**
1. **Step 1: Enter Phone Number**
   - User enters country code (default: 855) and phone number
   - Click "Send OTP" 
   - API Call: `POST /api/auth/otp/send`
   ```json
   {
     "countryCode": "855",
     "phone": "974976736"
   }
   ```

2. **Step 2: Verify OTP**
   - User enters 6-digit OTP received via SMS
   - Navigate to password setup

3. **Step 3: Set Password**
   - User enters password (no username required)
   - API Call: `POST /api/auth/register`
   ```json
   {
     "countryCode": "855",
     "phone": "974976736",
     "otp": "123456",
     "password": "securepassword"
   }
   ```

## 🔐 **Login Process**

### **Option A: Password-Only Login (Preferred)**
- User enters country code, phone number, and password
- API Call: `POST /api/auth/login` (without OTP field)
```json
{
  "countryCode": "855",
  "phone": "974976736",
  "password": "securepassword"
}
```

### **Option B: OTP + Password Login (Fallback)**
- If password-only login fails and requires OTP:
  1. Send OTP to user's phone
  2. User enters OTP in dialog
  3. API Call: `POST /api/auth/login` (with OTP)
  ```json
  {
    "countryCode": "855",
    "phone": "974976736",
    "otp": "123456",
    "password": "securepassword"
  }
  ```

## 🔄 **Password Reset Process**
1. **Step 1: Enter Phone Number**
   - User enters full phone number
   - Send OTP for verification

2. **Step 2: Verify OTP**
   - User enters OTP received via SMS

3. **Step 3: Set New Password**
   - API Call: `POST /api/auth/password/reset`
   ```json
   {
     "countryCode": "855",
     "phone": "974976736",
     "otp": "123456",
     "password": "newSecurePassword"
   }
   ```

## 🚀 **Key Changes Made**

### **Removed Username Requirement**
- Signup no longer requires username
- Users are identified by phone number only
- Simplified registration form

### **Updated Login Screen**
- Changed from "Username/Email" to "Country Code + Phone Number"
- Added intelligent OTP fallback for accounts that require it
- Better error handling

### **Consistent Phone Number Format**
- All screens now use country code + phone number format
- Default country code set to 855 (Cambodia)
- Proper validation for both fields

### **Real API Integration**
- All authentication flows now use real API endpoints
- Removed dependency on mock AuthService
- Proper error handling and user feedback

## 📋 **Updated Screen Flow**

```
Login Screen (Country Code + Phone + Password)
    ↓ (if OTP required)
OTP Dialog (Send & Enter OTP)
    ↓
Main App

OR

Signup Screen (Country Code + Phone)
    ↓
OTP Verification Screen (Enter OTP)
    ↓
Complete Signup Screen (Password only)
    ↓
Login Screen

OR

Reset Password Screen (Full Phone)
    ↓
OTP Verification Screen (Enter OTP)
    ↓
New Password Screen (New Password)
    ↓
Login Screen
```

## 🔧 **API Service Methods Available**

### **OTP Operations**
- `OtpService.sendSignupOTP()`
- `OtpService.sendResetPasswordOTP()`
- `OtpService.resendOTP()`

### **Authentication Operations**
- `OtpService.completeRegistration()`
- `OtpService.loginWithPassword()`
- `OtpService.loginWithOTP()`
- `OtpService.resetPasswordWithOTP()`

### **Direct API Calls**
- `ApiService.sendOTP()`
- `ApiService.register()`
- `ApiService.login()`
- `ApiService.loginWithPassword()`
- `ApiService.resetPassword()`
