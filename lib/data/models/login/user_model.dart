class UserModel {
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final List<String> roles;
  final bool isEmailVerified;
  final bool isHost;
  final bool isStaff;
  final int accountStatus;

  UserModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.roles,
    required this.isEmailVerified,
    required this.isHost,
    required this.isStaff,
    required this.accountStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      displayName: json['displayName'],
      roles: List<String>.from(json['roles']),
      isEmailVerified: json['isEmailVerified'],
      isHost: json['isHost'],
      isStaff: json['isStaff'],
      accountStatus: json['accountStatus'],
    );
  }
}
