import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // firebase에도 User모델이 있음.
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AuthProgressState extends Equatable {
  final bool loading;

  const AuthProgressState({required this.loading});

  // change loading 상태
  AuthProgressState copyWith({bool? loading}) {
    return AuthProgressState(loading: loading ?? this.loading);
  }

  @override
  List<Object?> get props => [loading];
}

// State의 변화를 알려주기위해
class AuthProvider extends ChangeNotifier {
  final _auth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  AuthProgressState state = const AuthProgressState(loading: false);

  Future<void> signUp(
    BuildContext context, {
    required String name,
    required String email,
    required String password,
  }) async {
    // loading 상태 true 변경
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebase_auth.User? signedInUser = userCredential.user;

      await _firestore.collection('users').doc(signedInUser!.uid).set({
        'name': name,
        'email': email,
      });

      state = state.copyWith(loading: false);
      notifyListeners();

      Navigator.pop(context);

    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      state = state.copyWith(loading: false);
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  void signOut() {
    _auth.signOut();
  }
}
