import 'package:equatable/equatable.dart';
import 'package:shamunity/models/library_model.dart' show LibraryModel;

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibrarySuccess extends LibraryState {
  final List<LibraryModel> libraries;

  const LibrarySuccess(this.libraries);

  @override
  List<Object?> get props => [libraries];
}

class LibraryFailure extends LibraryState {
  final String message;

  const LibraryFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadFileSuccess extends LibraryState {}

class UploadFileLoading extends LibraryState {}

class UploadFileFailure extends LibraryState {
  final String message;

  const UploadFileFailure(this.message);

  @override
  List<Object?> get props => [message];
}
