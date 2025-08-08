import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/loading_dialog_widget.dart';
import 'package:shamunity/logic/register%20bloc/register_bloc.dart';
import 'package:shamunity/models/verify_otp_model.dart';
import 'package:shamunity/routes/extension.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  // Form controllers
  TextEditingController verificationCode = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final AuthApi _authApi;

  VerificationBloc(this._authApi) : super(VerificationInitial()) {
    on<VerifyCodeEvent>((event, emit) async {
      emit(VerificationLoading());
      BuildContext? context = SingleInstanceService.context;
      showDialog(
          context: context!,
          builder: (BuildContext context) => const LoadingDialogWidget());

      final result = await _authApi.verifyOtp(
          VerifyOtpRequest(email: event.email, otpCode: verificationCode.text));
      result.fold(
        (failure) {
          context.pop();
          emit(VerificationFailure(message: failure.message));
          Toast().error(context, failure.message);
        },
        (data) {
          context.pop();
          emit(VerificationSuccess(message: data.message));
          Toast().success(context, data.message);
          getit.unregister<RegisterBloc>(
            disposingFunction: (bloc) => bloc.close(),
          );
          context.pushNamedAndRemoveUntil('/home',
              predicate: (route) => false);
        },
      );
    });

    on<ResendCodeEvent>((event, emit) async {
      emit(ResendCodeLoading());
      BuildContext? context = SingleInstanceService.context;

      final result = await _authApi.resendOtp(email: event.email);

      result.fold(
        (failure) {
          emit(ResendCodeFailure(message: failure.message));
          Toast().error(context!, failure.message);
        },
        (data) {
          emit(ResendCodeSuccess(message: data.message));
          Toast().success(context!, data.message);
        },
      );
    });
  }
  @override
  Future<void> close() {
    // Dispose controllers when bloc is closed
    verificationCode.dispose();
    return super.close();
  }
}
