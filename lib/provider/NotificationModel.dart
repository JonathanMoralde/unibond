import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  static const int _perPage = 10;

  Future<void> fetchNotif({bool loadMore = false}) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      Query query = FirebaseFirestore.instance
          .collection("notification")
          .where("receiver_uid", isEqualTo: uid)
          .orderBy('dateTime', descending: true)
          .limit(_perPage);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      var querySnapshot = await query.get();

      if (querySnapshot.docs.length < _perPage) {
        _hasMore = false;
      }

      List<Map<String, dynamic>> tempNotifications = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> tempData = doc.data() as Map<String, dynamic>;
        tempData['docId'] = doc.id;
        if (tempData['is_group'] || tempData['is_event']) {
          final result = await FirebaseFirestore.instance
              .collection('groups')
              .where('group_name', isEqualTo: tempData['group_name'])
              .get();

          tempData['pic'] = result.docs.first.data()['group_pic'];
          tempData['group_data'] = result.docs.first.data();
        } else {
          final result = await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: tempData['from_uid'])
              .get();

          tempData['pic'] = result.docs.first.data()['profile_pic'];
        }
        tempNotifications.add(tempData);
      }

      if (loadMore) {
        _notifications.addAll(tempNotifications);
      } else {
        _notifications = tempNotifications;
      }

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching notifications: $e");
      // Handle errors
    }
  }

  String formatDateTime(Timestamp dateTime) {
    DateTime notifDateTime = dateTime.toDate();
    DateTime now = DateTime.now();

    DateTime dateToday = DateTime(now.year, now.month, now.day);
    DateTime notifDate =
        DateTime(notifDateTime.year, notifDateTime.month, notifDateTime.day);

    bool isSameDate = dateToday.isAtSameMomentAs(notifDate);

    String formattedDateTime = (isSameDate)
        ? DateFormat('hh:mm a').format(notifDateTime)
        : (notifDateTime.isAfter(
            now.subtract(const Duration(days: 6)),
          ))
            ? DateFormat('EEE \'at\' hh:mm a').format(notifDateTime)
            : (notifDateTime.isAfter(
                DateTime(now.year - 1, now.month, now.day),
              ))
                ? DateFormat('MMM d \'at\' hh:mm a').format(notifDateTime)
                : DateFormat('MM/dd/yy \'at\' hh:mm a').format(notifDateTime);

    return formattedDateTime;
  }

  Future<void> updateReadStatus(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notification')
          .doc(docId)
          .update({
        "is_read": true,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String uid) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      return result.docs.first.data();
    } catch (e) {
      print('failed to fetch user data $e');
    }

    return {};
  }
}
