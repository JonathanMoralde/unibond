import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:http/http.dart' as http;

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

  Future<void> sendMessage(String message, String friendUid,
      String currentUserName, String? currentUserPic) async {
    if (message.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final filter = ProfanityFilter.filterAdditionally([
        "amputa",
        "animal ka",
        "bilat",
        "binibrocha",
        "bobo",
        "bogo",
        "boto",
        "brocha",
        "burat",
        "bwesit",
        "bwisit",
        "demonyo ka",
        "engot",
        "etits",
        "gaga",
        "gagi",
        "gago",
        "habal",
        "hayop ka",
        "hayup",
        "hinampak",
        "hinayupak",
        "hindot",
        "hindutan",
        "hudas",
        "iniyot",
        "inutel",
        "inutil",
        "iyot",
        "kagaguhan",
        "kagang",
        "kantot",
        "kantotan",
        "kantut",
        "kantutan",
        "kaululan",
        "kayat",
        "kiki",
        "kikinginamo",
        "kingina",
        "kupal",
        "leche",
        "leching",
        "lechugas",
        "lintik",
        "nakakaburat",
        "nimal",
        "ogag",
        "olok",
        "pakingshet",
        "pakshet",
        "pakyu",
        "pesteng yawa",
        "poke",
        "poki",
        "pokpok",
        "poyet",
        "pu'keng",
        "pucha",
        "puchanggala",
        "puchangina",
        "puke",
        "puki",
        "pukinangina",
        "puking",
        "punyeta",
        "puta",
        "pota",
        "putang",
        "putang ina",
        "putangina",
        "putanginamo",
        "putaragis",
        "putragis",
        "puyet",
        "ratbu",
        "shunga",
        "sira ulo",
        "siraulo",
        "suso",
        "susu",
        "tae",
        "taena",
        "tamod",
        "tanga",
        "tangina",
        "taragis",
        "tarantado",
        "tete",
        "teti",
        "timang",
        "tinil",
        "tite",
        "titi",
        "tungaw",
        "ulol",
        "ulul",
        "ungas",
      ]);
      String cleanString = filter.censor(message);

      print(cleanString);

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
            'content': cleanString,
            'receiver_id': friendUid,
            'sender_id': uid,
            'timestamp': timeSent,
            'type': 'text'
          });

          await chatDoc.update({
            'latest_chat_message': cleanString,
            'latest_chat_user': uid,
            'latest_timestamp': timeSent,
            'latest_chat_read': false
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
              'latest_chat_message': cleanString,
              'latest_chat_user': uid,
              'latest_timestamp': timeSent,
              'latest_chat_read': false
            });

            // Get the ID of the newly created chat document
            String newChatDocId = newChatDocRef.id;

            // Create a messages subcollection for the new chat
            CollectionReference messagesCollection =
                newChatDocRef.collection('messages');

            // Add the initial message to the messages subcollection
            await messagesCollection.add({
              'is_read': false,
              'content': cleanString,
              'receiver_id': friendUid,
              'sender_id': uid,
              'timestamp': timeSent,
              'type': 'text'
            });

            _chatDocId = newChatDocId;
            notifyListeners();

            // sendNotification('message');
          } catch (e) {
            print("error sending message, line 81: $e");
          }
        }

        sendPushMessage(
            friendUid, currentUserName, cleanString, currentUserPic);
      } catch (e) {
        print("error sending msg, line 85 $e");
      }

      // chatTextFieldController.clear();

      // !======== SEND A NOTIF=================
    }
  }

  Future<void> sendImage(File image, String friendUid, String currentUserName,
      String? currentUserPic) async {
    try {
      print(image.path);
      final hasNudity =
          await FlutterNudeDetector.detect(path: image.path, threshold: 0.1);
      print(hasNudity);
      if (hasNudity) {
        Fluttertoast.showToast(msg: "This photo is prohibited");
        print('nude detected');
        return;
      }
      print('this executed');
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
          'latest_chat_read': false
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
          'latest_chat_read': false
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
      sendPushMessage(
          friendUid, currentUserName, 'Send a photo', currentUserPic);
    } catch (e) {
      print('unable to send image: $e');
    }
  }

  Future<void> sendCallDurationMessage(String message, String friendUid) async {
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
            'is_read': true,
            'content': message,
            'receiver_id': friendUid,
            'sender_id': uid,
            'timestamp': timeSent,
            'type': 'notify'
          });

          await chatDoc.update({
            'latest_chat_message': message,
            'latest_chat_user': uid,
            'latest_timestamp': timeSent,
            'latest_chat_read': true
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
              'latest_chat_read': true
            });

            // Get the ID of the newly created chat document
            String newChatDocId = newChatDocRef.id;

            // Create a messages subcollection for the new chat
            CollectionReference messagesCollection =
                newChatDocRef.collection('messages');

            // Add the initial message to the messages subcollection
            await messagesCollection.add({
              'is_read': true,
              'content': message,
              'receiver_id': friendUid,
              'sender_id': uid,
              'timestamp': timeSent,
              'type': 'notify'
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

  Future<void> sendMissedCall(String message, String friendUid) async {
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
            'is_read': true,
            'content': message,
            'receiver_id': friendUid,
            'sender_id': uid,
            'timestamp': timeSent,
            'type': 'call'
          });

          await chatDoc.update({
            'latest_chat_message': message,
            'latest_chat_user': uid,
            'latest_timestamp': timeSent,
            'latest_chat_read': false
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
              'latest_chat_read': false
            });

            // Get the ID of the newly created chat document
            String newChatDocId = newChatDocRef.id;

            // Create a messages subcollection for the new chat
            CollectionReference messagesCollection =
                newChatDocRef.collection('messages');

            // Add the initial message to the messages subcollection
            await messagesCollection.add({
              'is_read': false,
              'content': message,
              'receiver_id': friendUid,
              'sender_id': uid,
              'timestamp': timeSent,
              'type': 'call'
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

  Future<void> sendPushMessage(String friendId, String currentUserName,
      String message, String? currentUserPic) async {
    final String notificationTitle = currentUserName;
    final String notificationBody = message;

    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .collection('fcm_tokens')
        .get();

    if (result.docs.isNotEmpty) {
      // get fcm tokens of the user
      final List<String> fcmTokens =
          result.docs.map((doc) => doc.data()['fcm_token'] as String).toList();

      for (final fcmToken in fcmTokens) {
        final response = await http.post(
          Uri.parse('https://unibond-token-server.onrender.com/send_message'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'token': fcmToken,
            'title': notificationTitle,
            'body': notificationBody,
            'userId': friendId,
            'chatDocId': chatDocId,
            'senderName': currentUserName,
            'senderId': FirebaseAuth.instance.currentUser!.uid,
            'senderPic': currentUserPic ?? '',
          }),
        );

        if (response.statusCode == 200) {
          print("Notification sent successfully");
        } else {
          print("Failed to send notification: ${response.body}");
        }
      }
    }
  }

  Future<void> messageNotification(
      String fromUid, String fromName, String receiverUid, bool isPhoto) async {
    // final Timestamp today = Timestamp.now();

    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final Timestamp startOfDayTimestamp = Timestamp.fromDate(startOfDay);
    try {
      // Query to check if a notification has been sent today for a message
      QuerySnapshot<Map<String, dynamic>> existingNotification =
          await FirebaseFirestore.instance
              .collection('notification')
              .where('from_uid', isEqualTo: fromUid)
              .where('is_message', isEqualTo: true)
              .where('dateTime', isGreaterThanOrEqualTo: startOfDayTimestamp)
              .get();

      if (existingNotification.docs.isEmpty) {
        // If no notification has been sent for a message today, proceed with sending a new notification

        // Rest of your existing message sending logic

        // After sending the message, create a notification
        await FirebaseFirestore.instance.collection('notification').add({
          'chat_doc_id': chatDocId ?? '',
          'dateTime': Timestamp.now(),
          'from_name': fromName,
          'from_uid': fromUid,
          'is_friend_request': false,
          'is_friend_accept': false,
          'is_event': false,
          'is_group': false,
          'is_message': true,
          'is_read': false,
          'notif_msg':
              isPhoto ? 'sent you a photo. Tap to view!' : 'messaged you.',
          'receiver_uid': receiverUid,
        });
      } else {
        print("Notification already sent for a message today");
      }
    } catch (e) {
      print("error sending notification, line 309: $e");
    }
  }

  void resetState() {
    _chatDocId = null;
    notifyListeners();
  }
}
