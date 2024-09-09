import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:profanity_filter/profanity_filter.dart';

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
    // notifyListeners();
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
      String message, String userName, String userProfPic, String type) async {
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
            'content': cleanString,
            'sender_id': uid,
            'sender_name': userName,
            'sender_profile_pic': userProfPic,
            'timestamp': timeSent,
            'type': type
          });

          await chatDoc.update({
            'latest_chat_message': cleanString,
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
      File image, String userName, String userProfPic) async {
    try {
      if (chatDocId != null) {
        final hasNudity = await FlutterNudeDetector.detect(path: image.path);
        if (hasNudity) {
          Fluttertoast.showToast(msg: "This photo is prohibited");
          return;
        }
        final groupData = await FirebaseFirestore.instance
            .collection('groups')
            .doc(chatDocId)
            .get();
        final groupDataMap = groupData.data() as Map<String, dynamic>;

        // Upload the image to Firebase Storage
        final userUid = FirebaseAuth.instance.currentUser!.uid;
        final ext = image.path.split('.').last;

        final storageRef = FirebaseStorage.instance.ref().child(
            'groups/${groupDataMap['group_name']}/${DateTime.now().millisecondsSinceEpoch}.$ext');
        await storageRef
            .putFile(image, SettableMetadata(contentType: 'image/$ext'))
            .then((p0) {
          print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
        });

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

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

  Future<void> messageNotification() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    // final Timestamp today = Timestamp.now();

    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final Timestamp startOfDayTimestamp = Timestamp.fromDate(startOfDay);
    try {
      if (chatDocId != null) {
        final groupData = await FirebaseFirestore.instance
            .collection('groups')
            .doc(chatDocId)
            .get();
        final groupDataMap = groupData.data() as Map<String, dynamic>;
        final groupMembersUid = (groupDataMap['members'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

        // Query to check if a notification has been sent today for a message
        QuerySnapshot<Map<String, dynamic>> existingNotification =
            await FirebaseFirestore.instance
                .collection('notification')
                .where('group_name', isEqualTo: groupDataMap['group_name'])
                .where('is_group', isEqualTo: true)
                .where('dateTime', isGreaterThanOrEqualTo: startOfDayTimestamp)
                .get();

        if (existingNotification.docs.isEmpty) {
          // If no notification has been sent for a message today, proceed with sending a new notification

          // Rest of your existing message sending logic

          for (final uid in groupMembersUid) {
            if (uid != userUid) {
              // After sending the message, create a notification
              await FirebaseFirestore.instance.collection('notification').add({
                'chat_doc_id': chatDocId ?? '',
                'dateTime': Timestamp.now(),
                'is_friend_request': false,
                'is_friend_accept': false,
                'is_event': false,
                'is_group': true,
                'is_message': false,
                'is_read': false,
                'group_name': groupDataMap['group_name'],
                'notif_msg': 'has new messages. Tap to view!',
                'receiver_uid': uid,
              });
            }
          }
        } else {
          print("Notification already sent for a message today");
        }
      }
    } catch (e) {
      print("error sending notification, line 309: $e");
    }
  }

  void resetState() {
    _chatDocId = null;
    // notifyListeners();
  }
}
