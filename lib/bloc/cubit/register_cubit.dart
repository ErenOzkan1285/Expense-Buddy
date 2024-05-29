import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import '../../database/app_database.dart';
import '../../database/databaseModels/user_model.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  TextEditingController usernameController;
  TextEditingController emailController;
  final GlobalKey<FormState> formKey;

  bool isRegisterFail = false;
  bool isLoading = false;
  bool isRegistered = false;

  bool get getIsRegistered => isRegistered;

  RegisterCubit({
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.isRegistered,
  }) : super(RegisterInitial());

  void postUserModel() async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      changeLoadingView();
      final newUser = User(
        username: usernameController.text,
        email: emailController.text,
        totalExpanses: 0.0,
        income: 0.0,
      );
      await ExpensesDatabase.instance.createUser(newUser);
      changeLoadingView();
      emit(RegisterComplete(isRegistered: true));
      Future.delayed(const Duration(seconds: 2));
    } else {
      isRegisterFail = true;
      emit(RegisterValidateState(isRegisterFail));
    }
  }

  void dropTables() async {
    await ExpensesDatabase.instance.dropAndRecreateTables();
  }

  void changeLoadingView() {
    isLoading = !isLoading;
    emit(RegisterLoadingState(isLoading));
  }
}
