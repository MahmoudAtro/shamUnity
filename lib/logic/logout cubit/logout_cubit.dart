import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';

part 'logout_state_cubit.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final AuthApi _authApi;

  LogoutCubit(this._authApi) : super(LogoutInitial());

  Future<void> logout() async {
    emit(LogoutLoading());
    BuildContext? context = SingleInstanceService.context;
    // Call logout API
    final result = await _authApi.logout();

    result.fold(
      (failure) {
        emit(LogoutFailure(errorMessage: failure.message));
        Toast().error(context!, failure.message);
      },
      (response) async {
        Toast().success(context!, response);
        emit(LogoutSuccess(message: response));
      },
    );
  }
}
