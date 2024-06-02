import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/IndividualMessage.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Conversation extends StatefulWidget {
  final String friendName;
  final String? friendProfilePic;
  final String friendUid;
  const Conversation(
      {super.key,
      required this.friendName,
      this.friendProfilePic,
      required this.friendUid});

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final chatController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            widget.friendProfilePic != null &&
                    (widget.friendProfilePic as String).isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.friendProfilePic!),
                    maxRadius: 15,
                  )
                : const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 15,
                  ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                widget.friendName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.video_call,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.call,
              color: Colors.black,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
      body: Consumer2<ConversationModel, ProfileModel>(
          builder: (context, conversationModel, profileModel, child) {
        return SafeArea(
            child: StreamBuilder<QuerySnapshot>(
                stream: conversationModel.fetchMessages(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<IndividualMessage> msg = [];

                  if (snapshot.data != null) {
                    msg = snapshot.data!.docs.map((messageDoc) {
                      return IndividualMessage(
                        msgDocId: messageDoc.id,
                        messageText: messageDoc['message_text'],
                        receiverId: messageDoc['receiver_id'],
                        senderId: messageDoc['sender_id'],
                        timestamp: messageDoc['timestamp'],
                      );
                    }).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // CHAT DISPLAY
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: msg.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isCurrentUser = msg[index].senderId ==
                                profileModel.userDetails['uid'];

                            // ===================== Time Display =====================
                            DateTime timeReceived =
                                msg[index].timestamp.toDate();
                            // DateTime now = DateTime.now();

                            // DateTime dateToday =
                            //     DateTime(now.year, now.month, now.day);
                            // DateTime dateReceived = DateTime(timeReceived.year,
                            //     timeReceived.month, timeReceived.day);

                            // bool isSameDate =
                            //     dateToday.isAtSameMomentAs(dateReceived);

                            // String formattedDateTime = (isSameDate)
                            //     ? DateFormat('hh:mm a').format(timeReceived)
                            //     : (timeReceived.isAfter(
                            //         now.subtract(const Duration(days: 6)),
                            //       ))
                            //         ? DateFormat('EEE \'at\' hh:mm a')
                            //             .format(timeReceived)
                            //         : (timeReceived.isAfter(
                            //             DateTime(
                            //                 now.year - 1, now.month, now.day),
                            //           ))
                            //             ? DateFormat('MMM d \'at\' hh:mm a')
                            //                 .format(timeReceived)
                            //             : DateFormat('MM/dd/yy \'at\' hh:mm a')
                            //                 .format(timeReceived);
                            String formattedDateTime =
                                conversationModel.formatDateTime(timeReceived);
                            // ========================================================

                            final List<Widget> listTileContent = [
                              isCurrentUser
                                  ? (profileModel.userDetails['profile_pic'] !=
                                              null &&
                                          (profileModel.userDetails[
                                                  'profile_pic'] as String)
                                              .isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              profileModel
                                                  .userDetails['profile_pic']),
                                          maxRadius: 20,
                                        )
                                      : const CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'lib/assets/default_profile_pic.png'),
                                          maxRadius: 20,
                                        ))
                                  : widget.friendProfilePic != null &&
                                          (widget.friendProfilePic as String)
                                              .isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              widget.friendProfilePic!),
                                          maxRadius: 20,
                                        )
                                      : const CircleAvatar(
                                          backgroundImage: AssetImage(
                                              'lib/assets/default_profile_pic.png'),
                                          maxRadius: 20,
                                        ),
                              const SizedBox(
                                width: 5,
                              ),
                              Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                              0.80,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? const Color(0xffFF8C36)
                                            : const Color(0xff6ECDF7),
                                        borderRadius: BorderRadius.only(
                                            topLeft: !isCurrentUser
                                                ? const Radius.circular(0)
                                                : const Radius.circular(32),
                                            topRight: isCurrentUser
                                                ? const Radius.circular(0)
                                                : const Radius.circular(32),
                                            bottomLeft:
                                                const Radius.circular(32),
                                            bottomRight:
                                                const Radius.circular(32)),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Text(
                                        msg[index].messageText,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4.0,
                                  ),
                                  Text(formattedDateTime,
                                      style: GoogleFonts.dmSans(fontSize: 11))
                                ],
                              ),
                            ];

                            return ListTile(
                              title: Row(
                                  mainAxisAlignment: isCurrentUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: isCurrentUser
                                      ? listTileContent.reversed.toList()
                                      : listTileContent),
                            );
                          },
                        ),
                      ),

                      // INPUTS
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Expanded(
                              child: StyledTextFormField(
                                controller: chatController,
                                hintText: 'Type something',
                                obscureText: false,
                                maxLines: 6,
                                paddingLeft: 16,
                                paddingRight: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                conversationModel.sendMessage(
                                    chatController.text, widget.friendUid);
                                chatController.clear();
                              },
                              icon: const Icon(Icons.send),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                }));
      }),
    );
  }
}
