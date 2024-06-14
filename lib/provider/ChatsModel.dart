import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unibond/model/MessageData.dart';

class ChatsModel extends ChangeNotifier {
  Stream<QuerySnapshot> fetchMessages() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    print(uid);
    return FirebaseFirestore.instance
        .collection('chats')
        .where('users_id', arrayContains: uid)
        .orderBy('latest_timestamp', descending: true)
        .snapshots();
  }

  Future<List<MessageData>> processMessageDocs(
      List<DocumentSnapshot> docs) async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;

    List<MessageData> chats = [];
    try {
      for (final chat in docs) {
        final chatData = chat.data() as Map<String, dynamic>;
        List<String> users = (chatData['users_id'] as List<dynamic>)
            .map((item) => item.toString())
            .toList();
        String docId = chat.id;
        String friendId = users.firstWhere((id) => id != userUid); //!or user id
        String? userName; //! or user full name
        String? profilePic;
        Timestamp latestChatTimeStamp = chatData['latest_timestamp'];
        String latestChatUser = chatData['latest_chat_user'];
        String latestChatMsg = chatData['latest_chat_message'];
        bool isRead = true;

        final userQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: friendId)
            .get();

        if (userQuery.docs.isNotEmpty) {
          userName = userQuery.docs.first.get('full_name');
          profilePic = userQuery.docs.first.get('profile_pic');
        }

        // Fetch the latest message from the messages collection
        final latestMessageQuery = await FirebaseFirestore.instance
            .collection('chats')
            .doc(docId)
            .collection('messages')
            .where('sender_id', isNotEqualTo: userUid)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (latestMessageQuery.docs.isNotEmpty) {
          final latestMessageData = latestMessageQuery.docs.first.data();
          isRead = latestMessageData['is_read'] ?? false;
        }

        if (docId.isNotEmpty &&
            friendId.isNotEmpty &&
            userName != null &&
            profilePic != null &&
            latestChatTimeStamp.toString().isNotEmpty &&
            latestChatUser.isNotEmpty &&
            latestChatMsg.isNotEmpty) {
          final currentChat = MessageData(
              compositeId: chatData['composite_id'],
              chatDocId: docId,
              incomindId: friendId,
              userName: userName,
              userProfPic: profilePic,
              latestTimestamp: latestChatTimeStamp,
              latestChatUser: latestChatUser,
              latestChatMsg: latestChatMsg,
              isRead: isRead);

          chats.add(currentChat);
        }
      }
    } catch (e) {
      print("error fetching message data $e");
    }

    return chats;
  }
}
