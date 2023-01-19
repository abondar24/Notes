import 'dart:developer';

import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInit>((event, emit) async {
      await provider.init();

      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLogin>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        emit(AuthStateLoggedIn(user));
      } on Exception catch (ex) {
        log(ex.toString());
        emit(AuthStateLoggedOut(ex));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        emit(const AuthStateLoading());

        await provider.logOut();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (ex) {
        log(ex.toString());
        emit(AuthStateLoggedOutFailure(ex));
      }
    });
  }
}
