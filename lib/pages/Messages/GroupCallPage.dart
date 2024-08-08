import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:unibond/model/GroupCallModel.dart';
import 'package:unibond/provider/GroupConversationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class GroupCallPage extends StatefulWidget {
  final GroupCallModel call;
  final String userUid;
  final String chatDocId;
  const GroupCallPage(
      {super.key,
      required this.call,
      required this.userUid,
      required this.chatDocId});

  @override
  State<GroupCallPage> createState() => _GroupCallPageState();
}

class _GroupCallPageState extends State<GroupCallPage> {
  final String appId = dotenv.env['AGORA_APP_ID'] ?? '';
  final String tokenBaseUrl = "https://unibond-token-server.onrender.com";

  String? token;

  String? callId;

  // UI KIT IMPLEMENTATION

  AgoraClient? client;

  bool isLocalUserJoined = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      callId = widget.call.id;
    });
    getToken().then((_) {
      initAgora().then((_) {
        if (callId == null) {
          makeCall();
        }

        if (widget.call.isVideoCall) {
          client!.engine.enableVideo();
        } else {
          client!.engine.disableVideo();
        }
      });
    });
    // initAgora().then((_) {
    //   // initiate call
    //   if (callId == null) {
    //     makeCall();
    //   }
    //   // else join
    // });
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    print("\x1B[31mINITIALIZING\x1B[0m");

    setState(() {
      client = AgoraClient(
        agoraConnectionData: AgoraConnectionData(
          appId: appId,
          channelName: widget.call.channel,
          tempToken: token,
        ),
        // tokenUrl: 'https://unibond-token-server.onrender.com'),
        agoraEventHandlers: AgoraRtcEventHandlers(
          onJoinChannelSuccess: (connection, uid) {
            print('\x1B[31mlocal user joined: $uid\x1B[0m');
          },
          onRejoinChannelSuccess: (connection, elapsed) {
            // if (callId != null) {
            //   FirebaseFirestore.instance
            //       .collection('group_calls')
            //       .doc(callId)
            //       .update({
            //     'connected': true,
            //   });
            // }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint("Remote user $remoteUid joined");

            // if (callId != null) {
            //   FirebaseFirestore.instance
            //       .collection('calls')
            //       .doc(callId)
            //       .update({
            //     'connected': true,
            //   });
            // }
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint("Remote user $remoteUid left channel");

            // if (callId != null) {
            //   FirebaseFirestore.instance
            //       .collection('calls')
            //       .doc(callId)
            //       .update({
            //     'connected': false,
            //   });
            // }
          },
          onLeaveChannel: (connection, stats) {
            print('\x1B[31mremote user left the channel\x1B[0m');

            // if (callId != null) {
            //   FirebaseFirestore.instance
            //       .collection('calls')
            //       .doc(callId)
            //       .update({'active': false, 'connected': false});
            // }
            // Navigator.pop(context);
          },
        ),
        agoraRtmChannelEventHandler: AgoraRtmChannelEventHandler(
          onMemberLeft: (member) async {
            if (callId != null) {
              final result = await FirebaseFirestore.instance
                  .collection('group_calls')
                  .doc(callId)
                  .get();

              final resultMap = result.data() as Map<String, dynamic>;
              final callJoined = (resultMap['joined'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();

              if (callJoined.length == 1 &&
                  callJoined.contains(
                      Provider.of<ProfileModel>(context, listen: false)
                          .userDetails['uid'])) {
                FirebaseFirestore.instance
                    .collection('group_calls')
                    .doc(callId)
                    .update({'active': false, 'joined': []});
              }
            }
            // Navigator.pop(context);
          },
        ),
      );
    });

    try {
      await client!.initialize();
      print('\x1B[31mclient initialized successfully!\x1B[0m');
    } catch (e) {
      print('\x1B[31mfaled to initialize: $e\x1B[0m');
    }
    client!.sessionController.updateUserVideo(
        uid: client!.agoraConnectionData.uid ?? 0,
        videoDisabled: !widget.call.isVideoCall);
  }

  Future<void> getToken() async {
    final response = await http.get(Uri.parse(
        '$tokenBaseUrl/access_token?channelName=${widget.call.channel}'));
    if (response.statusCode == 200) {
      setState(() {
        token = jsonDecode(response.body)['token'];
      });
    }
  }

  Future<void> makeCall() async {
    print("\x1B[31mMAKINGCALL\x1B[0m");
    final docRef = FirebaseFirestore.instance.collection('group_calls').doc();

    setState(() {
      callId = docRef.id;
    });

    await docRef.set({
      'id': docRef.id,
      'channel': widget.call.channel,
      'caller_uid': widget.call.caller,
      'caller_name': widget.call.callerName,
      'group_name': widget.call.groupName,
      'active': true,
      'members': widget.call.members, //List of String
      'joined': [widget.call.caller], //list of String
      'chat_doc_id': widget.chatDocId,
      'is_video_call': widget.call.isVideoCall,
      'rejected': []
    });

    // fetch fcm for each users
    for (final memberUid in widget.call.members) {
      if (memberUid != widget.call.caller) {
        final result = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberUid)
            .collection('fcm_tokens')
            .get();
        if (result.docs.isNotEmpty) {
          // send push notification to each fcm_token
          for (final fcmToken in result.docs
              .map((doc) => doc.data()['fcm_token'] as String)
              .toList()) {
            await sendPushNotification(fcmToken, memberUid);
          }
        }
      }
    }
  }

  Future<void> sendPushNotification(String token, String userCalled) async {
    final String notificationTitle = "Incoming Call";
    final String notificationBody =
        "You have an incoming call from ${widget.call.callerName}";

    final response = await http.post(
      Uri.parse('https://unibond-token-server.onrender.com/send_notification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'token': token, // replace with the actual recipient's FCM token
        'title': notificationTitle,
        'body': notificationBody,
        'callData': {
          'id': callId,
          'callerPic': widget.call.groupPic,
          'caller': widget.call.caller,
          'callerName': widget.call.callerName,
          'called': userCalled,
          'groupName': widget.call.groupName,
          'members': widget.call.members,
          'joined': [widget.call.caller],
          'rejected': widget.call.rejected,
          'channel': widget.call.channel,
          'chatDocId': widget.chatDocId,
          'isVideoCall': widget.call.isVideoCall
        },
      }),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('\x1B[31mlocla user joined: $isLocalUserJoined\x1B[0m');
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              if (client == null) CircularProgressIndicator(),
              if (client != null)
                AgoraVideoViewer(
                  client: client!,

                  layoutType: Layout.grid,
                  enableHostControls: true, // Add this to enable host controls
                ),
              if (client != null && callId != null)
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('group_calls')
                        .doc(callId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        final joined = (data['joined'] as List<dynamic>)
                            .map((e) => e.toString())
                            .toList();

                        return AgoraVideoButtons(
                          enabledButtons: widget.call.isVideoCall == false
                              ? [
                                  BuiltInButtons.toggleMic,
                                  BuiltInButtons.callEnd,
                                ]
                              : [
                                  BuiltInButtons.toggleMic,
                                  BuiltInButtons.callEnd,
                                  BuiltInButtons.switchCamera,
                                  BuiltInButtons.toggleCamera
                                ],
                          onDisconnect: () async {
                            if (joined.length == 1 &&
                                joined.contains(widget.userUid)) {
                              FirebaseFirestore.instance
                                  .collection('group_calls')
                                  .doc(callId)
                                  .update({'active': false, 'joined': []});

                              DocumentReference chatDoc = FirebaseFirestore
                                  .instance
                                  .collection('groups')
                                  .doc(widget.chatDocId);

                              CollectionReference messagesCollection =
                                  chatDoc.collection('messages');

                              Timestamp timeSent = Timestamp.now();

                              await messagesCollection.add({
                                'is_read': false,
                                'content':
                                    '${widget.call.isVideoCall ? 'video ' : ''}call ended',
                                'sender_id': widget.userUid,
                                'sender_name': widget.call.callerName,
                                'sender_profile_pic': '',
                                'timestamp': timeSent,
                                'type': 'notify'
                              });

                              await chatDoc.update({
                                'latest_chat_message':
                                    '${widget.call.isVideoCall ? 'video ' : ''}call ended',
                                'latest_chat_user': widget.userUid,
                                'latest_timestamp': timeSent,
                              });
                            }

                            if (joined.length > 1 &&
                                joined.contains(widget.userUid)) {
                              joined.remove(widget.userUid);

                              FirebaseFirestore.instance
                                  .collection('group_calls')
                                  .doc(callId)
                                  .update({'joined': joined});

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pop(context);
                              });
                            }
                          },
                          client: client!,
                        );
                      }

                      return SizedBox.shrink();
                    }),
              if (callId != null)
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('group_calls')
                        .doc(callId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;

                        final joined = (data['joined'] as List<dynamic>)
                            .map((e) => e.toString())
                            .toList();
                        if (joined.length == 0 || data['active'] == false) {
                          Fluttertoast.showToast(
                              msg: "Call Ended", gravity: ToastGravity.CENTER);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                          });
                          return SizedBox.shrink();
                        }
                      }

                      return SizedBox.shrink();
                    })
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    // await _engine!.leaveChannel(); // Leave the channel
    // await _engine!.release(); // Release resources
    client!.release();
    if (callId != null) {
      final result = await FirebaseFirestore.instance
          .collection('group_calls')
          .doc(callId)
          .get();

      final resultMap = result.data() as Map<String, dynamic>;
      final callJoined = (resultMap['joined'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      if (callJoined.length == 1 && callJoined.contains(widget.userUid)) {
        FirebaseFirestore.instance
            .collection('group_calls')
            .doc(callId)
            .update({'active': false, 'joined': []});

        DocumentReference chatDoc = FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.chatDocId);

        CollectionReference messagesCollection = chatDoc.collection('messages');

        Timestamp timeSent = Timestamp.now();

        await messagesCollection.add({
          'is_read': false,
          'content': '${widget.call.isVideoCall ? 'video ' : ''}call ended',
          'sender_id': widget.userUid,
          'sender_name': widget.call.callerName,
          'sender_profile_pic': '',
          'timestamp': timeSent,
          'type': 'notify'
        });

        await chatDoc.update({
          'latest_chat_message':
              '${widget.call.isVideoCall ? 'video ' : ''}call ended',
          'latest_chat_user': widget.userUid,
          'latest_timestamp': timeSent,
        });
      }

      if (callJoined.length > 1 && callJoined.contains(widget.userUid)) {
        callJoined.remove(widget.userUid);

        FirebaseFirestore.instance
            .collection('group_calls')
            .doc(callId)
            .update({'joined': callJoined});
      }
    }
  }
}
