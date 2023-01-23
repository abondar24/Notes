import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/utils/extensions/context/loc.dart';

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
        title: Text(
          context.loc.verify_email,
        ),
      ),
      body: Column(
        children: [
          Text(
            context.loc.verification_sent,
          ),
          Text(
            context.loc.verification_not_recieved,
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventSendEmail(),
                  );
            },
            child: Text(
              context.loc.send_verfication,
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                    const AuthEventLogout(),
                  );
            },
            child: Text(
              context.loc.restart,
            ),
          )
        ],
      ),
    );
  }
}
