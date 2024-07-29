import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:unibond/main.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:unibond/pages/Messages/CallPage.dart';
import 'package:uuid/uuid.dart';

class FirebaseMessagingApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initPushNotification() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('fcm_tokens')
        .doc(fCMToken)
        .set({'fcm_token': fCMToken});

    initPushNotification2();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && message.data['userId'] == currentUser.uid) {
      Map<String, dynamic> callData = jsonDecode(message.data['callData']);
      showIncomingCall(callData);
    }
  }

  Future<void> showIncomingCall(Map<String, dynamic> callData) async {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event?.event) {
        case Event.actionCallAccept:
          // Handle call accept
          // print(currentCall);

          // Accept call
          FirebaseFirestore.instance
              .collection('calls')
              .doc(callData['id'])
              .update({'accepted': true});

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Navigate to CallPage using the global navigator key
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => CallPage(
                  call: CallModel(
                      id: callData['id'],
                      caller: callData['caller'] ?? '',
                      callerName: callData['callerName'] ?? '',
                      called: callData['called'] ?? '',
                      channel: callData['channel'] ?? '',
                      active: true,
                      accepted: true,
                      rejected: false,
                      connected: false,
                      isVideoCall: callData['isVideoCall']),
                ),
              ),
            );
          });

          break;
        case Event.actionCallDecline:
          // Handle call decline
          // Reject call
          FirebaseFirestore.instance
              .collection('calls')
              .doc(callData['id'])
              .update({'rejected': true, 'active': false});
          break;
        default:
          break;
      }
    });

    final params = CallKitParams(
      id: Uuid().v4(),
      nameCaller: callData['callerName'],
      appName: 'Unibond',
      avatar: callData['callerPic'] ?? '',
      handle: 'Incoming Call',
      type: 0,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: false,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      extra: callData,
      android: const AndroidParams(
        isShowFullLockedScreen: false,
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> initPushNotification2() async {
    _firebaseMessaging.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void initialize(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && message.data['userId'] == currentUser.uid) {
        handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && message.data['userId'] == currentUser.uid) {
        handleMessage(message);
      }
    });
  }
}
