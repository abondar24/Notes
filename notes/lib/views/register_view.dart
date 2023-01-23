import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'dart:developer' show log;
import 'package:notes/utils/dialogs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/utils/extensions/context/loc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        if (state is AuthStateRegistering) {
          if (state.exception != null) {
            log(state.exception.toString());
          }

          if (state.exception is WeakPasswordAuthExcpetion) {
            await showErrorDialog(
              context,
              context.loc.weak_password,
            );
          } else if (state.exception is EmailInUseAuthException) {
            await showErrorDialog(
              context,
              context.loc.email_in_use,
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              context.loc.invalid_email,
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              context.loc.registration_failed,
            );
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(title: Text(context.loc.register)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.loc.enter_email_password),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: false,
                  autocorrect: false,
                  autofocus: true,
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
                Center(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () async {
                            final email = _emailController.text;
                            final password = _passwordController.text;

                            context.read<AuthBloc>().add(
                                  AuthEventRegister(
                                    email,
                                    password,
                                  ),
                                );
                          },
                          child: Text(
                            context.loc.register,
                          )),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEventLogout(),
                              );
                        },
                        child: Text(
                          context.loc.login_button,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
