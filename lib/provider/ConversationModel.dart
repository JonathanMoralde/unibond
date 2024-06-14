import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';

class ConversationModel extends ChangeNotifier {
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

  String generateConversationId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchDoc(String friendUid) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final result = FirebaseFirestore.instance
        .collection('chats')
        .where(
          "composite_id",
          isEqualTo: generateConversationId(uid, friendUid),
        )
        .snapshots();

    return result;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchMessages() {
    if (chatDocId == null) {
      // Return an empty stream if chatDocId is null
      return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String message, String friendUid) async {
    if (message.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        if (chatDocId != null) {
          // ! =========== IF CHAT ALREADY EXIST ==================
          DocumentReference chatDoc =
              FirebaseFirestore.instance.collection('chats').doc(chatDocId);

          CollectionReference messagesCollection =
              chatDoc.collection('messages');

          Timestamp timeSent = Timestamp.now();

          await messagesCollection.add({
            'is_read': false,
            'content': message,
            'receiver_id': friendUid,
            'sender_id': uid,
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
        } else {
          // ! ========== IF CHAT IS A NEW CONVERSATION ==========
          try {
            CollectionReference chatsCollection =
                FirebaseFirestore.instance.collection('chats');

            Timestamp timeSent = Timestamp.now();

            // Create a new chat document and get its reference
            DocumentReference newChatDocRef = await chatsCollection.add({
              'users_id': [uid, friendUid],
              'composite_id': generateConversationId(uid, friendUid),
              'latest_chat_message': message,
              'latest_chat_user': uid,
              'latest_timestamp': timeSent,
            });

            // Get the ID of the newly created chat document
            String newChatDocId = newChatDocRef.id;

            // Create a messages subcollection for the new chat
            CollectionReference messagesCollection =
                newChatDocRef.collection('messages');

            // Add the initial message to the messages subcollection
            await messagesCollection.add({
              'is_read': false,
              'message_text': message,
              'receiver_id': friendUid,
              'sender_id': uid,
              'timestamp': timeSent,
            });

            _chatDocId = newChatDocId;
            notifyListeners();

            // sendNotification('message');
          } catch (e) {
            print("error sending message, line 81: $e");
          }
        }
      } catch (e) {
        print("error sending msg, line 85 $e");
      }

      // chatTextFieldController.clear();

      // !======== SEND A NOTIF=================
    }
  }

  Future<void> sendImage(File image, String friendUid) async {
    try {
      // Upload the image to Firebase Storage
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final ext = image.path.split('.').last;

      final storageRef = FirebaseStorage.instance.ref().child(
          'chats/${generateConversationId(userUid, friendUid)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
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
            FirebaseFirestore.instance.collection('chats').doc(chatDocId);

        CollectionReference messagesCollection = chatDoc.collection('messages');

        Timestamp timeSent = Timestamp.now();

        await messagesCollection.add({
          'is_read': false,
          'content': imageUrl,
          'receiver_id': friendUid,
          'sender_id': userUid,
          'timestamp': timeSent,
          'type': 'image'
        });

        await chatDoc.update({
          'latest_chat_message': '[image]',
          'latest_chat_user': userUid,
          'latest_timestamp': timeSent,
        });

        print('message sent successfully');
        // sendNotification('message');
      } else {
        // ! ========== IF CHAT IS A NEW CONVERSATION ==========
        CollectionReference chatsCollection =
            FirebaseFirestore.instance.collection('chats');

        Timestamp timeSent = Timestamp.now();

        // Create a new chat document and get its reference
        DocumentReference newChatDocRef = await chatsCollection.add({
          'users_id': [userUid, friendUid],
          'composite_id': generateConversationId(userUid, friendUid),
          'latest_chat_message': '[image]',
          'latest_chat_user': userUid,
          'latest_timestamp': timeSent,
        });

        // Get the ID of the newly created chat document
        String newChatDocId = newChatDocRef.id;

        // Create a messages subcollection for the new chat
        CollectionReference messagesCollection =
            newChatDocRef.collection('messages');

        // Add the initial message to the messages subcollection
        await messagesCollection.add({
          'is_read': false,
          'content': imageUrl,
          'receiver_id': friendUid,
          'sender_id': userUid,
          'timestamp': timeSent,
          'type': 'image'
        });

        _chatDocId = newChatDocId;
        notifyListeners();

        // sendNotification('message');
      }
    } catch (e) {
      print('unable to send image: $e');
    }
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

  Future<void> markMessageAsRead(String chatDocId, String messageDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatDocId)
          .collection('messages')
          .doc(messageDocId)
          .update({'is_read': true});
    } catch (e) {
      print("Error marking message as read: $e");
    }
  }

  void resetState() {
    _chatDocId = null;
    notifyListeners();
  }
}
