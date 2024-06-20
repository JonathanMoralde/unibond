import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel extends ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  Future<void> fetchNotif() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      var querySnapshot = await FirebaseFirestore.instance
          .collection("notification")
          .where("receiver_uid", isEqualTo: uid)
          .orderBy('dateTime', descending: true)
          .get();

      List<Map<String, dynamic>> tempNotifications =
          []; // Temporary list to store fetched data

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> tempData = doc.data();
        tempData['docId'] = doc.id;

        tempNotifications.add(tempData);
      });

      // Fetching shopData for each notification
      // for (var notification in tempNotifications) {
      //   var serviceProviderSnapshot = await FirebaseFirestore.instance
      //       .collection("service_provider")
      //       .doc(notification[
      //           'from_uid']) // Assuming user_doc_id is the ID in service_provider
      //       .get();

      //   if (serviceProviderSnapshot.exists) {
      //     var serviceProviderData = serviceProviderSnapshot.data();
      //     // Accessing service_provider_name
      //     var serviceProviderName =
      //         serviceProviderData!['service_provider_name'];

      //     notification['service_provider_name'] = serviceProviderName;
      //   } else {
      //     // ! FETCH USER INSTEAD
      //     var userQuery = await FirebaseFirestore.instance
      //         .collection('users')
      //         .where('uid', isEqualTo: notification['from_uid'])
      //         .get();

      //     if (userQuery.docs.isNotEmpty) {
      //       String userName = userQuery.docs.first.get("name");

      //       notification['service_provider_name'] = userName;
      //     }
      //   }
      // }

      // Update the state with the fetched data
      // setState(() {
      //   isLoading = false;
      //   notifications = tempNotifications;
      // });
      _notifications = tempNotifications;
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
}
