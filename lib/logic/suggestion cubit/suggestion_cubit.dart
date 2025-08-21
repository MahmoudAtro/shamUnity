import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/suggestion_api.dart';
import 'package:shamunity/logic/suggestion%20cubit/suggestion_state.dart';
import 'package:shamunity/models/suggestion_model.dart';

class SuggestionCubit extends Cubit<SuggestionState> {
  final SuggestionApi suggestionApi;
  SuggestionCubit(this.suggestionApi) : super(SuggestionInitial()) {}

  Future<void> sendSuggestion(String type, String content) async {
    emit(SuggestionLoading());
    final result = await suggestionApi
        .sendSuggestion(SuggestionModel(type: type, content: content));
    result.fold(
      (failure) => emit(SuggestionFailure(message: failure.message)),
      (data) => emit(
        SuggestionSuccess(),
      ),
    );
  }
}
