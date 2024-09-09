import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/EventsData.dart';
import 'package:unibond/pages/Events/EventDetails.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/pages/Messages/GroupConversation.dart';
import 'package:unibond/pages/Messages/ProfileView.dart';
import 'package:unibond/provider/ChatsModel.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/NotificationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

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
  final String? groupDocId;

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
      this.groupData,
      this.groupDocId});

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
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, currentUserSnapshot) {
          if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (currentUserSnapshot.hasError) {
            return Center(child: Text('Error: ${currentUserSnapshot.error}'));
          }

          if (!currentUserSnapshot.hasData &&
              currentUserSnapshot.data != null) {
            return const Center(child: Text('No user data'));
          }

          final currentUserData =
              currentUserSnapshot.data!.data() as Map<String, dynamic>;
          final currentUserUid = currentUserData['uid'];
          final currentUserFullName = currentUserData['full_name'];
          final currentUserRequestList =
              (currentUserData['requests'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
          final currentUserFriendList =
              (currentUserData['friends'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: notifRead ? Colors.transparent : Colors.blue[100],
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Provider.of<NotificationModel>(context, listen: false)
                            .updateReadStatus(widget.docId)
                            .then((_) async {
                          setState(() {
                            notifRead = true;
                          });
                        });

                        if (widget.isEvent == true &&
                            widget.isGroup == false &&
                            widget.isMessage == false &&
                            widget.isFriendRequest == false &&
                            widget.isFriendAccept == false) {
                          final profileModel =
                              Provider.of<ProfileModel>(context, listen: false);
                          try {
                            final result = await FirebaseFirestore.instance
                                .collection('groups')
                                .where('group_name',
                                    isEqualTo: widget.eventData!.groupName)
                                .get();

                            if (result.docs.isNotEmpty) {
                              final data = result.docs.first.data();

                              print('this executed');

                              if ((data['admin'] as List<dynamic>).contains(
                                      profileModel.userDetails['uid']) ||
                                  profileModel.userDetails['role'] == 'admin') {
                                print('admin');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EventDetails(
                                      eventData: widget.eventData!,
                                      isAdmin: true,
                                    ),
                                  ),
                                );
                              } else {
                                print('not admin');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EventDetails(
                                      eventData: widget.eventData!,
                                      isAdmin: false,
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            print(e);
                          }
                        } else if (widget.isEvent == false &&
                            widget.isGroup == true &&
                            widget.isMessage == false &&
                            widget.isFriendRequest == false &&
                            widget.isFriendAccept == false) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  GroupConversation(
                                      groupDocId: widget.groupDocId!),
                            ),
                          );
                        } else if (widget.isEvent == false &&
                            widget.isGroup == false &&
                            widget.isMessage == true &&
                            widget.isFriendRequest == false &&
                            widget.isFriendAccept == false) {
                          Provider.of<ConversationModel>(context, listen: false)
                              .setChatDocId(widget.chatDocId);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => Conversation(
                                friendName: widget.fromName,
                                friendUid: widget.fromUid!,
                                friendProfilePic: widget.img,
                              ),
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
                                builder: (BuildContext context) => ProfileView(
                                      currentUserFriendsList:
                                          currentUserFriendList,
                                      currentUserFullName: currentUserFullName,
                                      currentUserRequestsList:
                                          currentUserRequestList,
                                      currentUserUid: currentUserUid,
                                      uid: widget.fromUid!,
                                    )));
                          });
                        } else {
                          Provider.of<NotificationModel>(context, listen: false)
                              .fetchUserData(widget.fromUid!)
                              .then((userData) {
                            Provider.of<FriendsModel>(context, listen: false)
                                .viewProfile(userData);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => ProfileView(
                                      currentUserFriendsList:
                                          currentUserFriendList,
                                      currentUserFullName: currentUserFullName,
                                      currentUserRequestsList:
                                          currentUserRequestList,
                                      currentUserUid: currentUserUid,
                                      uid: widget.fromUid!,
                                    )));
                          });
                        }
                      },
                      child: Row(
                        children: [
                          // Image/Icon
                          widget.img != null &&
                                  (widget.img as String).isNotEmpty
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
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors
                                              .black, // Add color to match theme
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ${widget.notifMsg}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors
                                              .black, // Add color to match theme
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

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
        });
  }
}
