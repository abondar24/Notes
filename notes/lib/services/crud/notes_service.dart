import 'package:flutter/material.dart';
import 'package:notes/constants/db.dart';
import 'package:notes/services/crud/database_exceptions.dart';
import 'package:notes/services/crud/model/database_note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:notes/services/crud/model/database_user.dart';

class NotesService {
  Database? _db;

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

  Future<void> deleteUser({required String email}) async {
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
    final db = _getDatabaseOrThrow();
    final res = await getUserById(id: user.id);
    if (res != user) {
      throw UserNotExistsException();
    }

    final noteId = await db.insert(noteTable, {
      userIdCol: res.id,
      textCol: '',
    });

    return DatabaseNote(id: noteId, userId: user.id, text: '');
  }

  Future<DatabaseNote> getNoteById({required int id}) async {
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      userTable,
      limit: 1,
      where: 'id =?',
      whereArgs: [id],
    );

    if (res.isEmpty) {
      throw NoteNotExistsException();
    } else {
      return DatabaseNote.fromRow(res.first);
    }
  }

  Future<Iterable<DatabaseNote>> getNotes({
    required int offset,
    required int limit,
  }) async {
    final db = _getDatabaseOrThrow();
    final res = await db.query(
      userTable,
      offset: offset,
      limit: limit,
    );

    final notes = res.map((r) => DatabaseNote.fromRow(r));

    return notes;
  }

  Future<DatabaseNote> updateNote({
    required int id,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNoteById(id: id);

    final updCount = await db.update(noteTable, {
      textCol: text,
    });

    if (updCount == 0) {
      throw NoteNotUpdatedException();
    } else {
      return await getNoteById(id: id);
    }
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      userTable,
      where: 'id =?',
      whereArgs: [id],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }
}
