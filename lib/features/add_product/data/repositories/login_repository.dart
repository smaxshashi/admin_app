import 'package:gehnaorg/features/add_product/apis/login_api.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';

class LoginRepository {
  final LoginApi loginApi;

  LoginRepository(this.loginApi);

  Future<Login> login(String email, String password) {
    return loginApi.login(email, password);
  }
}
