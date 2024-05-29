import 'package:expensebuddy/database/app_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

import '../../bloc/cubit/register_cubit.dart';

GetIt getIt = GetIt.instance;

void configureInjection() async {
  getIt
      .registerLazySingleton<ExpensesDatabase>(() => ExpensesDatabase.instance);
  getIt.registerLazySingleton<RegisterCubit>(() => RegisterCubit(
        formKey: GlobalKey<FormState>(),
        usernameController: TextEditingController(),
        emailController: TextEditingController(),
        isRegistered: false,
      ));
}
