class UserProfileModel {
  final String userId;
  final String email;

  final String? phoneNumber;

  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isAgeVerified;
  final bool isIdentityVerified;

  final int accountStatus;

  final DateTime createdAt;
  final DateTime lastLoginAt;

  final String profileId;

  final String firstName;
  final String lastName;
  final String displayName;

  final String? bio;
  final String? profileImageUrl;

  final DateTime? dateOfBirth;
  final int? gender;

  final bool isHostOnboarded;

  final List<String> roles;
  final bool hasPassword;
  final List<dynamic> linkedProviders;

  final bool isHost;
  final bool isStaff;

  UserProfileModel({
    required this.userId,
    required this.email,
    this.phoneNumber,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isAgeVerified,
    required this.isIdentityVerified,
    required this.accountStatus,
    required this.createdAt,
    required this.lastLoginAt,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.dateOfBirth,
    this.gender,
    required this.isHostOnboarded,
    required this.roles,
    required this.hasPassword,
    required this.linkedProviders,
    required this.isHost,
    required this.isStaff,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'],
      email: json['email'],

      phoneNumber: json['phoneNumber'],

      isEmailVerified: json['isEmailVerified'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
      isAgeVerified: json['isAgeVerified'] == true,
      isIdentityVerified: json['isIdentityVerified'] == true,

      accountStatus: json['accountStatus'] ?? 0,

      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),

      profileId: json['profileId'],

      firstName: json['firstName'],
      lastName: json['lastName'],
      displayName: json['displayName'],

      bio: json['bio'],
      profileImageUrl: json['profileImageUrl'],

      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,

      gender: json['gender'],

      isHostOnboarded: json['isHostOnboarded'] == true,

      roles: List<String>.from(json['roles'] ?? []),
      hasPassword: json['hasPassword'] == true,
      linkedProviders: List<dynamic>.from(json['linkedProviders'] ?? []),

      isHost: json['isHost'] == true,
      isStaff: json['isStaff'] == true,
    );
  }
}
