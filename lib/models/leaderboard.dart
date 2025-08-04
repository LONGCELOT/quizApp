class LeaderboardUser {
  final int userId;
  final int id;
  final String totalScore;
  final String? firstName;
  final String? lastName;

  LeaderboardUser({
    required this.userId,
    required this.id,
    required this.totalScore,
    this.firstName,
    this.lastName,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      userId: json['userId'] ?? 0,
      id: json['id'] ?? 0,
      totalScore: json['totalScore']?.toString() ?? '0',
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'totalScore': totalScore,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  /// Get display name - combines first and last name or shows "Anonymous" if both are null
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return 'Anonymous User';
    }
  }

  /// Get total score as integer
  int get scoreAsInt {
    return int.tryParse(totalScore) ?? 0;
  }
}

class LeaderboardResponse {
  final List<LeaderboardUser> users;

  LeaderboardResponse({required this.users});

  factory LeaderboardResponse.fromJson(List<dynamic> json) {
    return LeaderboardResponse(
      users: json.map((user) => LeaderboardUser.fromJson(user)).toList(),
    );
  }
}
