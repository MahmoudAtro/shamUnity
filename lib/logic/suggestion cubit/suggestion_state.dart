class SuggestionState {}

class SuggestionInitial extends SuggestionState {}

class SuggestionLoading extends SuggestionState {}

class SuggestionFailure extends SuggestionState {
  final String message;

  SuggestionFailure({required this.message});
}

class SuggestionSuccess extends SuggestionState {}
