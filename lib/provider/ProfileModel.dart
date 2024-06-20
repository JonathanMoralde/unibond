import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileModel extends ChangeNotifier {
  Map<String, dynamic> _userDetails = {};

  Map<String, dynamic> get userDetails => _userDetails;

  ProfileModel() {
    _initializeUserDetails();
  }

  Future<void> _initializeUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await fetchUserDetails(user);
    }
  }

  Future<void> fetchUserDetails(User user) async {
    final uid = user.uid;

    try {
      final DocumentSnapshot<Map<String, dynamic>> result =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      _userDetails = result.data() ?? {};
      notifyListeners();
    } catch (e) {
      // Handle any errors here
      print('Error fetching user details: $e');
    }
  }

  void removeFriend(String friendUid) {
    userDetails['friends'].remove(friendUid);
    notifyListeners();
  }

  void removeRequest(String requestingUid) {
    userDetails['requests'].remove(requestingUid);
    notifyListeners();
  }

  void addfriend(String newFriendUid) {
    userDetails['friends'].add(newFriendUid);
    notifyListeners();
  }

  void resetState() {
    _userDetails = {};
    notifyListeners();
  }
}
