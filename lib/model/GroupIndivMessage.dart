import 'package:cloud_firestore/cloud_firestore.dart';

class GroupIndivMessage {
  final String msgDocId;
  final String content;
  final String senderId;
  final Timestamp timestamp;
  final String type;
  final bool isRead;
  final String senderName;
  final String? senderProfilePic;

  GroupIndivMessage({
    required this.msgDocId,
    required this.content,
    required this.type,
    required this.senderId,
    required this.timestamp,
    required this.isRead,
    required this.senderName,
    this.senderProfilePic,
  });
}
