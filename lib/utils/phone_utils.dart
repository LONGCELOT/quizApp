/// Utility class for phone number operations
class PhoneUtils {
  /// Extract country code and phone number from a full phone number
  /// Assumes format: countryCode + phone (e.g., "855974976736")
  static Map<String, String> extractCountryCodeAndPhone(String fullPhoneNumber) {
    // For Cambodia (855), common country codes are 1-4 digits
    // This is a simple extraction - you might want to use a more robust solution
    
    // Default assumption: first 3 digits are country code
    if (fullPhoneNumber.length >= 6) {
      // Try common country code lengths
      for (int codeLength in [4, 3, 2, 1]) {
        if (fullPhoneNumber.length > codeLength) {
          String countryCode = fullPhoneNumber.substring(0, codeLength);
          String phone = fullPhoneNumber.substring(codeLength);
          
          // Basic validation - phone should be at least 6 digits
          if (phone.length >= 6) {
            return {
              'countryCode': countryCode,
              'phone': phone,
            };
          }
        }
      }
    }
    
    // Fallback: assume 855 (Cambodia) if extraction fails
    return {
      'countryCode': '855',
      'phone': fullPhoneNumber.length > 3 ? fullPhoneNumber.substring(3) : fullPhoneNumber,
    };
  }
  
  /// Format phone number for display
  static String formatForDisplay(String countryCode, String phone) {
    return '+$countryCode $phone';
  }
}
