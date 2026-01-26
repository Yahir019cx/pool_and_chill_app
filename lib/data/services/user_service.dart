import 'dart:convert';
import 'package:pool_and_chill_app/data/api/index.dart';
import 'package:pool_and_chill_app/data/models/user/index.dart';

class UserService {
  final ApiClient api;

  UserService(this.api);

  Future<UserProfileModel> getMe() async {
    final response = await api.get(ApiRoutes.me);

    if (response.statusCode != 200) {
      throw Exception('Failed to load user profile');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return UserProfileModel.fromJson(data);
  }
}
