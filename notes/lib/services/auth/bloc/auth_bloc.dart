import 'dart:developer';

import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

import 'package:bloc/bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    AuthProvider provider,
  ) : super(const AuthStateUninitialized(
          isLoading: true,
        )) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(
        const AuthStateRegistering(
          exception: null,
          isLoading: false,
        ),
      );
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));

      final email = event.email;
      if (email == null) {
        return; //go to forgot-pwd screen
      }

      //send email
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool emailSent;
      Exception? exception;
      try {
        await provider.sendPasswordReset(email: email);
        emailSent = true;
        exception = null;
      } on Exception catch (ex) {
        log(ex.toString());
        emailSent = false;
        exception = ex;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: emailSent,
        isLoading: false,
      ));
    });

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

        emit(const AuthStateNeedsVerification(
          isLoading: false,
        ));
      } on Exception catch (ex) {
        log(ex.toString());
        emit(AuthStateRegistering(
          exception: ex,
          isLoading: false,
        ));
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
        emit(const AuthStateNeedsVerification(
          isLoading: false,
        ));
      } else {
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
    });

    on<AuthEventLogin>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Logging in',
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

          emit(const AuthStateNeedsVerification(
            isLoading: false,
          ));
        } else {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ));

          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
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
        emit(const AuthStateUninitialized(
          isLoading: false,
        ));

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
