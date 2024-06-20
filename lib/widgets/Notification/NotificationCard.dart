import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/NotificationModel.dart';

class NotifcationCard extends StatelessWidget {
  final String? chatDocId;
  final bool isMessage;
  final bool isFriendRequest;
  final bool isGroup;
  final String? fromUid;
  final String fromName;
  final Timestamp dateTime;
  final bool isRead;
  final String docId;
  final String notifMsg;

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
      required this.isFriendRequest,
      required this.notifMsg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Divider(
            height: 1,
          ),
        ),
        Container(
          color: isRead ? Colors.transparent : Colors.blue[100],
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.78,
                  child: GestureDetector(
                    onTap: () {
                      // updateReadStatus();

                      // if (isMessage == true &&
                      //     isRate == false &&
                      //     isAgreement == false) {
                      //   // Navigator.of(context).push(
                      //   //   MaterialPageRoute(
                      //   //     builder: (BuildContext context) => Conversation(
                      //   //       docId: chatDocId,
                      //   //       shopId: fromUid,
                      //   //       shopName: shopName,
                      //   //     ),
                      //   //   ),
                      //   // );
                      // } else if (isRate == true &&
                      //     isMessage == false &&
                      //     isAgreement == false) {
                      //   print("rate");
                      //   // TODO NAVIGATE TO VIEW SHOP'S RATING & REVIEW
                      // } else {
                      //   print('agreement');
                      //   // TODO NAVIGATE TO CONVERSATION PAGE
                      // }
                    },
                    child: Row(
                      children: [
                        // Image/Icon
                        const CircleAvatar(
                          backgroundImage:
                              AssetImage('images/default_profile_pic.png'),
                          maxRadius: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),

                        // Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SHOP NAME
                            Text(
                              fromName ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Colors.black),
                            ),

                            // messaged you
                            Text(
                              notifMsg,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Colors.black),
                            ),

                            // timestamp
                            Text(
                              Provider.of<NotificationModel>(context,
                                      listen: false)
                                  .formatDateTime(dateTime),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.grey[700]),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
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
