import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:parkirta/data/repository/user_repository.dart';
import 'package:parkirta/utils/contsant/user_const.dart';
import 'package:sp_util/sp_util.dart';

class HomeBloc extends Cubit<LoginState> {
  UserRepository _userRepository = UserRepository();

  HomeBloc() : super(LoginInitial());



  void doLogin(String email, String password) async {
    emit(LoginLoadingState(true));
    final response =
        await _userRepository.login(email, password);
    emit(LoginLoadingState(false));
    if (response.success) {

      SpUtil.putString(API_TOKEN, response.data?.user.token ?? "");
      // SpUtil.putInt(USER_ID, response.data?.user.id ?? 0);
      SpUtil.putString(USER_NAME, response.data?.user.name?? "");
      SpUtil.putString(EMAIL, response.data?.user.email?? "");
      SpUtil.putBool(IS_LOGGED_IN, true);

      emit(LoginSuccessState());



    } else {
      emit(LoginErrorState(error: response.message ?? "Login failed !"));
    }
  }
}

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
}
class LoginSuccessState extends LoginState {
}

class LoginErrorState extends LoginState {
  final String error;
  const LoginErrorState({required this.error});

}

class LoginLoadingState extends LoginState {
  final show;
  LoginLoadingState(this.show);
}

class LoginPasswordState extends LoginState {
}

