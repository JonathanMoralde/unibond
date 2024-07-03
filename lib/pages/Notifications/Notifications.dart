import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/EventsData.dart';
import 'package:unibond/provider/NotificationModel.dart';
import 'package:unibond/widgets/Notification/NotificationCard.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final notificationModel =
        Provider.of<NotificationModel>(context, listen: false);

    notificationModel.fetchNotif();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (notificationModel.hasMore) {
          notificationModel.fetchNotif(loadMore: true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NotificationModel>(
        builder: (context, notificationModel, child) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: notificationModel.notifications.length +
                (notificationModel.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < notificationModel.notifications.length) {
                var notification = notificationModel.notifications[index];
                return NotifcationCard(
                  chatDocId: notification['chat_doc_id'],
                  fromUid: notification['from_uid'],
                  fromName:
                      notification['from_name'] ?? notification['group_name'],
                  dateTime: notification['dateTime'],
                  isRead: notification['is_read'],
                  docId: notification['docId'],
                  isMessage: notification['is_message'],
                  isGroup: notification['is_group'],
                  isEvent: notification['is_event'],
                  isFriendRequest: notification['is_friend_request'],
                  isFriendAccept: notification['is_friend_accept'],
                  eventData: notification['event_description'] != null &&
                          notification['event_date'] != null &&
                          notification['event_doc_id'] != null &&
                          notification['event_name'] != null &&
                          notification['event_time'] != null &&
                          notification['group_name'] != null &&
                          notification['event_location'] != null &&
                          notification['event_color'] != null
                      ? IndivEvents(
                          description: notification['event_description'],
                          eventDate: (notification['event_date'] as Timestamp)
                              .toDate(),
                          eventDocId: notification['event_doc_id'],
                          eventName: notification['event_name'],
                          eventTime: notification['event_time'],
                          groupName: notification['group_name'],
                          location: notification['event_location'],
                          color: notification['event_color'])
                      : null,
                  notifMsg: notification['notif_msg'],
                  img: notification['pic'],
                  groupData: notification['group_data'],
                  groupDocId: notification['group_doc_id'],
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
