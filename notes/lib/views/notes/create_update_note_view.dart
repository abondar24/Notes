import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_notes_service.dart';
import 'package:notes/services/database/database_notes_service.dart';
import 'package:notes/utils/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:notes/utils/extensions/context/get_arguments.dart';
import 'package:notes/utils/extensions/context/loc.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/database/database_note.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _cloudNote;

  late final CloudNotesService _cloudNotesService;

  late final TextEditingController _textController;

  bool saveOffine = false;

  @override
  void initState() {
    _cloudNotesService = CloudNotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final text = _textController.text;
    final note = _cloudNote;
    if (note == null) {
      return;
    }

    await _cloudNotesService.updateNote(
      docId: note.docId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetNote() async {
    final widgetNote = context.getArgument<CloudNote>();
    if (widgetNote != null) {
      _cloudNote = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _cloudNote;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;

    final newNote = await _cloudNotesService.createNewNote(
      userId: currentUser.id,
    );
    _cloudNote = newNote;

    return newNote;
  }

  void _deleteNoteIfEmpty() {
    if (_textController.text.isEmpty) {
      final note = _cloudNote;
      if (note != null) {
        _cloudNotesService.deleteNote(docId: note.docId);
      }
    }
  }

  void _saveNoteIfNotEmpty() async {
    final text = _textController.text;
    if (text.isNotEmpty) {
      final note = _cloudNote;
      if (note != null) {
        await _cloudNotesService.updateNote(
          docId: note.docId,
          text: text,
        );
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
        title: Text(context.loc.new_note),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_cloudNote == null || text.isEmpty) {
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
