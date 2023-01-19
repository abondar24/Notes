import 'dart:developer';

import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<AuthEventSendEmail>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();

        emit(const AuthStateNeedsVerification());
      } on Exception catch (ex) {
        log(ex.toString());
        emit(AuthStateRegistering(ex));
      }
    });

    on<AuthEventInit>((event, emit) async {
      await provider.init();

      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
      ));

      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));

          emit(const AuthStateNeedsVerification());
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));

          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (ex) {
        log(ex.toString());
        emit(AuthStateLoggedOut(
          exception: ex,
          isLoading: false,
        ));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        emit(const AuthStateUninitialized());

        await provider.logOut();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (ex) {
        log(ex.toString());
        emit(AuthStateLoggedOut(
          exception: ex,
          isLoading: false,
        ));
      }
    });
  }
}
