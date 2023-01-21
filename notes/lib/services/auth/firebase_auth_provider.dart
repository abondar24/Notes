import 'dart:developer';

import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:notes/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (ex) {
      log(ex.code);
      if (ex.code == 'weak-password') {
        throw WeakPasswordAuthExcpetion();
      } else if (ex.code == 'email-already-in0use') {
        throw EmailInUseAuthException();
      } else if (ex.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (ex) {
      log(ex.toString());
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (ex) {
      log(ex.code);
      if (ex.code == 'user-not-found') {
        throw UserNotFoundAuthExcpetion();
      } else if (ex.code == 'wrong-password') {
        throw WrongPasswordAuthExcpetion();
      } else {
        throw GenericAuthException();
      }
    } catch (ex) {
      log(ex.toString());
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (ex) {
      log(ex.toString());
      switch (ex.code) {
        case 'firebase_auth/invalid-email':
          throw InvalidEmailAuthException();
        case 'forebase_auth/user-not-found':
          throw UserNotFoundAuthExcpetion();
        default:
          throw GenericAuthException();
      }
    } catch (ex) {
      log(ex.toString());
      throw GenericAuthException();
    }
  }
}
