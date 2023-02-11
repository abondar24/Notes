import 'package:flutter/material.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:notes/views/notes/offline/notes_offline_list_view.dart';

import '../../../routes/routes.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/database/database_note.dart';
import '../../../services/database/database_notes_service.dart';

class NotesOfflineView extends StatefulWidget {
  const NotesOfflineView({super.key});

  @override
  State<NotesOfflineView> createState() => _NotesOfflineViewState();
}

class _NotesOfflineViewState extends State<NotesOfflineView> {
  late final DatabaseNotesService _databaseNotesService;

  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _databaseNotesService = DatabaseNotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Iterable<DatabaseNote>>(
          future: _databaseNotesService.getNotes(offset: 0, limit: 100000),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final noteCount = snapshot.data!.length;
              final text = context.loc.notes_title(noteCount);
              return Text(text);
            } else {
              return const Text('');
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: _databaseNotesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _databaseNotesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesOfflineListView(
                          notes: allNotes,
                          onTap: (note) {
                            Navigator.of(context).pushNamed(
                              createUpdateNotesOfflineRoute,
                              arguments: note,
                            );
                          },
                          onDelete: (note) async {
                            await _databaseNotesService.deleteNote(id: note.id);
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
