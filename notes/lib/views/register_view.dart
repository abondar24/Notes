import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' show log;

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
                    final userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email, password: password);
                  } on FirebaseAuthException catch (ex) {
                    log(ex.code);
                  }
                },
                child: const Text('Register')),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login/', (route) => false);
                },
                child: const Text('Have an account? Please login'))
          ],
        ));
  }
}
