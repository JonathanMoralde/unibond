import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupChatDetailsModel extends ChangeNotifier {
  List<Map<String, dynamic>> _membersList = [];
  List<Map<String, dynamic>> get membersList => _membersList;

  Future<void> fetchMembersData(List<String> membersUid) async {
    try {
      List<Map<String, dynamic>> tempList = [];
      for (final uid in membersUid) {
        final result =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        tempList.add(result.data() ?? {});
      }

      _membersList = tempList;
      notifyListeners();
    } catch (e) {
      print('error fetching member data');
    }
  }

// FOR GROUP CARD
  Future<List<Map<String, dynamic>>> fetchMembers(
      List<String> membersUid) async {
    List<Map<String, dynamic>> tempList = [];
    try {
      for (final uid in membersUid) {
        final result =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        tempList.add(result.data() ?? {});
      }
    } catch (e) {
      print("error fetching members $e");
    }
    return tempList;
  }
}
