import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_constants.dart';
import 'package:notes/services/cloud/cloud_exceptions.dart';
import 'package:notes/services/cloud/cloud_note.dart';

class CloudNotesService {
  final notes = FirebaseFirestore.instance.collection('notes');

  static final CloudNotesService _shared = CloudNotesService._sharedInstance();

  CloudNotesService._sharedInstance();

  factory CloudNotesService() => _shared;

  void createNewNote({required String userId}) async {
    await notes.add({
      userIdField: userId,
      textField: '',
    });
  }

  Stream<Iterable<CloudNote>> allNotes({
    required String userId,
  }) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.userId == userId));

  Future<Iterable<CloudNote>> getNotes({
    required String userId,
  }) async {
    try {
      return await notes
          .where(
            userIdField,
            isEqualTo: userId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudNote(
                  docId: doc.id,
                  userId: doc.data()[userIdField],
                  text: doc.data()[textField],
                );
              },
            ),
          );
    } catch (ex) {
      log(ex.toString());
      throw NotesNotFoundException();
    }
  }

  Future<void> updateNote({
    required String docId,
    required String text,
  }) async {
    try {
      await notes.doc(docId).update({textField: text});
    } catch (ex) {
      log(ex.toString());
      throw NoteNotUpdatedException();
    }
  }

  Future<void> deleteNote({
    required String docId,
  }) async {
    try {
      await notes.doc(docId).delete();
    } catch (ex) {
      log(ex.toString());
      throw NoteNotDeletedException();
    }
  }
}
