import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:unibond/model/IndividualMessage.dart';
import 'package:unibond/pages/Messages/CallPage.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/utils/NotificationService.dart';
import 'package:unibond/widgets/styledTextFormField.dart';
import 'package:uuid/uuid.dart';

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
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('calls')
                  .where('called_uid', isEqualTo: widget.friendUid)
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
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('calls')
                        .where('caller_uid', isEqualTo: widget.friendUid)
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
                        onPressed: () async {
                          final result = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.friendUid)
                              .collection('fcm_tokens')
                              .get();

                          if (result.docs.isNotEmpty) {
                            // get fcm tokens of the user
                            final List<String> fcmTokens = result.docs
                                .map((doc) => doc.data()['fcm_token'] as String)
                                .toList();

                            // VIDEO CALL
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return CallPage(
                                  fcmTokens: fcmTokens,
                                  call: CallModel(
                                      accepted: null,
                                      active: null,
                                      called: widget.friendUid,
                                      caller: Provider.of<ProfileModel>(context,
                                              listen: false)
                                          .userDetails['uid'],
                                      callerName: Provider.of<ProfileModel>(
                                              context,
                                              listen: false)
                                          .userDetails['full_name'],
                                      callerPic: Provider.of<ProfileModel>(
                                              context,
                                              listen: false)
                                          .userDetails['profile_pic'],
                                      channel:
                                          '${Provider.of<ProfileModel>(context, listen: false).userDetails['uid']}-${widget.friendUid}', //localuseruid-frienduid
                                      // channel: 'test', //localuseruid-frienduid
                                      connected: null,
                                      id: null,
                                      rejected: null,
                                      isVideoCall: true),
                                );
                              }),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.videocam,
                          color: Colors.black,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    });
              }),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('calls')
                  .where('called_uid', isEqualTo: widget.friendUid)
                  .where('active', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final data = snapshot.data!.docs.first.data();

                  return const IconButton(
                      onPressed: null,
                      icon: Icon(
                        Icons.call,
                        color: Colors.grey,
                      ));
                }
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('calls')
                        .where('caller_uid', isEqualTo: widget.friendUid)
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
                        onPressed: () async {
                          final result = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.friendUid)
                              .collection('fcm_tokens')
                              .get();

                          if (result.docs.isNotEmpty) {
                            // get fcm tokens of the user
                            final List<String> fcmTokens = result.docs
                                .map((doc) => doc.data()['fcm_token'] as String)
                                .toList();

                            // AUDIO CALL
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return CallPage(
                                  fcmTokens: fcmTokens,
                                  call: CallModel(
                                      accepted: null,
                                      active: null,
                                      called: widget.friendUid,
                                      caller: Provider.of<ProfileModel>(context,
                                              listen: false)
                                          .userDetails['uid'],
                                      callerName: Provider.of<ProfileModel>(
                                              context,
                                              listen: false)
                                          .userDetails['full_name'],
                                      channel:
                                          '${Provider.of<ProfileModel>(context, listen: false).userDetails['uid']}-${widget.friendUid}',
                                      connected: null,
                                      id: null,
                                      rejected: null,
                                      isVideoCall: false),
                                );
                              }),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.call,
                          color: Colors.black,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    });
              })
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
                        content: messageDoc['content'],
                        type: messageDoc['type'],
                        receiverId: messageDoc['receiver_id'],
                        senderId: messageDoc['sender_id'],
                        timestamp: messageDoc['timestamp'],
                        isRead: messageDoc['is_read'],
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
                            String formattedDateTime =
                                conversationModel.formatDateTime(timeReceived);
                            // ========================================================

                            // Mark message as read if it's for the current user and not yet read
                            if (!isCurrentUser && msg[index].isRead == false) {
                              conversationModel.markMessageAsRead(
                                  conversationModel.chatDocId!,
                                  msg[index].msgDocId);
                            }

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
                                      : widget.friendProfilePic != null &&
                                              (widget.friendProfilePic
                                                      as String)
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
                                                        ? const Radius.circular(
                                                            0)
                                                        : const Radius.circular(
                                                            32),
                                                    topRight: isCurrentUser
                                                        ? const Radius.circular(
                                                            0)
                                                        : const Radius.circular(
                                                            32),
                                                    bottomLeft:
                                                        const Radius.circular(
                                                            32),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            32)),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                              child: Text(
                                                msg[index].content,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                          : msg[index].type == 'call'
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    final result =
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(widget
                                                                .friendUid)
                                                            .collection(
                                                                'fcm_tokens')
                                                            .get();

                                                    if (result
                                                        .docs.isNotEmpty) {
                                                      // get fcm tokens of the user
                                                      final List<String>
                                                          fcmTokens = result
                                                              .docs
                                                              .map((doc) => doc
                                                                          .data()[
                                                                      'fcm_token']
                                                                  as String)
                                                              .toList();

                                                      // VIDEO CALL
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                          return CallPage(
                                                            fcmTokens:
                                                                fcmTokens,
                                                            call: CallModel(
                                                                accepted: null,
                                                                active: null,
                                                                called: widget
                                                                    .friendUid,
                                                                caller: Provider.of<ProfileModel>(context, listen: false)
                                                                        .userDetails[
                                                                    'uid'],
                                                                callerName: Provider.of<ProfileModel>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .userDetails[
                                                                    'full_name'],
                                                                callerPic: Provider.of<ProfileModel>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .userDetails[
                                                                    'profile_pic'],
                                                                channel:
                                                                    '${Provider.of<ProfileModel>(context, listen: false).userDetails['uid']}-${widget.friendUid}', //localuseruid-frienduid
                                                                // channel: 'test', //localuseruid-frienduid
                                                                connected: null,
                                                                id: null,
                                                                rejected: null,
                                                                isVideoCall: msg[index]
                                                                    .content
                                                                    .contains('video')),
                                                          );
                                                        }),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: isCurrentUser
                                                          ? const Color(
                                                              0xffFF8C36)
                                                          : const Color(
                                                              0xff6ECDF7),
                                                      borderRadius: BorderRadius.only(
                                                          topLeft:
                                                              !isCurrentUser
                                                                  ? const Radius
                                                                      .circular(
                                                                      0)
                                                                  : const Radius
                                                                      .circular(
                                                                      32),
                                                          topRight:
                                                              isCurrentUser
                                                                  ? const Radius
                                                                      .circular(
                                                                      0)
                                                                  : const Radius
                                                                      .circular(
                                                                      32),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(32),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  32)),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                              color:
                                                                  isCurrentUser
                                                                      ? Colors
                                                                          .grey
                                                                      : Colors
                                                                          .red),
                                                          child: Icon(
                                                            Icons.phone_missed,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              msg[index]
                                                                  .content,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            Text(
                                                                isCurrentUser
                                                                    ? "Tap to call again"
                                                                    : "Tap to call back",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12))
                                                          ],
                                                        ),
                                                      ],
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
                                                            leading:
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Icon(
                                                                        Icons
                                                                            .close)),
                                                            actions: [
                                                              IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .save_alt),
                                                                  onPressed:
                                                                      () {
                                                                    conversationModel
                                                                        .saveImage(
                                                                            msg[index].content);
                                                                  }),
                                                            ],
                                                          ),
                                                          body: PhotoView(
                                                            imageProvider:
                                                                NetworkImage(msg[
                                                                        index]
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
                                                        imageUrl:
                                                            msg[index].content),
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                XFile? image = await picker.pickImage(
                                    source: ImageSource.camera);

                                if (image != null) {
                                  conversationModel.sendImage(
                                      File(image.path),
                                      widget.friendUid,
                                      profileModel.userDetails['full_name'],
                                      profileModel.userDetails['profile_pic']);
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final List<XFile> images = await picker
                                    .pickMultiImage(imageQuality: 70);
                                if (images.isNotEmpty) {
                                  for (final image in images) {
                                    conversationModel.sendImage(
                                        File(image.path),
                                        widget.friendUid,
                                        profileModel.userDetails['full_name'],
                                        profileModel
                                            .userDetails['profile_pic']);
                                    //     .then((_) {
                                    //   conversationModel.messageNotification(
                                    //       profileModel.userDetails['uid'],
                                    //       profileModel.userDetails['full_name'],
                                    //       widget.friendUid,
                                    //       true);
                                    // });
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
                                conversationModel.sendMessage(
                                    chatController.text,
                                    widget.friendUid,
                                    profileModel.userDetails['full_name'],
                                    profileModel.userDetails['profile_pic']);
                                //     .then((_) {
                                //   conversationModel.messageNotification(
                                //       profileModel.userDetails['uid'],
                                //       profileModel.userDetails['full_name'],
                                //       widget.friendUid,
                                //       false);
                                // });
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
