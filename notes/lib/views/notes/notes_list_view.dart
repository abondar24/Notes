import 'package:flutter/material.dart';
import 'package:notes/services/crud/model/database_note.dart';
import 'package:notes/utils/dialogs/delete_dialog.dart';

typedef DeleteCallback = void Function(DatabaseNote);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;

  final DeleteCallback onDelete;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDelete(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
