import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unibond/model/GroupCallModel.dart';
import 'package:unibond/pages/Messages/CallPage.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/pages/Messages/GroupCallPage.dart';
import 'package:unibond/provider/ConversationModel.dart';

import '../main.dart'; // Import the file where the GlobalKey is defined

class NotificationService {
  static bool isNotifActive = false;

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      'resource://mipmap/launcher_icon',
      [
        NotificationChannel(
          channelGroupKey: 'sound_channel',
          channelKey: 'sound_channel',
          channelName: 'Call notifications',
          channelDescription: 'Notification channel for incoming call',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          // onlyAlertOnce: true,
          vibrationPattern: Int64List.fromList(
            [0, 500, 200, 500, 200, 500, 200, 500],
          ),
          playSound: true,
          criticalAlerts: true,
          defaultRingtoneType: DefaultRingtoneType.Ringtone,
          defaultPrivacy: NotificationPrivacy.Public,

          locked: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelGroupKey: 'basic_channel',
          channelKey: 'basic_channel',
          channelName: 'Message notifications',
          channelDescription: 'Notification channel for incoming messages',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
          // onlyAlertOnce: true,
          vibrationPattern: Int64List.fromList(
            [0, 500, 200, 500, 200, 500, 200, 500],
          ),
          playSound: true,
          enableVibration: true,
        ),
      ],
      // channelGroups: [
      //   NotificationChannelGroup(
      //     channelGroupKey: 'sound_channel_group',
      //     channelGroupName: 'Group 1',
      //   )
      // ],
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
        isNotifActive = false;
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
                fcmTokens: [],
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

          final joinedList = payload['joined']?.split(',') ?? [];
          final rejectedList = payload['rejected']?.split(',') ?? [];
          final membersList = payload['members']?.split(',') ?? [];

          // Navigate to CallPage using the global navigator key
          WidgetsBinding.instance.addPostFrameCallback((_) {
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
          });
        }
      } else if (receivedAction.buttonKeyPressed == 'REJECT') {
        isNotifActive = false;
        if (payload['groupName'] == null) {
          // Reject call
          FirebaseFirestore.instance
              .collection('calls')
              .doc(payload['callId'])
              .update({'rejected': true, 'active': false});
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

    // handle message notification
    if (payload['chatDocId'] != null) {
      print("profilePic: ${payload['senderPic']}");
      // Navigate to CallPage using the global navigator key
      Provider.of<ConversationModel>(navigatorKey.currentContext!,
              listen: false)
          .setChatDocId(payload['chatDocId']);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => Conversation(
            friendName: payload['senderName'] ?? '',
            friendUid: payload['senderId'] ?? '',
            friendProfilePic: payload['senderPic'] ?? null,
          ),
        ),
      );
    }
  }

  static Future<void> showNotification({
    required final int id,
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
        id: id,
        channelKey: 'sound_channel',
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
        locked: true,
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

  static Future<void> showMessageNotification({
    required final int id,
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
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
        wakeUpScreen: true,
        autoDismissible: true,
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
