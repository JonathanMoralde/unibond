import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  Future<void> removeMember(String memberUid, String memberName,
      String groupName, Map<String, dynamic> userDetails) async {
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

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(result.docs.first.id)
          .update({
        'latest_chat_message':
            '${userDetails['full_name']} removed ${memberName} joined the group',
        'latest_chat_user': userDetails['uid'],
        'latest_timestamp': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(result.docs.first.id)
          .collection('messages')
          .add({
        'is_read': false,
        'content':
            '${userDetails['full_name']} removed ${memberName} joined the group',
        'sender_id': userDetails['uid'],
        'timestamp': Timestamp.now(),
        'type': 'notify',
        'sender_name': userDetails['full_name'],
        'sender_profile_pic': userDetails['profile_pic'],
      });
    } catch (e) {
      print('error setting user as admin');
    }
  }

  Future<void> leaveGroup(String groupDocId) async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final result = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupDocId)
          .get();
      final resultMap = result.data() as Map<String, dynamic>;

      if ((resultMap['admin'] as List<dynamic>).contains(userUid) &&
          (resultMap['admin'] as List<dynamic>).length == 1) {
        Fluttertoast.showToast(
            msg: 'Set a new admin first before leaving group',
            gravity: ToastGravity.CENTER);
        return;
      } else {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(groupDocId)
            .update({
          'members': FieldValue.arrayRemove([userUid]),
          'admin': FieldValue.arrayRemove([userUid]),
        });
      }
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
