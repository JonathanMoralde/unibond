import 'dart:async';
import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:http/http.dart' as http;
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

class CallPage extends StatefulWidget {
  final CallModel call;
  final List<String>? fcmTokens;
  const CallPage({super.key, required this.call, this.fcmTokens});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final String appId = dotenv.env['AGORA_APP_ID'] ?? '';
  final String tokenBaseUrl = "https://unibond-token-server.onrender.com";

  String? token;

  String? callId;

  Timer? missedCallTimer;

  DateTime? callStartTime;

  // UI KIT IMPLEMENTATION

  AgoraClient? client;

  bool isLocalUserJoined = false;

  // bool? isVideoEnabled;

  @override
  void initState() {
    super.initState();
    setState(() {
      callId = widget.call.id;
      // isVideoEnabled = widget.call.isVideoCall;
    });
    getToken().then((_) {
      initAgora().then((_) {
        if (callId == null) {
          makeCall().then((_) {
            startMissedCallTimer();
          });
        }

        if (widget.call.isVideoCall) {
          client!.engine.enableVideo();
        } else {
          client!.engine.disableVideo();
        }
      });
    });

    // initAgora().then((_) {
    //   if (callId == null) {
    //     makeCall();
    //   }
    // });
  }

  // Function to start the missed call timer
  void startMissedCallTimer() {
    missedCallTimer = Timer(Duration(seconds: 30), () {
      // Trigger the missed call message if the remote user hasn't joined
      Provider.of<ConversationModel>(context, listen: false).sendMissedCall(
          'Missed ${widget.call.isVideoCall ? "video " : ''}call',
          widget.call.called);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      // endCall(); // Optionally end the call if it's missed
    });
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
          // tokenUrl: 'https://unibond-token-server.onrender.com'
        ),
        agoraEventHandlers: AgoraRtcEventHandlers(
          onJoinChannelSuccess: (connection, uid) {
            print('\x1B[31mlocal user joined: $uid\x1B[0m');
          },
          onRejoinChannelSuccess: (connection, elapsed) {
            if (callId != null) {
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({
                'connected': true,
              });
            }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint("Remote user $remoteUid joined");

            if (callId != null) {
              callStartTime = DateTime.now();
              print('executed after joined');
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({
                'connected': true,
              });
            }
            missedCallTimer?.cancel();
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint("Remote user $remoteUid offline");

            if (callId != null) {
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({
                'connected': false,
              });
            }
          },
          onLeaveChannel: (connection, stats) async {
            print('\x1B[31mremote user left the channel\x1B[0m');

            // int callDurationInSeconds = stats.duration ?? 0;
            // String formattedDuration =
            //     formatDuration(Duration(seconds: callDurationInSeconds));
            // print('\x1B[31m$formattedDuration\x1B[0m');

            if (callId != null) {
              final result = await FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .get();

              if (widget.call.caller ==
                      FirebaseAuth.instance.currentUser!.uid &&
                  (result.data() as Map<String, dynamic>)['accepted'] ==
                      false) {
                // send a missed call when caller ends call but called does not accept or reject
                String missedCallMessage =
                    'Missed ${widget.call.isVideoCall ? 'video ' : ''}call';
                Provider.of<ConversationModel>(context, listen: false)
                    .sendMissedCall(missedCallMessage, widget.call.called)
                    .then((_) => print("Missed call message sent"));
              }
              await FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({'active': false, 'connected': false}).then((_) {
                print("this executed on leave after firestore");
              });
            }
            // Navigator.pop(context);
          },
        ),
        agoraRtmChannelEventHandler: AgoraRtmChannelEventHandler(
          onMemberLeft: (member) {
            if (callId != null) {
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({'active': false, 'connected': false});
            }
            // Navigator.pop(context);
          },
        ),
      );
    });

    try {
      // client!.sessionController.updateUserVideo(
      //     uid: client!.agoraConnectionData.uid ?? 0,
      //     videoDisabled: !widget.call.isVideoCall);
      await client!.initialize();

      print('\x1B[31mclient initialized successfully!\x1B[0m');
    } catch (e) {
      print('\x1B[31mfaled to initialize: $e\x1B[0m');
    }
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
    final docRef = FirebaseFirestore.instance.collection('calls').doc();

    setState(() {
      callId = docRef.id;
    });

    await docRef.set({
      'id': docRef.id,
      'channel': '${widget.call.caller}-${widget.call.called}',
      'caller_uid': widget.call.caller,
      'caller_name': widget.call.callerName,
      'caller_pic': widget.call.callerPic,
      'called_uid': widget.call.called,
      'active': true,
      'accepted': false,
      'rejected': false,
      'connected': false,
      'is_video_call': widget.call.isVideoCall
    });

    for (final fcmToken in widget.fcmTokens!) {
      await sendPushNotification(fcmToken);
    }
  }

  Future<void> sendPushNotification(String token) async {
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
          'callerPic': widget.call.callerPic,
          'caller': widget.call.caller,
          'callerName': widget.call.callerName,
          'called': widget.call.called,
          'channel': widget.call.channel,
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              if (client == null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  height: MediaQuery.sizeOf(context).height,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(),
                      Column(
                        children: [
                          CircularProgressIndicator(),
                          Text("Loading...")
                        ],
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50)),
                        child: IconButton(
                          onPressed: () {
                            if (callId != null) {
                              FirebaseFirestore.instance
                                  .collection('calls')
                                  .doc(callId)
                                  .update(
                                      {'active': false, 'connected': false});
                            }
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.call_end),
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              if (client != null)
                AgoraVideoViewer(
                  client: client!,
                  layoutType: Layout.oneToOne,
                  enableHostControls: true, // Add this to enable host controls
                ),
              // if (client != null && callId != null && isVideoEnabled != null)
              if (client != null && callId != null)
                AgoraVideoButtons(
                  autoHideButtons: true,
                  client: client!,
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
                    if (callId != null) {
                      FirebaseFirestore.instance
                          .collection('calls')
                          .doc(callId)
                          .update({'active': false, 'connected': false});
                    }
                  },
                ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     AgoraVideoButtons(
              //       client: client!,
              //       enabledButtons: widget.call.isVideoCall == false
              //           ? [
              //               BuiltInButtons.toggleMic,
              //               BuiltInButtons.callEnd,
              //               BuiltInButtons.switchCamera
              //             ]
              //           : [
              //               BuiltInButtons.toggleMic,
              //               BuiltInButtons.callEnd,
              //               BuiltInButtons.switchCamera,
              //               BuiltInButtons.toggleCamera
              //             ],
              //       onDisconnect: () async {
              //         if (callId != null) {
              //           FirebaseFirestore.instance
              //               .collection('calls')
              //               .doc(callId)
              //               .update({'active': false, 'connected': false});
              //         }
              //       },
              //     ),
              //     if (widget.call.isVideoCall == false)
              //       InkWell(
              //         borderRadius: BorderRadius.circular(50),
              //         onTap: () {
              //           if (isVideoEnabled == true) {
              //             client!.engine.disableVideo();
              //           } else {
              //             client!.engine.enableVideo();
              //           }
              //           setState(() {
              //             isVideoEnabled = !isVideoEnabled!;
              //           });
              //         },
              //         child: Container(
              //           padding: EdgeInsets.all(10),
              //           margin:
              //               EdgeInsets.only(bottom: 58, left: 16, right: 16),
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(50),
              //               color: isVideoEnabled == true
              //                   ? Colors.white
              //                   : Colors.blue.shade600),
              //           child: Icon(
              //             isVideoEnabled == true
              //                 ? Icons.videocam
              //                 : Icons.videocam_off,
              //             color: isVideoEnabled == true
              //                 ? Colors.blue.shade600
              //                 : Colors.white,
              //           ),
              //         ),
              //       ),
              //   ],
              // ),
              if (callId != null && client != null)
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        if (data['rejected'] == true) {
                          Fluttertoast.showToast(
                              msg: "Call rejected",
                              gravity: ToastGravity.CENTER);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                          });
                          return SizedBox.shrink();
                        }
                        if (data['active'] == false && callStartTime != null) {
                          // send call ended message
                          final conversationModel =
                              Provider.of<ConversationModel>(context,
                                  listen: false);

                          Duration callDuration =
                              DateTime.now().difference(callStartTime!);

                          String formattedDuration =
                              formatDuration(callDuration);
                          print('\x1B[31m$formattedDuration\x1B[0m');

                          if (widget.call.caller ==
                                  Provider.of<ProfileModel>(context,
                                          listen: false)
                                      .userDetails['uid'] &&
                              data['accepted'] == true) {
                            print('time: ${formattedDuration}');
                            conversationModel
                                .sendCallDurationMessage(
                                    '${widget.call.isVideoCall ? 'Video ' : ''}Call has ended. ${formattedDuration}',
                                    widget.call.called)
                                .then((_) {
                              print("sent notify");
                            });
                          }

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
      print("executed dispose");
      FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .update({'active': false, 'connected': false});
    }
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
