import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/auth_api.dart';
import 'package:shamunity/core/helpers/toast.dart';
import 'package:shamunity/core/service/services_locator.dart';
import 'package:shamunity/core/widgets/loading_dialog_widget.dart';
import 'package:shamunity/models/signup_model.dart';
import 'package:shamunity/routes/extension.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  // Form controllers
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController birthDay = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController universityId = TextEditingController();
  TextEditingController collage = TextEditingController();
  TextEditingController major = TextEditingController();
  TextEditingController year = TextEditingController();
  File? image;
  final formkey = GlobalKey<FormState>();
  final formkey1 = GlobalKey<FormState>();
  final formkey2 = GlobalKey<FormState>();
  final AuthApi _authApi;

  RegisterBloc(this._authApi) : super(RegisterInitial()) {
    on<RegisterRequestEvent>((event, emit) async {
      emit(RegisterLoading());
      BuildContext? context = SingleInstanceService.context;
      showDialog(
          context: context!,
          builder: (BuildContext context) => const LoadingDialogWidget());

      final result = await _authApi.register(SignupModelRequest(
        firstName: firstName.text,
        lastName: lastName.text,
        gender: gender.text,
        birthDay: birthDay.text,
        email: email.text,
        password: password.text,
        universityId: universityId.text,
        collage: collage.text,
        major: major.text,
        year: int.parse(year.text),
        image: image,
      ));

      result.fold(
        (failure) {
          context.pop();
          Toast().error(context, failure.message);
          emit(RegisterFailure(message: failure.message));
        },
        (data) {
          context.pop();
          emit(RegisterSuccess(signupResponse: data));
          Toast().success(context, data.message);
          context.pushNamed('/verification', arguments: data.email);
        },
      );
    });
  }

  @override
  Future<void> close() {
    // Dispose controllers when bloc is closed
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    universityId.dispose();
    collage.dispose();
    major.dispose();
    year.dispose();
    return super.close();
  }
}
