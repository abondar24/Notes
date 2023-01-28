import 'package:flutter/material.dart';
import '../../../services/database/database_note.dart';
import 'package:notes/utils/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNote);

class NotesOfflineListView extends StatelessWidget {
  final List<DatabaseNote> notes;

  final NoteCallback onDelete;
  final NoteCallback onTap;

  const NotesOfflineListView({
    super.key,
    required this.notes,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () {
            onTap(note);
          },
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
