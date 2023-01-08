import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/routes/routes.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/notes/create_update_note_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/verify_email_view.dart';
import 'package:notes/services/auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyApp(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const NotesView(),
      verifyRoute: (context) => const VerifyEmailView(),
      createUpdateNotesRoute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: AuthService.firebase().init(),
//         builder: (context, snapshot) {
//           switch (snapshot.connectionState) {
//             case ConnectionState.done:
//               final user = AuthService.firebase().currentUser;
//               if (user != null) {
//                 if (user.isEmailVerified) {
//                   return const NotesView();
//                 } else {
//                   return const VerifyEmailView();
//                 }
//               } else {
//                 return const LoginView();
//               }

//             default:
//               return const CircularProgressIndicator();
//           }
//         });
//   }

// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBlock(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing Bloc'),
        ),
        body: BlocConsumer<CounterBlock, CounterState>(
          listener: (context, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidVal =
                (state is CounterStateInvalid) ? state.invalidVal : '';
            return Column(
              children: [
                Text('Curr val => ${state.value}'),
                Visibility(
                  child: Text('invalid input: $invalidVal'),
                  visible: state is CounterStateInvalid,
                ),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'input number'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBlock>()
                            .add(DecrementEvent(_controller.text));
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBlock>()
                            .add(IncrementEvent(_controller.text));
                      },
                      child: const Text('+'),
                    )
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;

  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalid extends CounterState {
  final String invalidVal;

  const CounterStateInvalid({
    required this.invalidVal,
    required int prevVal,
  }) : super(prevVal);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBlock extends Bloc<CounterEvent, CounterState> {
  CounterBlock() : super(const CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final val = int.tryParse(event.value);
      if (val == null) {
        emit(CounterStateInvalid(
          invalidVal: event.value,
          prevVal: state.value,
        ));
      } else {
        emit(CounterStateValid(state.value + val));
      }
    });

    on<DecrementEvent>((event, emit) {
      final val = int.tryParse(event.value);
      if (val == null) {
        emit(CounterStateInvalid(
          invalidVal: event.value,
          prevVal: state.value,
        ));
      } else {
        emit(CounterStateValid(state.value - val));
      }
    });
  }
}
