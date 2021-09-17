import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_note/constants/db_constants.dart';
import 'package:simple_note/models/user_model.dart';

class ProfileState extends Equatable {
  final bool loading;
  final User? user;

  const ProfileState({required this.loading, this.user});

  ProfileState copyWith({required bool loading, User? user}) {
    return ProfileState(loading: loading, user: user ?? this.user);
  }

  // string으로 프린트하기 좋게 만듬..
  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [loading, user];
}

class ProfileProvider with ChangeNotifier {
  ProfileState state = const ProfileState(loading: false);

  Future<void> getUserProfile(String userId) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      DocumentSnapshot userDoc = await usersRef.doc(userId).get();

      if (userDoc.exists) {
        User user = User.fromDoc(userDoc);
        state = state.copyWith(loading: false, user: user);
        notifyListeners();
      } else {
        throw Exception('유저 정보 가져오기 실패!');
      }
    } on Exception catch (e) {
      print(e);
      state = state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editUserProfile(String userId, String name, String email) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await usersRef.doc(userId).update({
        'name': name,
      });
      state = state.copyWith(
        loading: false,
        user: User(id: userId, name: name, email: email),
      );
      notifyListeners();
    } on Exception catch (e) {
      print(e);
      state = state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }
}
