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

  File? image;
  Map<String, dynamic> registrationData = {
    'first_name': '',
    'last_name': '',
    'birth_day': '',
    'gender': 'male',
    'email': '',
    'password': '',
    'university_id': '',
    'collage': '',
    'major': '',
    'academic_year': 0,
  };
  final AuthApi _authApi;

  RegisterBloc(this._authApi) : super(RegisterInitial()) {
    on<RegisterRequestEvent>((event, emit) async {
      debugPrint(
          "SharedPrefHelper : setData with key : ${event.image} registerData and value : $registrationData");
      emit(RegisterLoading());
      BuildContext? context = SingleInstanceService.context;
      showDialog(
          context: context!,
          builder: (BuildContext context) => const LoadingDialogWidget());

      final result = await _authApi.register(SignupModelRequest(
        firstName: registrationData['first_name'],
        lastName: registrationData['last_name'],
        gender: registrationData['gender'],
        birthDay: registrationData['birth_day'],
        email: registrationData['email'],
        password: registrationData['password'],
        universityId: registrationData['university_id'],
        collage: registrationData['collage'],
        major: registrationData['major'],
        year: int.parse(registrationData['academic_year']),
        image: event.image,
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
          registrationData.clear();
          registrationData.addAll({
            'first_name': '',
            'last_name': '',
            'birth_day': '',
            'gender': 'male',
            'email': '',
            'password': '',
            'university_id': '',
            'collage': '',
            'major': '',
            'academic_year': 0,
          });
          Toast().success(context, data.message);
          context.pushNamed('/verification', arguments: data.email);
        },
      );
    });
  }
}
