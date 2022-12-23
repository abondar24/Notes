import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'dart:developer' show log;
import 'package:notes/utils/show_error_dialog.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_service.dart';

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
    return Scaffold(
        appBar: AppBar(title: const Text('Register')),
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
                    await AuthService.firebase().createUser(
                      email: email,
                      password: password,
                    );
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyRoute);
                  } on WeakPasswordAuthExcpetion catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'Weak password',
                    );
                  } on EmailInUseAuthException catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'Email already in use',
                    );
                  } on InvalidEmailAuthException catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'Invalid email address',
                    );
                  } on GenericAuthException catch (ex) {
                    log(ex.toString());
                    await showErrorDialog(
                      context,
                      'Error: ${ex.toString}',
                    );
                  }
                },
                child: const Text('Register')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Have an account? Please login'),
            )
          ],
        ));
  }
}
