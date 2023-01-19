import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:notes/routes/routes.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text(
              "We've sent you an email verification. Please check your inbox"),
          const Text(
              "If you havenn't recieved it, please click the button below"),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmail(),
                  );
            },
            child: const Text('Send email verification'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventLogout(),
                  );
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
