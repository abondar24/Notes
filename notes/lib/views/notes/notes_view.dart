import 'package:notes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:notes/menu/menu_action.dart';
import 'package:notes/routes/routes.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_notes_service.dart';
import 'package:notes/utils/dialogs/logout_dialog.dart';
import 'package:notes/views/notes/notes_list_view.dart';

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
        title: const Text('Notes'),
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
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
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
