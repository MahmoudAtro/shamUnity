import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamunity/apis/library/library_api.dart';
import 'package:shamunity/logic/library%20bloc/library_state.dart';
import 'package:shamunity/models/book_request.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final LibraryApi _libraryApi;

  LibraryCubit(this._libraryApi) : super(LibraryInitial()) {
    fetchLibraryInfo();
  }

  Future<void> fetchLibraryInfo() async {
    emit(LibraryLoading());

    final result = await _libraryApi.fetchLibraryInfo();

    result.fold(
      (failure) => emit(LibraryFailure(failure.message)),
      (libraries) => emit(LibrarySuccess(libraries)),
    );
  }

  Future<void> uploadBook(BookRequestModel bookRequest) async {
    emit(UploadFileLoading());

    final result = await _libraryApi.uploadBook(bookRequest);

    result.fold(
      (failure) => emit(UploadFileFailure(failure.message)),
      (response) => emit(UploadFileSuccess()),
    );
  }
}
