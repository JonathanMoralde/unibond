import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageData {
  final String chatDocId;
  final String compositeId;
  final String latestChatMsg;
  final String latestChatUser;
  final Timestamp latestTimestamp;
  final String incomindId;
  final String userName;
  final String userProfPic;
  final bool isRead;

  MessageData(
      {required this.chatDocId,
      required this.compositeId,
      required this.latestChatMsg,
      required this.latestChatUser,
      required this.latestTimestamp,
      required this.incomindId,
      required this.isRead,
      required this.userName,
      required this.userProfPic});
}
