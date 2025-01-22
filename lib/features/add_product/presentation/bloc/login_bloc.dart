// login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';
import 'package:gehnaorg/features/add_product/data/repositories/login_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;

  LoginBloc({required this.loginRepository}) : super(LoginInitial()) {
    // Handle LoginUserEvent
  on<LoginUserEvent>((event, emit) async {
  try {
    emit(LoginLoading());
    final loginResponse = await loginRepository.login(event.email, event.password);

    // Save token in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', loginResponse.token);

    emit(LoginSuccess(loginResponse));
  } catch (e) {
    emit(LoginFailure(e.toString()));
  }
});

  }
}
