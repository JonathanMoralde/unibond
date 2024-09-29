import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:provider/provider.dart';
import 'package:unibond/main.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:unibond/model/GroupCallModel.dart';
import 'package:unibond/pages/Messages/CallPage.dart';
import 'package:unibond/pages/Messages/GroupCallPage.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/utils/NotificationService.dart';
import 'package:uuid/uuid.dart';

class FirebaseMessagingApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initPushNotification(void Function(int newNotifId) setNewNotifId,
      void Function(Map<String, dynamic> newCallData) setNewCallData) async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('fcm_tokens')
        .doc(fCMToken)
        .set({'fcm_token': fCMToken});

    initPushNotification2(setNewNotifId, setNewCallData);
  }

  void handleMessage(
      RemoteMessage? message,
      void Function(int newNotifId) setNewNotifId,
      void Function(Map<String, dynamic> newCallData) setNewCallData) {
    if (message == null) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    // HANDLE MESSAGE PUSH NOTIFICATION
    if (currentUser != null &&
        message.data['userId'] == currentUser.uid &&
        message.data['chatDocId'] != null) {
      print('${message.notification!.body}');
      if (Provider.of<NavigationModel>(navigatorKey.currentContext!,
                  listen: false)
              .currentIndex !=
          0) {
        int notificationId = generateUniqueNotificationId();
        NotificationService.showMessageNotification(
          id: notificationId,
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: {
            'chatDocId': message.data['chatDocId'],
            'senderName': message.data['senderName'],
            'senderId': message.data['senderId'],
            'senderPic': message.data['senderPic']
          },
        );
      }
      return;
    }

    // HANDLE CALL PUSH NOTIFICATION
    if (currentUser != null && message.data['userId'] == currentUser.uid) {
      Map<String, dynamic> callData = jsonDecode(message.data['callData']);
      print("CALL DATA: $callData");
      // showIncomingCall(callData);
      int notificationId = generateUniqueNotificationId();
      setNewNotifId(notificationId); //return notifId in mainLayout
      setNewCallData(callData);

      print(notificationId);
      if (callData['groupName'] != null) {
        print("group name is not null");

        NotificationService.showNotification(
          id: notificationId,
          title: 'Incoming Call',
          body:
              '${callData['callerName']} started a group call in ${callData['groupName']}',
          payload: {
            'navigate': 'true',
            'callId': callData['id'],
            'channelName': callData['channel'],
            'caller': callData['caller'],
            'callerName': callData['callerName'],
            'groupName': callData['groupName'],
            'joined': (callData['joined'] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
                .join(','),
            'rejeceted': (callData['rejected'] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
                .join(','),
            'chatDocId': callData['chatDocId'],
            'isVideoCall': callData['isVideoCall'].toString()
          },
          category: NotificationCategory.Call,
          actionButtons: [
            NotificationActionButton(
              key: 'REJECT',
              label: 'Reject',
              actionType: ActionType.Default,
            ),
            NotificationActionButton(
              key: 'ACCEPT',
              label: 'Accept',
              actionType: ActionType.Default,
            ),
          ],
        );
        return;
      }
      NotificationService.showNotification(
        id: notificationId,
        title: 'Incoming Call',
        body: 'You have an incoming call from ${callData['callerName']}',
        payload: {
          'navigate': 'true',
          'callId': callData['id'],
          'channelName': callData['channel'],
          'caller': callData['caller'],
          'callerName': callData['callerName'],
          'called': callData['called'],
          'isVideoCall': callData['isVideoCall'].toString()
        },
        category: NotificationCategory.Call,
        actionButtons: [
          NotificationActionButton(
            key: 'REJECT',
            label: 'Reject',
            actionType: ActionType.Default,
          ),
          NotificationActionButton(
            key: 'ACCEPT',
            label: 'Accept',
            actionType: ActionType.Default,
          ),
        ],
      );
    }
  }

  // Future<void> showIncomingCall(Map<String, dynamic> callData) async {
  //   FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
  //     switch (event?.event) {
  //       case Event.actionCallAccept:
  //         // Handle call accept
  //         // print(currentCall);

  //         if (callData['groupName'] != null) {
  //           //  Accept call
  //           FirebaseFirestore.instance
  //               .collection('group_calls')
  //               .doc(callData['id'])
  //               .update({
  //             'joined': FieldValue.arrayUnion(
  //                 [FirebaseAuth.instance.currentUser!.uid])
  //           });

  //           final joinedList = (callData['joined'] as List<dynamic>)
  //               .map((e) => e.toString())
  //               .toList();
  //           final rejectedList = (callData['rejected'] as List<dynamic>)
  //               .map((e) => e.toString())
  //               .toList();
  //           final membersList = (callData['members'] as List<dynamic>)
  //               .map((e) => e.toString())
  //               .toList();
  //           print('joined: $joinedList');
  //           print('rejected: $rejectedList');
  //           print('members: $membersList');

  //           // Navigate to CallPage using the global navigator key
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             navigatorKey.currentState?.push(
  //               MaterialPageRoute(
  //                 builder: (context) => GroupCallPage(
  //                   chatDocId: callData['chatDocId'],
  //                   userUid: FirebaseAuth.instance.currentUser!.uid,
  //                   call: GroupCallModel(
  //                       id: callData['id'],
  //                       caller: callData['caller'],
  //                       callerName: callData['callerName'],
  //                       channel: callData['channel'],
  //                       active: true,
  //                       groupName: callData['groupName'],
  //                       joined: [
  //                         FirebaseAuth.instance.currentUser!.uid,
  //                         ...joinedList
  //                       ],
  //                       rejected: rejectedList,
  //                       members: membersList,
  //                       isVideoCall: callData['isVideoCall']),
  //                 ),
  //               ),
  //             );
  //           });
  //         } else {
  //           // Accept call
  //           FirebaseFirestore.instance
  //               .collection('calls')
  //               .doc(callData['id'])
  //               .update({'accepted': true});

  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             // Navigate to CallPage using the global navigator key
  //             navigatorKey.currentState?.push(
  //               MaterialPageRoute(
  //                 builder: (context) => CallPage(
  //                   call: CallModel(
  //                       id: callData['id'],
  //                       caller: callData['caller'] ?? '',
  //                       callerName: callData['callerName'] ?? '',
  //                       called: callData['called'] ?? '',
  //                       channel: callData['channel'] ?? '',
  //                       active: true,
  //                       accepted: true,
  //                       rejected: false,
  //                       connected: false,
  //                       isVideoCall: callData['isVideoCall']),
  //                 ),
  //               ),
  //             );
  //           });
  //         }

  //         break;
  //       case Event.actionCallDecline:
  //         // Handle call decline
  //         if (callData['groupName'] != null) {
  //           // Reject call
  //           FirebaseFirestore.instance
  //               .collection('group_calls')
  //               .doc(callData['id'])
  //               .update({
  //             'rejected': FieldValue.arrayUnion(
  //                 [FirebaseAuth.instance.currentUser!.uid])
  //           });
  //         } else {
  //           // Reject call
  //           FirebaseFirestore.instance
  //               .collection('calls')
  //               .doc(callData['id'])
  //               .update({'rejected': true, 'active': false});
  //         }
  //         break;
  //       default:
  //         break;
  //     }
  //   });

  //   final params = CallKitParams(
  //     id: Uuid().v4(),
  //     nameCaller: callData['callerName'],
  //     appName: 'Unibond',
  //     avatar: callData['callerPic'] ?? '',
  //     handle: 'Incoming Call',
  //     type: 0,
  //     textAccept: 'Accept',
  //     textDecline: 'Decline',
  //     missedCallNotification: const NotificationParams(
  //       showNotification: false,
  //       isShowCallback: false,
  //       subtitle: 'Missed call',
  //       callbackText: 'Call back',
  //     ),
  //     extra: callData,
  //     android: const AndroidParams(
  //       isShowFullLockedScreen: false,
  //       isCustomNotification: true,
  //       isShowLogo: false,
  //       ringtonePath: 'system_ringtone_default',
  //       actionColor: '#4CAF50',
  //       textColor: '#ffffff',
  //     ),
  //   );

  //   await FlutterCallkitIncoming.showCallkitIncoming(params);
  // }

  Future<void> initPushNotification2(
      void Function(int newNotifId) setNewNotifId,
      void Function(Map<String, dynamic> newCallData) setNewCallData) async {
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      handleMessage(message, setNewNotifId, setNewCallData);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      handleMessage(message, setNewNotifId, setNewCallData);
    });
  }

  void initialize(void Function(int newNotifId) setNewNotifId,
      void Function(Map<String, dynamic> newCallData) setNewCallData) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && message.data['userId'] == currentUser.uid) {
        handleMessage(message, setNewNotifId, setNewCallData);
      }
    });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   User? currentUser = FirebaseAuth.instance.currentUser;

    //   if (currentUser != null && message.data['userId'] == currentUser.uid) {
    //     handleMessage(message);
    //   }
    // });
  }

  int generateUniqueNotificationId() {
    var uuid = Uuid();
    return uuid.v4().hashCode;
  }

  // void initiateFlutterCallKit(){

  //   FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
  //     switch (event?.event) {
  //       case Event.actionCallAccept:
  //         // Handle call accept
  //         // print(currentCall);

  //         if (callData['groupName'] != null) {
  //           //  Accept call
  //           FirebaseFirestore.instance
  //               .collection('group_calls')
  //               .doc(callData['id'])
  //               .update({
  //             'joined': FieldValue.arrayUnion(
  //                 [FirebaseAuth.instance.currentUser!.uid])
  //           });

  //           final joinedList = (callData['joined'] as List<dynamic>)
  //               .map((e) => e.toString())
  //               .toList();
  //           final rejectedList = (callData['rejected'] as List<dynamic>)
  //               .map((e) => e.toString())
  //               .toList();
  //           final membersList = (callData['members'] as List<dynamic>)
  //               .map((e) => e.toString())
  //               .toList();
  //           print('joined: $joinedList');
  //           print('rejected: $rejectedList');
  //           print('members: $membersList');

  //           // Navigate to CallPage using the global navigator key
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             navigatorKey.currentState?.push(
  //               MaterialPageRoute(
  //                 builder: (context) => GroupCallPage(
  //                   chatDocId: callData['chatDocId'],
  //                   userUid: FirebaseAuth.instance.currentUser!.uid,
  //                   call: GroupCallModel(
  //                       id: callData['id'],
  //                       caller: callData['caller'],
  //                       callerName: callData['callerName'],
  //                       channel: callData['channel'],
  //                       active: true,
  //                       groupName: callData['groupName'],
  //                       joined: [
  //                         FirebaseAuth.instance.currentUser!.uid,
  //                         ...joinedList
  //                       ],
  //                       rejected: rejectedList,
  //                       members: membersList,
  //                       isVideoCall: callData['isVideoCall']),
  //                 ),
  //               ),
  //             );
  //           });
  //         } else {
  //           // Accept call
  //           FirebaseFirestore.instance
  //               .collection('calls')
  //               .doc(callData['id'])
  //               .update({'accepted': true});

  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             // Navigate to CallPage using the global navigator key
  //             navigatorKey.currentState?.push(
  //               MaterialPageRoute(
  //                 builder: (context) => CallPage(
  //                   call: CallModel(
  //                       id: callData['id'],
  //                       caller: callData['caller'] ?? '',
  //                       callerName: callData['callerName'] ?? '',
  //                       called: callData['called'] ?? '',
  //                       channel: callData['channel'] ?? '',
  //                       active: true,
  //                       accepted: true,
  //                       rejected: false,
  //                       connected: false,
  //                       isVideoCall: callData['isVideoCall']),
  //                 ),
  //               ),
  //             );
  //           });
  //         }

  //         break;
  //       case Event.actionCallDecline:
  //         // Handle call decline
  //         if (callData['groupName'] != null) {
  //           // Reject call
  //           FirebaseFirestore.instance
  //               .collection('group_calls')
  //               .doc(callData['id'])
  //               .update({
  //             'rejected': FieldValue.arrayUnion(
  //                 [FirebaseAuth.instance.currentUser!.uid])
  //           });
  //         } else {
  //           // Reject call
  //           FirebaseFirestore.instance
  //               .collection('calls')
  //               .doc(callData['id'])
  //               .update({'rejected': true, 'active': false});
  //         }
  //         break;
  //       default:
  //         break;
  //     }
  //   });

  // }
}
