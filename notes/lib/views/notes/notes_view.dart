import 'package:notes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:notes/menu/menu_action.dart';
import 'package:notes/routes/routes.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_notes_service.dart';
import 'package:notes/utils/dialogs/logout_dialog.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/utils/extensions/stream/count.dart';
import 'package:notes/views/notes/notes_list_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;

//TODO Create a separate view with local notes and add functionality to transfer notes from local to remote.
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // late final DatabaseNotesService _databaseNotesService;
  late final CloudNotesService _cloudNotesService;

  //String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    // _databaseNotesService = DatabaseNotesService();
    _cloudNotesService = CloudNotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: _cloudNotesService.allNotes(userId: userId).count,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final noteCount = snapshot.data ?? 0;
              final text = context.loc.notes_title(noteCount);
              return Text(text);
            } else {
              return const Text('');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                createUpdateNotesRoute,
              );
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(
                    context.loc.logout,
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _cloudNotesService.allNotes(userId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createUpdateNotesRoute,
                      arguments: note,
                    );
                  },
                  onDelete: (note) async {
                    await _cloudNotesService.deleteNote(docId: note.docId);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
    // body: FutureBuilder(
    //   future: _databaseNotesService.getOrCreateUser(email: userEmail),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.done:
    //         return StreamBuilder(
    //           stream: _databaseNotesService.allNotes,
    //           builder: (context, snapshot) {
    //             switch (snapshot.connectionState) {
    //               case ConnectionState.waiting:
    //               case ConnectionState.active:
    //                 if (snapshot.hasData) {
    //                   final allNotes = snapshot.data as List<DatabaseNote>;
    //                   return NotesListView(
    //                     notes: allNotes,
    //                     onTap: (note) {
    //                       Navigator.of(context).pushNamed(
    //                         createUpdateNotesRoute,
    //                         arguments: note,
    //                       );
    //                     },
    //                     onDelete: (note) async {
    //                       await _databaseNotesService.deleteNote(id: note.id);
    //                     },
    //                   );
    //                 } else {
    //                   return const CircularProgressIndicator();
    //                 }
    //               default:
    //                 return const CircularProgressIndicator();
    //             }
    //           },
    //         );
    //       default:
    //         return const CircularProgressIndicator();
    //     }
    //   },
    // ),
    // );
  }
}
