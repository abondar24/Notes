import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'dart:developer';
import 'package:notes/utils/dialogs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/utils/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  CloseDialog? _closeDialogHandle;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading...',
            );
          }

          if (state.exception != null) {
            log(state.exception.toString());
          }
          if (state.exception is UserNotFoundAuthExcpetion ||
              state.exception is WrongPasswordAuthExcpetion) {
            await showErrorDialog(
              context,
              'Wrong credentials!',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              'Authentication Error!',
            );
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Column(
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter email',
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter password',
                ),
              ),
              TextButton(
                  onPressed: () async {
                    final email = _emailController.text;
                    final password = _passwordController.text;

                    context.read<AuthBloc>().add(
                          AuthEventLogin(
                            email,
                            password,
                          ),
                        );
                  },
                  child: const Text('Login')),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: const Text("Don't have an account? Register here"))
            ],
          )),
    );
  }
}
