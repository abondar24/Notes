import 'package:flutter/material.dart';
import 'package:notes/services/database/database_constants.dart';

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSync;

  const DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSync});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idCol] as int,
        userId = map[userIdCol] as int,
        text = map[textCol] as String,
        isSync = (map[isSyncCol] as int) == 1 ? true : false;

  @override
  String toString() => 'Person, ID=$id, userID=$userId, text=$text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
