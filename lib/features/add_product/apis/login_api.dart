import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';

class LoginApi {
  final Dio dio;

  LoginApi(this.dio);

  Future<Login> login(String email, String password) async {
    try {
      final response = await dio.post(
        'https://admin-service-254137058023.asia-south1.run.app/admin/auth/login',
        data: {
          "email": email,
          "password": password,
        },
        options: Options(contentType: 'application/json'),
      );  

      if (response.statusCode == 200) {
        final login = Login.fromJson(response.data);
        print('Login successful! Token: ${login.token}');
        print('Identity: ${login.identity}');
        print('wholesalerId: ${login.wholesalerId}');

        // admin id stored here
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('wholesalerId', login.wholesalerId);

        print('wholesalerId stored in shared preferences: ${login.wholesalerId}');

        return login;
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }
}