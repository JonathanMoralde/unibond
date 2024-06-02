import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unibond/main.dart';
import 'package:unibond/provider/ProfileModel.dart';

class AuthModel extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthModel() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
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
          'friend_requests': [],
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
    try {
      await _firebaseAuth.signOut().then((_) {
        _user = null;
        notifyListeners();
        Fluttertoast.showToast(
          msg: 'Logged out successfully!',
          backgroundColor: Colors.green,
          textColor: Colors.black,
        );
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Failed to log out, please try again!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // for forgot pass
  Future<void> sendPasswordResetLink(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email).then((_) {
        Fluttertoast.showToast(
          msg: 'Password reset link sent!',
          backgroundColor: Colors.green,
          textColor: Colors.black,
        );
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Failed to send password reset link, please try again!',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<bool> checkExistingUserDetails() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> result =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      final userDetails = result.data();

      // Check if any of the fields is not empty
      if (userDetails != null) {
        final interests = userDetails['interests'] as List?;
        final bio = userDetails['bio'] as String?;
        final profilePic = userDetails['profile_pic'] as String?;

        // Return true if any of the fields is not empty
        return (interests != null && interests.isNotEmpty) ||
            (bio != null && bio.isNotEmpty) ||
            (profilePic != null && profilePic.isNotEmpty);
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
