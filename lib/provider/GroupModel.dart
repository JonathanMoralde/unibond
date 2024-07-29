import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupModel extends ChangeNotifier {
  Stream<QuerySnapshot<Map<String, dynamic>>> getGroupsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Query for groups where the user is a member
    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }
}
