import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/helpers/loading/loading_screen.dart';
import 'package:notes/routes/routes.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/firebase_auth_provider.dart';
import 'package:notes/views/forgot_password_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/notes/create_update_note_view.dart';
import 'package:notes/views/notes/offline/create_update_offline_note_view.dart';
import 'package:notes/views/notes/offline/notes_offline_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/verify_email_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MaterialColor mycolor = const MaterialColor(0x24283B, <int, Color>{
    50: Color(0x24283B),
    100: Color(0x24283B),
    200: Color(0x24283B),
    300: Color(0x24283B),
    400: Color(0x24283B),
    500: Color(0x24283B),
    600: Color(0x24283B),
    700: Color(0x24283B),
    800: Color(0x24283B),
    900: Color(0x24283B),
  });

  runApp(MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    title: 'Notes',
    theme: ThemeData(
      primarySwatch: mycolor, //replace with
    ),
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const MyApp(),
    ),
    routes: {
      createUpdateNotesRoute: (context) => const CreateUpdateNoteView(),
      createUpdateNotesOfflineRoute: (context) =>
          const CreateUpdateOfflineNoteView(),
      showOfflineNotesRoute: (context) => const NotesOfflineView(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInit());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
