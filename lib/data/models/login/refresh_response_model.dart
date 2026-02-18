class RefreshResponseModel {
  final String accessToken;
  final int expiresIn;

  RefreshResponseModel({
    required this.accessToken,
    required this.expiresIn,
  });

  factory RefreshResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshResponseModel(
      accessToken: json['accessToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
