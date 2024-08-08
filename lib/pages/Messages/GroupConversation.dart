import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/GroupCallModel.dart';
import 'package:unibond/model/GroupIndivMessage.dart';
import 'package:unibond/pages/Messages/GroupCallPage.dart';
import 'package:unibond/pages/Messages/GroupChatDetails.dart';
import 'package:unibond/provider/GroupConversationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class GroupConversation extends StatefulWidget {
  final String groupDocId;
  const GroupConversation({super.key, required this.groupDocId});

  @override
  State<GroupConversation> createState() => _GroupConversationState();
}

class _GroupConversationState extends State<GroupConversation> {
  final chatController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<GroupConversationModel>(context, listen: false)
        .setChatDocId(widget.groupDocId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .doc(widget.groupDocId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text('Group data not found');
              }

              final groupData = snapshot.data!.data() as Map<String, dynamic>;

              return Row(
                children: [
                  groupData['group_pic'] != null &&
                          (groupData['group_pic'] as String).isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(groupData['group_pic']!),
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
                      groupData['group_name'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              );
            }),
        actions: [
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupDocId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return SizedBox.shrink();
                }

                final groupData = snapshot.data!.data() as Map<String, dynamic>;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('group_calls')
                        .where('group_name', isEqualTo: groupData['group_name'])
                        .where('active', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final data = snapshot.data!.docs.first.data();

                        return IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.videocam,
                              color: Colors.grey,
                            ));
                      }
                      return IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => GroupCallPage(
                                chatDocId: Provider.of<GroupConversationModel>(
                                        context,
                                        listen: false)
                                    .chatDocId!,
                                userUid: Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['uid'],
                                call: GroupCallModel(
                                    id: null,
                                    groupPic: groupData['group_pic'],
                                    channel: groupData['group_name'],
                                    caller: Provider.of<ProfileModel>(context,
                                            listen: false)
                                        .userDetails['uid'],
                                    callerName: Provider.of<ProfileModel>(
                                            context,
                                            listen: false)
                                        .userDetails['full_name'],
                                    groupName: groupData['group_name'],
                                    active: true,
                                    members:
                                        (groupData['members'] as List<dynamic>)
                                            .map((e) => e.toString())
                                            .toList(),
                                    joined: [
                                      Provider.of<ProfileModel>(context,
                                              listen: false)
                                          .userDetails['uid']
                                    ],
                                    rejected: [],
                                    isVideoCall: true),
                              ),
                            ),
                          );

                          final groupConversationModel =
                              Provider.of<GroupConversationModel>(context,
                                  listen: false);

                          Future.delayed(Duration(seconds: 3), () {
                            groupConversationModel.sendMessage(
                                '${Provider.of<ProfileModel>(context, listen: false).userDetails['full_name']} started a video call',
                                Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['full_name'],
                                Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['profile_pic'],
                                'notify');
                          });
                        },
                        icon: const Icon(Icons.videocam, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    });
              }),
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupDocId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return SizedBox.shrink();
                }

                final groupData = snapshot.data!.data() as Map<String, dynamic>;

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('group_calls')
                        .where('group_name', isEqualTo: groupData['group_name'])
                        .where('active', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        final data = snapshot.data!.docs.first.data();

                        return IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.call,
                              color: Colors.grey,
                            ));
                      }
                      return IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => GroupCallPage(
                                chatDocId: Provider.of<GroupConversationModel>(
                                        context,
                                        listen: false)
                                    .chatDocId!,
                                userUid: Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['uid'],
                                call: GroupCallModel(
                                    id: null,
                                    channel: groupData['group_name'],
                                    caller: Provider.of<ProfileModel>(context,
                                            listen: false)
                                        .userDetails['uid'],
                                    callerName: Provider.of<ProfileModel>(
                                            context,
                                            listen: false)
                                        .userDetails['full_name'],
                                    groupName: groupData['group_name'],
                                    active: true,
                                    members:
                                        (groupData['members'] as List<dynamic>)
                                            .map((e) => e.toString())
                                            .toList(),
                                    joined: [
                                      Provider.of<ProfileModel>(context,
                                              listen: false)
                                          .userDetails['uid']
                                    ],
                                    rejected: [],
                                    isVideoCall: false),
                              ),
                            ),
                          );

                          final groupConversationModel =
                              Provider.of<GroupConversationModel>(context,
                                  listen: false);

                          Future.delayed(Duration(seconds: 3), () {
                            groupConversationModel.sendMessage(
                                '${Provider.of<ProfileModel>(context, listen: false).userDetails['full_name']} started a call',
                                Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['full_name'],
                                Provider.of<ProfileModel>(context,
                                        listen: false)
                                    .userDetails['profile_pic'],
                                'notify');
                          });
                        },
                        icon: const Icon(Icons.call, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    });
              }),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => GroupChatDetails(
                    groupDocId: widget.groupDocId,
                    isMember: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info, color: Colors.black),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: Consumer2<GroupConversationModel, ProfileModel>(
          builder: (context, groupConversationModel, profileModel, child) {
        return SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: groupConversationModel.fetchMessages(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<GroupIndivMessage> msg = [];

                  if (snapshot.data != null) {
                    msg = snapshot.data!.docs.map((messageDoc) {
                      return GroupIndivMessage(
                        msgDocId: messageDoc.id,
                        content: messageDoc['content'],
                        type: messageDoc['type'],
                        senderId: messageDoc['sender_id'],
                        timestamp: messageDoc['timestamp'],
                        isRead: messageDoc['is_read'],
                        senderName: messageDoc['sender_name'],
                        senderProfilePic: messageDoc['sender_profile_pic'],
                      );
                    }).toList();
                  }

                  return Expanded(
                    child: ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: msg.length,
                        itemBuilder: (BuildContext context, int index) {
                          bool isCurrentUser = msg[index].senderId ==
                              profileModel.userDetails['uid'];

                          // ===================== Time Display =====================
                          DateTime timeReceived = msg[index].timestamp.toDate();
                          String formattedDateTime = groupConversationModel
                              .formatDateTime(timeReceived);
                          // ========================================================

                          final List<Widget> listTileContent = [
                            msg[index].type == 'notify'
                                ? Expanded(
                                    child: Text(
                                    msg[index].content,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600),
                                  ))
                                : isCurrentUser
                                    ? (profileModel.userDetails[
                                                    'profile_pic'] !=
                                                null &&
                                            (profileModel.userDetails[
                                                    'profile_pic'] as String)
                                                .isNotEmpty
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                profileModel.userDetails[
                                                    'profile_pic']),
                                            maxRadius: 20,
                                          )
                                        : const CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'lib/assets/default_profile_pic.png'),
                                            maxRadius: 20,
                                          ))
                                    : msg[index].senderProfilePic != null &&
                                            (msg[index].senderProfilePic
                                                    as String)
                                                .isNotEmpty
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                msg[index].senderProfilePic!),
                                            maxRadius: 20,
                                          )
                                        : const CircleAvatar(
                                            backgroundImage: AssetImage(
                                                'lib/assets/default_profile_pic.png'),
                                            maxRadius: 20,
                                          ),
                            if (msg[index].type != 'notify')
                              const SizedBox(
                                width: 5,
                              ),
                            if (msg[index].type != 'notify')
                              Column(
                                crossAxisAlignment: isCurrentUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.sizeOf(context).width *
                                              0.60,
                                      // 0.80,
                                    ),
                                    child: msg[index].type == 'text'
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: isCurrentUser
                                                  ? const Color(0xffFF8C36)
                                                  : const Color(0xff6ECDF7),
                                              borderRadius: BorderRadius.only(
                                                  topLeft: !isCurrentUser
                                                      ? const Radius.circular(0)
                                                      : const Radius.circular(
                                                          32),
                                                  topRight: isCurrentUser
                                                      ? const Radius.circular(0)
                                                      : const Radius.circular(
                                                          32),
                                                  bottomLeft:
                                                      const Radius.circular(32),
                                                  bottomRight:
                                                      const Radius.circular(
                                                          32)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 16),
                                            child: Text(
                                              msg[index].content,
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Scaffold(
                                                    appBar: AppBar(
                                                      leading: GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Icon(
                                                              Icons.close)),
                                                      actions: [
                                                        IconButton(
                                                            icon: const Icon(
                                                                Icons.save_alt),
                                                            onPressed: () {
                                                              groupConversationModel
                                                                  .saveImage(msg[
                                                                          index]
                                                                      .content);
                                                            }),
                                                      ],
                                                    ),
                                                    body: PhotoView(
                                                      imageProvider:
                                                          NetworkImage(
                                                              msg[index]
                                                                  .content),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xff00B0FF))),
                                              child: CachedNetworkImage(
                                                  imageUrl: msg[index].content),
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
                                mainAxisAlignment: msg[index].type == 'notify'
                                    ? MainAxisAlignment.center
                                    : isCurrentUser
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: isCurrentUser
                                    ? listTileContent.reversed.toList()
                                    : listTileContent),
                          );
                        }),
                  );
                }),

            // INPUTS
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      XFile? image =
                          await picker.pickImage(source: ImageSource.camera);

                      if (image != null) {
                        // conversationModel.sendImage(
                        //     File(image.path), widget.friendUid);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      if (images.isNotEmpty) {
                        for (final image in images) {
                          groupConversationModel.sendImage(
                              File(image.path),
                              profileModel.userDetails['full_name'],
                              profileModel.userDetails['profile_pic']);
                        }
                      }
                    },
                    icon: const Icon(Icons.image),
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
                      groupConversationModel
                          .sendMessage(
                              chatController.text,
                              profileModel.userDetails['full_name'],
                              profileModel.userDetails['profile_pic'],
                              'text')
                          .then((_) {
                        groupConversationModel.messageNotification();
                      });
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
        ));
      }),
    );
  }
}
