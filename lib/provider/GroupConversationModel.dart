import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';

class GroupConversationModel extends ChangeNotifier {
  String? _chatDocId;
  String? get chatDocId => _chatDocId;

  String formatDateTime(DateTime timeReceived) {
    DateTime now = DateTime.now();

    DateTime dateToday = DateTime(now.year, now.month, now.day);
    DateTime dateReceived =
        DateTime(timeReceived.year, timeReceived.month, timeReceived.day);

    bool isSameDate = dateToday.isAtSameMomentAs(dateReceived);

    if (isSameDate) {
      return DateFormat('hh:mm a').format(timeReceived);
    } else if (timeReceived.isAfter(now.subtract(const Duration(days: 6)))) {
      return DateFormat('EEE \'at\' hh:mm a').format(timeReceived);
    } else if (timeReceived
        .isAfter(DateTime(now.year - 1, now.month, now.day))) {
      return DateFormat('MMM d \'at\' hh:mm a').format(timeReceived);
    } else {
      return DateFormat('MM/dd/yy \'at\' hh:mm a').format(timeReceived);
    }
  }

  void setChatDocId(String? docId) {
    _chatDocId = docId;
    notifyListeners();
  }

  Future<void> fetchDoc(String groupName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .where("group_name", isEqualTo: groupName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want the first matching document
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        String docId = docSnapshot.id;

        _chatDocId = docId;
        notifyListeners();

        // Use the document ID and data as needed
        print('Document ID: $docId');
      } else {
        print('No document found for the given group name');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMessages() {
    if (chatDocId == null) {
      // Return an empty stream if chatDocId is null
      return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('groups')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> saveImage(String imageUrl) async {
    try {
      GallerySaver.saveImage(imageUrl).then((success) {
        Fluttertoast.showToast(msg: 'Image saved to gallery!');
      });
      ;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to save image: $e');
    }
  }

  Future<void> sendMessage(
      String message, String userName, String userProfPic) async {
    if (message.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        if (chatDocId != null) {
          // ! =========== IF CHAT ALREADY EXIST ==================
          DocumentReference chatDoc =
              FirebaseFirestore.instance.collection('groups').doc(chatDocId);

          CollectionReference messagesCollection =
              chatDoc.collection('messages');

          Timestamp timeSent = Timestamp.now();

          await messagesCollection.add({
            'is_read': false,
            'content': message,
            'sender_id': uid,
            'sender_name': userName,
            'sender_profile_pic': userProfPic,
            'timestamp': timeSent,
            'type': 'text'
          });

          await chatDoc.update({
            'latest_chat_message': message,
            'latest_chat_user': uid,
            'latest_timestamp': timeSent,
          });

          print('message sent successfully');
          // sendNotification('message');
        }
      } catch (e) {
        print("error sending msg, line 85 $e");
      }

      // chatTextFieldController.clear();

      // !======== SEND A NOTIF=================
    }
  }

  Future<void> sendImage(
      File image, String groupName, String userName, String userProfPic) async {
    try {
      // Upload the image to Firebase Storage
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final ext = image.path.split('.').last;

      final storageRef = FirebaseStorage.instance.ref().child(
          'groups/$groupName/${DateTime.now().millisecondsSinceEpoch}.$ext');
      await storageRef
          .putFile(image, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) {
        print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
      });

      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();

      if (chatDocId != null) {
        // ! =========== IF CHAT ALREADY EXIST ==================
        DocumentReference chatDoc =
            FirebaseFirestore.instance.collection('groups').doc(chatDocId);

        CollectionReference messagesCollection = chatDoc.collection('messages');

        Timestamp timeSent = Timestamp.now();

        await messagesCollection.add({
          'is_read': false,
          'content': imageUrl,
          'sender_id': userUid,
          'timestamp': timeSent,
          'sender_name': userName,
          'sender_profile_pic': userProfPic,
          'type': 'image'
        });

        await chatDoc.update({
          'latest_chat_message': '[image]',
          'latest_chat_user': userUid,
          'latest_timestamp': timeSent,
        });

        print('message sent successfully');
        // sendNotification('message');
      }
    } catch (e) {
      print('unable to send image: $e');
    }
  }

  void resetState() {
    _chatDocId = null;
    notifyListeners();
  }
}
