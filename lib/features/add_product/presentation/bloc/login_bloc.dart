// login_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';
import 'package:gehnaorg/features/add_product/data/repositories/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository loginRepository;

  LoginBloc({required this.loginRepository}) : super(LoginInitial()) {
    // Handle LoginUserEvent
    on<LoginUserEvent>((event, emit) async {
      try {
        emit(LoginLoading()); // Emit loading state
        final loginResponse =
            await loginRepository.login(event.email, event.password);
        emit(LoginSuccess(
            loginResponse)); // Emit success state with login response
      } catch (e) {
        emit(LoginFailure(e.toString())); // Emit failure state in case of error
      }
    });
  }
}
