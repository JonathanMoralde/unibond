import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthModel extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthModel() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

// for register
  Future<void> registerUser(
      String fullName, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'full_name': fullName,
          'email': email,
          'uid': uid,
          'friends': [],
          'interests': [],
          'bio': '',
          'profile_pic': '',
          'cover_pic': '',
        }).then((_) {
          Fluttertoast.showToast(
            msg: 'Account was registered successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.black,
          );
        });
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Error occured during registration, please try again!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

// for login
  Future<void> loginUser(String email, String password) async {
    try {
      await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((_) {
        Fluttertoast.showToast(
          msg: 'Account was registered successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.black,
        );
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Error occured during login, please try again!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
