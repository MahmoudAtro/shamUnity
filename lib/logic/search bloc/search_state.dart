import 'package:equatable/equatable.dart';
import 'package:shamunity/models/post.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Author> users;

  const SearchLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
