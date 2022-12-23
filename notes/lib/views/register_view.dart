import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' show log;
import '../utils/show_error_dialog.dart';
import 'package:notes/views/constants/routes.dart';

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
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    final user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();

                    Navigator.of(context).pushNamed(verifyRoute);
                  } on FirebaseAuthException catch (ex) {
                    log(ex.code);
                    if (ex.code == 'weak-password') {
                      await showErrorDialog(
                        context,
                        'Weak password',
                      );
                    } else if (ex.code == 'email-already-in0use') {
                      await showErrorDialog(
                        context,
                        'Email already in use',
                      );
                    } else if (ex.code == 'invalid-email') {
                      await showErrorDialog(
                        context,
                        'Invalid email address',
                      );
                    } else {
                      await showErrorDialog(
                        context,
                        'Error: ${ex.code}',
                      );
                    }
                  } catch (ex) {
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
