import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

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
                    final userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                  } on FirebaseAuthException catch (ex) {
                    log(ex.code);
                  }
                },
                child: const Text('Login')),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/register/', (route) => false);
                },
                child: const Text('Have a login? Register here'))
          ],
        ));
  }
}
