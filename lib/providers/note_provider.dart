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
    return NoteListState(loading: loading, notes: notes ?? this.notes);
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [loading, notes];
}

class NoteProvider extends ChangeNotifier {
  NoteListState state = const NoteListState(loading: false, notes: []);

  // 다음 노트가 있는지 알려줌 true: 있음, false: 없음
  bool _hasNextDocs = true;

  // getter
  bool get hasNextDocs => _hasNextDocs;

  void handleError(Exception e) {
    print(e);
    state = state.copyWith(loading: false);
    notifyListeners();
  }

  // 한페이지만큼의 노트를 읽는다.
  Future<void> getNotes(String userId, int limit) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      // collection 정보는 QuerySnapshot 에 저장되고, Doc 정보는 DocumentSnapshot에 저장.
      QuerySnapshot userNotesSnapshot;
      DocumentSnapshot? startAfterDoc;

      // 처음 불러오면 notes가 empty
      if (state.notes.isNotEmpty) {
        Note n = state.notes.last;
        // 마지막 document를 읽어옴.
        startAfterDoc =
            await notesRef.doc(userId).collection('userNotes').doc(n.id).get();
      } else {
        // notes 가 비어있으면 null 값
        startAfterDoc = null;
      }

      final refNotes = notesRef
          .doc(userId)
          .collection('userNotes')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      // 처음 읽는 것
      if (startAfterDoc == null) {
        userNotesSnapshot = await refNotes.get();
      } else {
        // startAfterDocument(10) 이 들어가면 11부터 읽어온다.
        userNotesSnapshot =
            await refNotes.startAfterDocument(startAfterDoc).get();
      }

      List<Note> notes = userNotesSnapshot.docs.map((noteDoc) {
        return Note.fromDoc(noteDoc);
      }).toList();

      // 더 이상 읽을게 없음. 마지막.
      if (userNotesSnapshot.docs.length < limit) {
        _hasNextDocs = false;
      }

      state = state.copyWith(loading: false, notes: [...state.notes, ...notes]);
      notifyListeners();

    } on Exception catch (e) {
      handleError(e);
      rethrow;
    }
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

  // search snapshot 두개를 하나로 묶어버린다.
  Future<List<QuerySnapshot>> searchNotes(
      String userId, String searchTerm) async {
    try {
      final snapshotOne = notesRef
          .doc(userId)
          .collection('userNotes')
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThanOrEqualTo: searchTerm + 'z');

      final snapshotTwo = notesRef
          .doc(userId)
          .collection('userNotes')
          .where('desc', isGreaterThanOrEqualTo: searchTerm)
          .where('desc', isLessThanOrEqualTo: searchTerm + 'z');

      final userNotesSnapshot =
          await Future.wait([snapshotOne.get(), snapshotTwo.get()]);

      return userNotesSnapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addNote(Note newNote) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      final DocumentReference docRef =
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
