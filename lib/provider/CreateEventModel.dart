import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateEventModel extends ChangeNotifier {
  List<DropdownMenuItem<String>> _groupOptions = [];

  List<DropdownMenuItem<String>> get groupOptions => _groupOptions;

  Future<void> fetchGroups() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where('admin', arrayContains: userUid)
          .get();

      final groups = querySnapshot.docs.map((doc) {
        return DropdownMenuItem<String>(
          value: doc['group_name'],
          child: Text(doc[
              'group_name']), // Assuming the group name is stored under the 'groupName' field
        );
      }).toList();

      _groupOptions = groups;
      notifyListeners();
    } catch (e) {
      print('Failed to fetch groups: $e');
    }
  }

  Future<void> insertEvent(
      String eventName,
      DateTime date,
      String time,
      String location,
      String groupName,
      String description,
      int selectedColorValue) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc().set({
        'event_name': eventName,
        'event_date': date,
        'event_time': time,
        'location': location,
        'group_name': groupName,
        'description': description,
        'color': selectedColorValue
      });
    } catch (e) {
      print('error inserting event $e');
    }
  }
}
