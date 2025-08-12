import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/user_profile/api_search.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ApiSearch _apiSearch;
  Timer? _debounceTimer;

  SearchCubit(this._apiSearch) : super(SearchInitial());

  void searchUsers(String query) {
    // إلغاء البحث السابق إذا كان هناك
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }

    // تأخير البحث لمدة 500 مللي ثانية لتجنب طلبات API متكررة
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      emit(SearchLoading());

      try {
        final result = await _apiSearch.searchUsers(query);
        result.fold(
          (failure) => emit(SearchError(failure.message)),
          (users) => emit(SearchLoaded(users)),
        );
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
