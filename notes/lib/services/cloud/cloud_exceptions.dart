class CloudException implements Exception {
  const CloudException();
}

class NoteNoteCreatedException implements CloudException {}

class NotesNotFoundException implements CloudException {}

class NoteNotUpdatedException implements CloudException {}

class NoteNotDeletedException implements CloudException {}
