import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualMessage {
  final String msgDocId;
  final String content; //id of shop
  final String receiverId;
  final String senderId;
  final Timestamp timestamp;
  final String type;

  IndividualMessage({
    required this.msgDocId,
    required this.content,
    required this.receiverId,
    required this.type,
    required this.senderId,
    required this.timestamp,
  });
}
