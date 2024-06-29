import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/EventsData.dart';
import 'package:unibond/pages/Events/EventDetails.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/pages/Messages/GroupConversation.dart';
import 'package:unibond/pages/Messages/ProfileView.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/NotificationModel.dart';

class NotifcationCard extends StatefulWidget {
  final String? chatDocId;
  final bool isMessage;
  final bool isFriendRequest;
  final bool isFriendAccept;
  final bool isGroup;
  final bool isEvent;
  final IndivEvents? eventData;
  final String? fromUid;
  final String fromName;
  final Timestamp dateTime;
  final bool isRead;
  final String docId;
  final String notifMsg;
  final String? img;
  final Map<String, dynamic>? groupData;

  const NotifcationCard(
      {super.key,
      this.chatDocId,
      this.fromUid,
      required this.fromName,
      required this.dateTime,
      required this.isRead,
      required this.docId,
      required this.isMessage,
      required this.isGroup,
      required this.isEvent,
      this.eventData,
      required this.isFriendRequest,
      required this.isFriendAccept,
      required this.notifMsg,
      this.img,
      this.groupData});

  @override
  State<NotifcationCard> createState() => _NotifcationCardState();
}

class _NotifcationCardState extends State<NotifcationCard> {
  late bool notifRead;

  @override
  void initState() {
    super.initState();
    setState(() {
      notifRead = widget.isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: notifRead ? Colors.transparent : Colors.blue[100],
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Provider.of<NotificationModel>(context, listen: false)
                      .updateReadStatus(widget.docId)
                      .then((_) {
                    setState(() {
                      notifRead = true;
                    });
                  });

                  print('event: ${widget.isEvent}');
                  print('group: ${widget.isGroup}');
                  print('message: ${widget.isMessage}');
                  print('fried request: ${widget.isFriendRequest}');
                  print('accepted: ${widget.isFriendAccept}');

                  if (widget.isEvent == true &&
                      widget.isGroup == false &&
                      widget.isMessage == false &&
                      widget.isFriendRequest == false &&
                      widget.isFriendAccept == false) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            EventDetails(eventData: widget.eventData!),
                      ),
                    );
                  } else if (widget.isEvent == false &&
                      widget.isGroup == true &&
                      widget.isMessage == false &&
                      widget.isFriendRequest == false &&
                      widget.isFriendAccept == false) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            GroupConversation(groupData: widget.groupData!),
                      ),
                    );
                  } else if (widget.isEvent == false &&
                      widget.isGroup == false &&
                      widget.isMessage == true &&
                      widget.isFriendRequest == false &&
                      widget.isFriendAccept == false) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => Conversation(
                            friendName: widget.fromName,
                            friendUid: widget.fromUid!),
                      ),
                    );
                  } else if (widget.isEvent == false &&
                      widget.isGroup == false &&
                      widget.isMessage == false &&
                      widget.isFriendRequest == true &&
                      widget.isFriendAccept == false) {
                    Provider.of<NotificationModel>(context, listen: false)
                        .fetchUserData(widget.fromUid!)
                        .then((userData) {
                      Provider.of<FriendsModel>(context, listen: false)
                          .viewProfile(userData);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ProfileView()));
                    });
                  } else {
                    Provider.of<NotificationModel>(context, listen: false)
                        .fetchUserData(widget.fromUid!)
                        .then((userData) {
                      Provider.of<FriendsModel>(context, listen: false)
                          .viewProfile(userData);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ProfileView()));
                    });
                  }
                },
                child: Row(
                  children: [
                    // Image/Icon
                    widget.img != null && (widget.img as String).isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(widget.img!),
                            maxRadius: 30,
                          )
                        : const CircleAvatar(
                            backgroundImage: AssetImage(
                                'lib/assets/default_profile_pic.png'),
                            maxRadius: 30,
                          ),
                    const SizedBox(
                      width: 10,
                    ),

                    // Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SHOP NAME
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.fromName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .black, // Add color to match theme
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${widget.notifMsg}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors
                                        .black, // Add color to match theme
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // messaged you
                          // Text(
                          //   notifMsg,
                          //   style: Theme.of(context)
                          //       .textTheme
                          //       .bodyLarge!
                          //       .copyWith(color: Colors.black),
                          // ),

                          const SizedBox(
                            height: 5,
                          ),

                          // timestamp
                          Text(
                            Provider.of<NotificationModel>(context,
                                    listen: false)
                                .formatDateTime(widget.dateTime),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
