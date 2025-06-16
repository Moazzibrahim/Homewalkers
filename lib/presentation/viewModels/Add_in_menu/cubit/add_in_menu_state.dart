part of 'add_in_menu_cubit.dart';

abstract class AddInMenuState extends Equatable {
  const AddInMenuState();

  @override
  List<Object?> get props => [];
}

class AddInMenuInitial extends AddInMenuState {}

class AddInMenuLoading extends AddInMenuState {}

class AddInMenuSuccess extends AddInMenuState {
  final String message;

  const AddInMenuSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddInMenuError extends AddInMenuState {
  final String message;

  const AddInMenuError({required this.message});

  @override
  List<Object?> get props => [message];
}
