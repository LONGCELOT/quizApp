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

  UserProfile({
    required this.id,
    this.username,
    required this.countryCode,
    required this.phone,
    this.firstName,
    this.lastName,
    this.status,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'],
      countryCode: json['countryCode'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      status: json['status'],
      lastSeenAt: json['lastSeenAt'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'countryCode': countryCode,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'status': status,
      'lastSeenAt': lastSeenAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get display name - combines first and last name or shows phone if both are null
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return phone;
    }
  }

  /// Get full phone number with country code
  String get fullPhoneNumber {
    return '+$countryCode$phone';
  }

  /// Create a copy with updated fields for profile editing
  UserProfile copyWith({
    int? id,
    String? username,
    String? countryCode,
    String? phone,
    String? firstName,
    String? lastName,
    String? status,
    String? lastSeenAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      status: status ?? this.status,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to update payload (only editable fields)
  Map<String, dynamic> toUpdatePayload() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

/// Request model for password change
class ChangePasswordRequest {
  final String password;

  ChangePasswordRequest({required this.password});

  Map<String, dynamic> toJson() {
    return {
      'password': password,
    };
  }
}
