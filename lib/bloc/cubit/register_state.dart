abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterComplete extends RegisterState {
  final bool isRegistered;

  RegisterComplete({
    required this.isRegistered,
  }) : super();

  List<Object?> get props => [isRegistered];
}

class RegisterValidateState extends RegisterState {
  final bool isValidate;

  RegisterValidateState(this.isValidate);
}

class RegisterLoadingState extends RegisterState {
  final bool isLoading;

  RegisterLoadingState(this.isLoading);
}
