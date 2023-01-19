import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'dart:developer' show log;
import 'package:notes/utils/dialogs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              'Weak Password!',
            );
          } else if (state.exception is EmailInUseAuthException) {
            await showErrorDialog(
              context,
              'Email already in use!',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              'Invalid email!',
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              'Registration failed!',
            );
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(title: const Text('Register')),
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
                          AuthEventRegister(
                            email,
                            password,
                          ),
                        );
                  },
                  child: const Text('Register')),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogout(),
                      );
                },
                child: const Text('Have an account? Please login'),
              )
            ],
          )),
    );
  }
}
