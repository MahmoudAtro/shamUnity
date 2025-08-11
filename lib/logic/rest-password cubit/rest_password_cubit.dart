import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/loading_dialog_widget.dart';
import 'package:shamunity/routes/extension.dart';

part 'rest_passwprd_state_cubit.dart';

class RestPasswordCubit extends Cubit<RestPasswordState> {
  final AuthApi _authApi;

  RestPasswordCubit(this._authApi) : super(RestPasswordInitial());

  Future<void> restPassword(String email) async {
    emit(RestPasswordLoading());
    BuildContext? context = SingleInstanceService.context;
    showDialog(
        context: context!,
        builder: (BuildContext context) => const LoadingDialogWidget());
    // Call RestPassword API
    final result = await _authApi.forgetPassword(email);

    result.fold(
      (failure) {
        context.pop();
        emit(RestPasswordFailure(errorMessage: failure.message));
        Toast().error(context, failure.message);
      },
      (response) async {
        context.pop();
        Toast().success(context, response);
        emit(RestPasswordSuccess(message: response));
      },
    );
  }

  Future<void> newPassword(String password) async {
    emit(RestPasswordLoading());
    BuildContext? context = SingleInstanceService.context;
    showDialog(
        context: context!,
        builder: (BuildContext context) => const LoadingDialogWidget());
    // Call RestPassword API
    final result = await _authApi.restPassword(password);

    result.fold(
      (failure) {
        context.pop();
        emit(RestPasswordFailure(errorMessage: failure.message));
        Toast().error(context, failure.message);
      },
      (response) async {
        context.pop();
        Toast().success(context, response);
        emit(RestPasswordSuccess(message: response));
      },
    );
  }
}
