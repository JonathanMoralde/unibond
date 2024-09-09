import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unibond/model/EventsData.dart';

class CreateEventModel extends ChangeNotifier {
  List<DropdownMenuItem<String>> _groupOptions = [];

  List<DropdownMenuItem<String>> get groupOptions => _groupOptions;

  Future<void> fetchAllGroups() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();

      if (querySnapshot.docs.length > 0) {
        final groups = querySnapshot.docs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc['group_name'],
            child: Text(doc[
                'group_name']), // Assuming the group name is stored under the 'groupName' field
          );
        }).toList();

        _groupOptions = groups;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch groups: $e');
    }
  }

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

  Future<String> insertEvent(
      String eventName,
      DateTime date,
      String time,
      String location,
      String groupName,
      String description,
      int selectedColorValue) async {
    try {
      // Create a new document reference with a unique ID
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('events').doc();

      // Set the document data
      await docRef.set({
        'event_name': eventName,
        'event_date': date,
        'event_time': time,
        'location': location,
        'group_name': groupName,
        'description': description,
        'color': selectedColorValue,
        'views': []
      });

      // Get the generated document ID
      String docId = docRef.id;

      return docId;
    } catch (e) {
      print('error inserting event $e');
    }

    return '';
  }

  Future<void> updateEvent(
      String documentId,
      String name,
      DateTime date,
      String time,
      String location,
      String group,
      String description,
      int color) async {
    // Your update logic here, e.g., updating Firestore document
    await FirebaseFirestore.instance
        .collection('events')
        .doc(documentId)
        .update({
      'event_name': name,
      'event_date': date,
      'event_time': time,
      'location': location,
      'group_name': group,
      'description': description,
      'color': color,
    });
  }

  Future<void> newEventNotification(IndivEvents eventData) async {
    // final Timestamp today = Timestamp.now();

    try {
      QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
          .instance
          .collection('groups')
          .where('group_name', isEqualTo: eventData.groupName)
          .get();

      if (result.docs.isNotEmpty) {
        final groupData = result.docs.first.data() as Map<String, dynamic>;
        final members = (groupData['members'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

        for (final uid in members) {
          // After sending the message, create a notification
          await FirebaseFirestore.instance.collection('notification').add({
            'chat_doc_id': result.docs.first.id,
            'dateTime': Timestamp.now(),
            'group_name': eventData.groupName,
            'event_description': eventData.description,
            'event_date': eventData.eventDate,
            'event_name': eventData.eventName,
            'event_doc_id': eventData.eventDocId,
            'event_time': eventData.eventTime,
            'event_location': eventData.location,
            'event_color': eventData.color,
            'is_friend_request': false,
            'is_friend_accept': false,
            'is_event': true,
            'is_group': false,
            'is_message': false,
            'is_read': false,
            'notif_msg':
                'has new event on ${DateFormat('MMMM dd, yyyy').format(DateTime(eventData.eventDate.year, eventData.eventDate.month + 0, eventData.eventDate.day))}. Tap to view details!',
            'receiver_uid': uid,
          });
        }
      }
    } catch (e) {
      print("error sending notification, line 309: $e");
    }
  }
}
