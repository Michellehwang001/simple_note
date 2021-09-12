import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String desc;
  final String noteOwnerId;
  final Timestamp timestamp;

  const Note({required this.id, required this.title, required this.desc,
    required this.noteOwnerId, required this.timestamp});

  // factory Constructor
  factory Note.fromDoc(DocumentSnapshot noteDoc) {
    final noteData = noteDoc.data();

    return Note(
      id: noteDoc.id,
      title: (noteData as Map)['title'],
      desc: noteData['desc'],
      noteOwnerId: noteData['noteOwnerId'],
      timestamp: noteData['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'noteOwnerId': noteOwnerId,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [id, title, desc, noteOwnerId, timestamp];

/*
  ChecklistModel.fromJson(dynamic json) {
    index = json["index"];
    title = json["title"];
    housing = json["housing"];
    article = json["article"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["index"] = index;
    map["title"] = title;
    map["housing"] = housing;
    map["article"] = article;
    return map;
  }
   */

}