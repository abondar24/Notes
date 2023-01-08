import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInit extends AuthEvent {
  const AuthEventInit();
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin(
    this.email,
    this.password,
  );
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}
