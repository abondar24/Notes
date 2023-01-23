import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'dart:developer';
import 'package:notes/utils/dialogs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/utils/extensions/context/loc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

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
          if (state.exception != null) {
            log(state.exception.toString());
          }
          if (state.exception is UserNotFoundAuthExcpetion ||
              state.exception is WrongPasswordAuthExcpetion) {
            await showErrorDialog(
              context,
              context.loc.wrong_credentials,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.aunthentication_error,
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.loc.login),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                context.loc.login_prompt,
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: context.loc.enter_email,
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: context.loc.enter_password,
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
                  child: Text(context.loc.login)),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(),
                        );
                  },
                  child: Text(
                    context.loc.forgot_password,
                  )),
              TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: Text(
                    context.loc.login_register_button,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
