import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/loading_dialog_widget.dart';
import 'package:shamunity/models/login_model.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';
import 'package:shamunity/routes/routes_name.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {  
  final AuthApi _authApi;

  LoginBloc(this._authApi) : super(LoginInitial()) {
    on<LoginRequestEvent>((event, emit) async {
      emit(LoginLoading());
      BuildContext? context = SingleInstanceService.context;
      showDialog(
          context: context!,
          builder: (BuildContext context) => const LoadingDialogWidget());

      final result = await _authApi.login(LoginRequest(
        email: event.email,
        password: event.password,
      ));
      result.fold(
        (failure) {
          context.pop();
          Toast().error(context, failure.message);
          emit(LoginFailure(message: failure.message));
        },
        (data) {
          context.pop();
          emit(LoginSuccess(verifyOtpResponse: data));
          Toast().success(context, data.message);
          context.pushNamedAndRemoveUntil(
            RoutesNames.homePage,
            arguments: false,
            predicate: (route) => false,
          );
        },
      );
    });
  }
}
