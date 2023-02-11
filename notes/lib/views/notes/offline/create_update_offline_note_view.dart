import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/database/database_notes_service.dart';
import 'package:notes/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notes/utils/extensions/context/get_arguments.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../services/database/database_note.dart';

class CreateUpdateOfflineNoteView extends StatefulWidget {
  const CreateUpdateOfflineNoteView({super.key});

  @override
  State<CreateUpdateOfflineNoteView> createState() =>
      _CreateUpdateOfflineNoteViewState();
}

class _CreateUpdateOfflineNoteViewState
    extends State<CreateUpdateOfflineNoteView> {
  DatabaseNote? _databaseNote;

  late final DatabaseNotesService _databaseNotesService;

  late final TextEditingController _textController;

  bool saveOffine = false;

  @override
  void initState() {
    _databaseNotesService = DatabaseNotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final text = _textController.text;
    final note = _databaseNote;
    if (note == null) {
      return;
    }
    await _databaseNotesService.updateNote(
      id: note.id,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNote> createOrGetNote() async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _databaseNote = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _databaseNote;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final owner = await _databaseNotesService.getUserByEmail(
      email: currentUser.email,
    );

    final newNote = await _databaseNotesService.createNote(
      user: owner,
    );
    _databaseNote = newNote;

    return newNote;
  }

  void _deleteNoteIfEmpty() {
    if (_textController.text.isEmpty) {
      final note = _databaseNote;
      if (note != null) {
        _databaseNotesService.deleteNote(id: note.id);
      }
    }
  }

  void _saveNoteIfNotEmpty() async {
    final text = _textController.text;
    if (text.isNotEmpty) {
      final note = _databaseNote;
      if (note != null) {
        await _databaseNotesService.updateNote(id: note.id, text: text);
      }
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.new_offline_note),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_databaseNote == null || text.isEmpty) {
                await showCannotShareEmptyDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: context.loc.new_note_hint,
                    ),
                  ),
                ],
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
