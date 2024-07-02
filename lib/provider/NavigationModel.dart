import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavigationModel extends ChangeNotifier {
  int currentIndex = 4;

  void changeIndex(int newIndex) {
    currentIndex = newIndex;
    notifyListeners();
  }

  void resetState() {
    currentIndex = 4;
    notifyListeners();
  }

  String? lastCallId;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCalls() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final result = FirebaseFirestore.instance
        .collection('calls')
        .where('called_uid', isEqualTo: uid)
        .where('active', isEqualTo: true)
        .snapshots();

    return result;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchGroupCalls() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final result = FirebaseFirestore.instance
        .collection('group_calls')
        .where('caller_uid', isNotEqualTo: uid)
        .where('members', arrayContains: uid)
        .where('active', isEqualTo: true)
        .snapshots();

    return result;
  }

  void setLastCallId(String id) {
    lastCallId = id;
    // notifyListeners();
  }
}
