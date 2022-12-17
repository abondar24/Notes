import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        body: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  final user = FirebaseAuth.instance.currentUser;

                  final emailVerified = user?.emailVerified ?? false;
                  if (emailVerified) {
                    return const LoginView();
                  } else {
                    return const RegisterView();
                  }

                default:
                  return const Text('Loading');
              }
            }));
  }
}
