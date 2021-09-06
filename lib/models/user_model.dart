import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
// Equatable 은 편리하게 두개의 Object가 같은지 알 수 있다.
class User extends Equatable {
  final String id;
  final String name;
  final String email;

  User(this.id, this.name, this.email);

  // // factory Constructor
  // factory User.fromDoc(DocumentSnapshot userDoc) {
  //   final userData = userDoc.data();
  // }

  @override
  List<Object?> get props => [id, name, email];
}