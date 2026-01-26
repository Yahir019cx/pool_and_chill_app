class UserModel {
  final String userId;
  final String email;
  final String? phoneNumber;
  final String firstName;
  final String lastName;
  final String displayName;
  final String? profileImageUrl;
  final List<String> roles;

  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isAgeVerified;
  final bool isIdentityVerified;
  final bool isHost;
  final bool isStaff;

  final int accountStatus;

  UserModel({
    required this.userId,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.profileImageUrl,
    required this.roles,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isAgeVerified,
    required this.isIdentityVerified,
    required this.isHost,
    required this.isStaff,
    required this.accountStatus,
  });

  static bool _toBool(dynamic v) => v == true || v == 1;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      displayName: json['displayName'],
      profileImageUrl: json['profileImageUrl'],
      roles: List<String>.from(json['roles'] ?? []),

      isEmailVerified: _toBool(json['isEmailVerified']),
      isPhoneVerified: _toBool(json['isPhoneVerified']),
      isAgeVerified: _toBool(json['isAgeVerified']),
      isIdentityVerified: _toBool(json['isIdentityVerified']),
      isHost: _toBool(json['isHost']),
      isStaff: _toBool(json['isStaff']),

      accountStatus: json['accountStatus'],
    );
  }
}
