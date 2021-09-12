import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
// Equatable 은 편리하게 두개의 Object가 같은지 알 수 있다.

class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  // // factory Constructor
  factory User.fromDoc(DocumentSnapshot userDoc) {
    final userData = userDoc.data();

    // name: (userData as Map)['name'] --> 한참 헤맸음....
    return User(id: userDoc.id, name: (userData as Map)['name'], email: userData['email']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, name, email];
}