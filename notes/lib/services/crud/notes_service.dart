import 'dart:async';
import 'dart:developer';
import 'package:notes/constants/db.dart';
import 'package:notes/services/crud/database_exceptions.dart';
import 'package:notes/services/crud/model/database_note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:notes/services/crud/model/database_user.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  //private constructor
  NotesService._sharedInstance();

  static final NotesService _shared = NotesService._sharedInstance();

  factory NotesService() => _shared;

  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);

      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );

    if (res.isNotEmpty) {
      throw UserAlreadyExistsExcpetion();
    }

    final userId = await db.insert(userTable, {
      emailCol: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUserByEmail({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      userTable,
      limit: 1,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );

    if (res.isEmpty) {
      throw UserNotExistsException();
    } else {
      return DatabaseUser.fromRow(res.first);
    }
  }

  Future<DatabaseUser> getUserById({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      userTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
    );

    if (res.isEmpty) {
      throw UserNotExistsException();
    } else {
      return DatabaseUser.fromRow(res.first);
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUserByEmail(email: email);
      return user;
    } on UserNotExistsException {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (ex) {
      log(ex.toString());
      rethrow;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser user}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await getUserById(id: user.id);
    if (res != user) {
      throw UserNotExistsException();
    }

    final noteId = await db.insert(noteTable, {
      userIdCol: res.id,
      textCol: '',
    });

    final note = DatabaseNote(id: noteId, userId: user.id, text: '');

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseNote> getNoteById({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      noteTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
    );

    if (res.isEmpty) {
      throw NoteNotExistsException();
    } else {
      final note = DatabaseNote.fromRow(res.first);
      _notes.removeWhere((oldNote) => oldNote.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getNotes({
    required int offset,
    required int limit,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      noteTable,
      offset: offset,
      limit: limit,
    );

    return res.map((r) => DatabaseNote.fromRow(r));
  }

  Future<DatabaseNote> updateNote({
    required int id,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNoteById(id: id);

    final updCount = await db.update(noteTable, {
      textCol: text,
    });

    if (updCount == 0) {
      throw NoteNotUpdatedException();
    } else {
      final updNote = await getNoteById(id: id);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(updNote);
      _notesStreamController.add(_notes);

      return updNote;
    }
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'id =?',
      whereArgs: [id],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedRows = await db.delete(noteTable);
    _notes.clear();
    _notesStreamController.add(_notes);

    return deletedRows;
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getNotes(
      offset: allNotesOffset,
      limit: allNotesLimit,
    );

    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException catch (ex) {
      log(ex.toString());
    }
  }
}
