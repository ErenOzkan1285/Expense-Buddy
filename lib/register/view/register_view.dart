import 'package:expensebuddy/home/view/home_view.dart';
import 'package:flutter/material.dart';
import 'package:expensebuddy/bloc/cubit/register_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cubit/register_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isRegistered = false;

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
          formKey: formKey,
          usernameController: usernameController,
          emailController: emailController,
          isRegistered: isRegistered),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterComplete && state.isRegistered) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeView()));
          }
        },
        builder: (context, state) {
          return buildScaffold(context, state);
        },
      ),
    );
  }

  Scaffold buildScaffold(BuildContext context, RegisterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Register To ExpenseBuddy')),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: state is RegisterValidateState
            ? (state.isValidate
                ? AutovalidateMode.always
                : AutovalidateMode.disabled)
            : AutovalidateMode.disabled,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            login(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            email(),
            ElevatedButton(
              onPressed: () {
                context.read<RegisterCubit>().postUserModel();
              },
              child: const Text("Register to App"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<RegisterCubit>().dropTables();
              },
              child: const Text("Drop Tables"),
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: context.watch<RegisterCubit>().getIsRegistered,
              child: const CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }

  TextFormField login() {
    return TextFormField(
      controller: usernameController,
      validator: (value) => (value ?? '').length > 5
          ? null
          : 'Your name cant be less than 5 characters',
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Your Name',
          prefixIcon: Icon(Icons.account_circle)),
    );
  }

  TextFormField email() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => (value ?? '').length > 5
          ? null
          : 'Email cant be less than 5 characters',
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Email',
          prefixIcon: Icon(Icons.mail)),
    );
  }
}
