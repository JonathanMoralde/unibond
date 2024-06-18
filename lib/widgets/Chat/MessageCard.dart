import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Messages/Conversation.dart';
import 'package:unibond/provider/ProfileModel.dart';

class MessageCard extends StatelessWidget {
  final bool isRead;
  final Function()? onTap;
  final String? profilePic;
  final String userName;
  final String latestMessage;
  final String latestUser;
  final Timestamp latestTimestamp;
  final String friendId;
  const MessageCard(
      {super.key,
      required this.isRead,
      required this.onTap,
      this.profilePic,
      required this.userName,
      required this.latestMessage,
      required this.latestUser,
      required this.latestTimestamp,
      required this.friendId});

  @override
  Widget build(BuildContext context) {
    String formatDateTime(Timestamp latestTimestamp) {
      DateTime lastChatDateTime = latestTimestamp.toDate();
      DateTime now = DateTime.now();

      Duration difference = now.difference(lastChatDateTime);

      if (difference.inSeconds < 60) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}hr ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays <= 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('d MMM').format(lastChatDateTime);
      }
    }

    return Consumer<ProfileModel>(builder: (context, value, child) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: isRead ? Colors.white : const Color(0xffCAE5F1)),
          child: Row(
            children: [
              // Profile pic
              // const CircleAvatar(
              //   backgroundImage: AssetImage('lib/assets/default_profile_pic.png'),
              //   maxRadius: 30,
              // ),
              profilePic != null && (profilePic as String).isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(profilePic!),
                      maxRadius: 30,
                    )
                  : const CircleAvatar(
                      backgroundImage:
                          AssetImage('lib/assets/default_profile_pic.png'),
                      maxRadius: 30,
                    ),
              const SizedBox(
                width: 10,
              ),

              // Name & Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      latestUser == value.userDetails['uid']
                          ? 'You: $latestMessage'
                          : latestMessage,
                      style: TextStyle(
                          fontWeight:
                              !isRead ? FontWeight.bold : FontWeight.normal),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),

              // Time ago
              Text(formatDateTime(latestTimestamp))
            ],
          ),
        ),
      );
    });
  }
}
