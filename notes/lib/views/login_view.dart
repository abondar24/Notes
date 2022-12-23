import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'dart:developer';
import 'package:notes/utils/show_error_dialog.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_service.dart';

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
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Enter password'),
            ),
            TextButton(
                onPressed: () async {
                  final email = _emailController.text;
                  final password = _passwordController.text;

                  try {
                    await AuthService.firebase().logIn(
                      email: email,
                      password: password,
                    );

                    final user = AuthService.firebase().currentUser;
                    if (user?.isEmailVerified ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                      );
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyRoute,
                        (route) => false,
                      );
                    }
                  } on UserNotFoundAuthExcpetion catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'User not found',
                    );
                  } on WrongPasswordAuthExcpetion catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'Wrong credentials',
                    );
                  } on GenericAuthException catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'Error: ${ex.toString}',
                    );
                  }
                },
                child: const Text('Login')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text("Don't have an account? Register here"))
          ],
        ));
  }
}
