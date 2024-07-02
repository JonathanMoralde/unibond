import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unibond/model/GroupCallModel.dart';
import 'package:unibond/pages/Messages/CallPage.dart';
import 'package:unibond/pages/Messages/GroupCallPage.dart';

import '../main.dart'; // Import the file where the GlobalKey is defined

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
            channelGroupKey: 'high_importance_channel',
            channelKey: 'high_importance_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            // onlyAlertOnce: true,
            // playSound: true,
            // criticalAlerts: true,
            defaultRingtoneType: DefaultRingtoneType.Ringtone,
            enableVibration: true)
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      // onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  // static Future<void> onDismissActionReceivedMethod(
  //     ReceivedAction receivedAction) async {
  //   debugPrint('onDismissActionReceivedMethod');
  // }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};

    if (payload["navigate"] == "true") {
      if (receivedAction.buttonKeyPressed == 'ACCEPT') {
        if (payload['groupName'] == null) {
          // Accept call
          FirebaseFirestore.instance
              .collection('calls')
              .doc(payload['callId'])
              .update({'accepted': true});

          // Navigate to CallPage using the global navigator key
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => CallPage(
                call: CallModel(
                    id: payload['callId'],
                    caller: payload['caller'] ?? '',
                    callerName: payload['callerName'] ?? '',
                    called: payload['called'] ?? '',
                    channel: payload['channelName'] ?? '',
                    active: true,
                    accepted: true,
                    rejected: false,
                    connected: false,
                    isVideoCall:
                        payload['isVideoCall']?.toLowerCase() == 'true'),
              ),
            ),
          );
        } else {
          // / Accept call
          FirebaseFirestore.instance
              .collection('group_calls')
              .doc(payload['callId'])
              .update({
            'joined':
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
          });

          final joinedList = payload['joined']!.split(',');
          final rejectedList = payload['rejected']!.split(',');
          final membersList = payload['members']!.split(',');

          // Navigate to CallPage using the global navigator key
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => GroupCallPage(
                chatDocId: payload['chatDocId'] ?? '',
                userUid: FirebaseAuth.instance.currentUser!.uid,
                call: GroupCallModel(
                    id: payload['callId'],
                    caller: payload['caller'] ?? '',
                    callerName: payload['callerName'] ?? '',
                    channel: payload['channelName'] ?? '',
                    active: true,
                    groupName: payload['groupName'] ?? '',
                    joined: joinedList,
                    rejected: rejectedList,
                    members: membersList,
                    isVideoCall:
                        payload['isVideoCall']?.toLowerCase() == 'true'),
              ),
            ),
          );
        }
      } else if (receivedAction.buttonKeyPressed == 'REJECT') {
        if (payload['groupName'] == null) {
          // Reject call
          FirebaseFirestore.instance
              .collection('calls')
              .doc(payload['callId'])
              .update({'rejected': true});
        } else {
          // Reject call
          FirebaseFirestore.instance
              .collection('group_calls')
              .doc(payload['callId'])
              .update({
            'rejected':
                FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
          });
        }
      }
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: -1,
        channelKey: 'high_importance_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
        wakeUpScreen: true,
        autoDismissible: false,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
              interval: interval,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }
}
