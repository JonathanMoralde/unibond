import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> makeAdmin(String memberUid, String groupName) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('groups')
          .where('group_name', isEqualTo: groupName)
          .get();

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(result.docs.first.id)
          .update({
        'admin': FieldValue.arrayUnion([memberUid])
      });
    } catch (e) {
      print('error setting user as admin');
    }
  }

  Future<void> removeAdmin(String memberUid, String groupName) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('groups')
          .where('group_name', isEqualTo: groupName)
          .get();

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(result.docs.first.id)
          .update({
        'admin': FieldValue.arrayRemove([memberUid])
      });
    } catch (e) {
      print('error setting user as admin');
    }
  }

  Future<void> removeMember(String memberUid, String groupName) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('groups')
          .where('group_name', isEqualTo: groupName)
          .get();

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(result.docs.first.id)
          .update({
        'members': FieldValue.arrayRemove([memberUid])
      });
    } catch (e) {
      print('error setting user as admin');
    }
  }

  void removeMemberinList(String memberUid) {
    _membersList.removeWhere((member) => member['uid'] == memberUid);
    notifyListeners();
  }

  Future<void> leaveGroup(String groupName) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final result = await FirebaseFirestore.instance
          .collection('groups')
          .where('group_name', isEqualTo: groupName)
          .get();

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(result.docs.first.id)
          .update({
        'members': FieldValue.arrayRemove([userUid]),
        'admin': FieldValue.arrayRemove([userUid]),
      });
    } catch (e) {
      print('error leaving group chat: $e');
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
