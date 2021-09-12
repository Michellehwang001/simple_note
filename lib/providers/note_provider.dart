/*
* 아래 방식 사용..
notes C - userId1 D - userNotes C- note1, note2, note3
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_note/constants/db_constants.dart';
import 'package:simple_note/models/note_model.dart';

class NoteListState extends Equatable {
  final bool loading;
  final List<Note> notes;

  const NoteListState({required this.loading, required this.notes});

  NoteListState copyWith({required bool loading, List<Note>? notes}) {
    return NoteListState(
        loading: loading ?? this.loading, notes: notes ?? this.notes);
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [loading, notes];
}

class NoteList extends ChangeNotifier {
  NoteListState state = const NoteListState(loading: false, notes: []);

  void handleError(Exception e) {
    print(e);
    state = state.copyWith(loading: false);
    notifyListeners();
  }

  // 모든 노트 다 읽어온다.
  Future<void> getAllNotes(String userId) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      QuerySnapshot userNotesSnapshot = await notesRef
          .doc(userId)
          .collection('userNotes')
          .orderBy('timestamp', descending: true)
          .get();

      List<Note> notes = userNotesSnapshot.docs.map((noteDoc) {
        return Note.fromDoc(noteDoc);
      }).toList();

      state = state.copyWith(loading: false, notes: notes);
      notifyListeners();
    } on Exception catch (e) {
      handleError(e);
      rethrow;
    }
  }

  Future<void> addNote(Note newNote) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      DocumentReference docRef =
          await notesRef.doc(newNote.noteOwnerId).collection('userNotes').add({
        'title': newNote.title,
        'desc': newNote.desc,
        'noteOwnerId': newNote.noteOwnerId,
        'timestamp': newNote.timestamp,
      });

      final note = Note(
        id: docRef.id,
        title: newNote.title,
        desc: newNote.desc,
        noteOwnerId: newNote.noteOwnerId,
        timestamp: newNote.timestamp,
      );

      state = state.copyWith(loading: false, notes: [
        note,
        ...state.notes,
      ]);
      notifyListeners();
    } on Exception catch (e) {
      handleError(e);
    }
  }

  Future<void> updateNote(Note note) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await notesRef
          .doc(note.noteOwnerId)
          .collection('userNotes')
          .doc(note.id)
          .update({
        'title': note.title,
        'desc': note.desc,
      });

      final notes = state.notes.map((n) {
        return n.id == note.id
            ? Note(
                id: n.id,
                title: note.title,
                desc: note.desc,
                noteOwnerId: n.noteOwnerId,
                timestamp: note.timestamp)
            : n;
      }).toList();

      state = state.copyWith(loading: false, notes: notes);
      notifyListeners();
    } on Exception catch (e) {
      handleError(e);
      rethrow;
    }
  }

  Future<void> removeNote(Note note) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await notesRef
          .doc(note.noteOwnerId)
          .collection('userNotes')
          .doc(note.id)
          .delete();

      final notes = state.notes.where((n) => n.id != note.id).toList();

      state = state.copyWith(loading: false, notes: notes);
      notifyListeners();
    } on Exception catch (e) {
      handleError(e);
      rethrow;
    }
  }
}
