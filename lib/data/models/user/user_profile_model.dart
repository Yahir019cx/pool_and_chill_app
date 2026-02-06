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
  final String? location;

  final DateTime? dateOfBirth;
  final int? gender;

  final int isHostOnboarded;

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
    this.location,
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
      location: json['location'],

      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,

      gender: json['gender'],

      isHostOnboarded: json['isHostOnboarded'] ?? 0,

      roles: List<String>.from(json['roles'] ?? []),
      hasPassword: json['hasPassword'] == true,
      linkedProviders: List<dynamic>.from(json['linkedProviders'] ?? []),

      isHost: json['isHost'] == true,
      isStaff: json['isStaff'] == true,
    );
  }

  /// Crea una copia del modelo con los campos especificados actualizados
  UserProfileModel copyWith({
    String? userId,
    String? email,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    bool? isAgeVerified,
    bool? isIdentityVerified,
    int? accountStatus,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? profileId,
    String? firstName,
    String? lastName,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    String? location,
    DateTime? dateOfBirth,
    int? gender,
    int? isHostOnboarded,
    List<String>? roles,
    bool? hasPassword,
    List<dynamic>? linkedProviders,
    bool? isHost,
    bool? isStaff,
    bool clearProfileImageUrl = false,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isAgeVerified: isAgeVerified ?? this.isAgeVerified,
      isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profileId: profileId ?? this.profileId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: clearProfileImageUrl ? null : (profileImageUrl ?? this.profileImageUrl),
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isHostOnboarded: isHostOnboarded ?? this.isHostOnboarded,
      roles: roles ?? this.roles,
      hasPassword: hasPassword ?? this.hasPassword,
      linkedProviders: linkedProviders ?? this.linkedProviders,
      isHost: isHost ?? this.isHost,
      isStaff: isStaff ?? this.isStaff,
    );
  }

  /// Obtiene las iniciales del usuario (primera letra del nombre y apellido)
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }
}
