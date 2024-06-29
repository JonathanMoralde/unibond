import 'dart:convert';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:http/http.dart' as http;
import 'package:unibond/provider/ProfileModel.dart';

class CallPage extends StatefulWidget {
  final CallModel call;
  const CallPage({super.key, required this.call});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
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
      });
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
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({
                'connected': true,
              });
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint("Remote user $remoteUid left channel");

            if (callId != null) {
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({
                'connected': false,
              });
            }
          },
          onLeaveChannel: (connection, stats) {
            print('\x1B[31mremote user left the channel\x1B[0m');

            if (callId != null) {
              FirebaseFirestore.instance
                  .collection('calls')
                  .doc(callId)
                  .update({'active': false, 'connected': false});
            }
            Navigator.pop(context);
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
            Navigator.pop(context);
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
      'called_uid': widget.call.called,
      'active': true,
      'accepted': false,
      'rejected': false,
      'connected': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    print('\x1B[31mlocla user joined: $isLocalUserJoined\x1B[0m');
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            if (client == null) CircularProgressIndicator(),
            if (client != null)
              AgoraVideoViewer(
                client: client!,
                layoutType: Layout.oneToOne,
                enableHostControls: true, // Add this to enable host controls
              ),
            if (client != null)
              AgoraVideoButtons(
                client: client!,
              ),
            if (callId != null)
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
                            msg: "Call rejected", gravity: ToastGravity.CENTER);
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
      FirebaseFirestore.instance
          .collection('calls')
          .doc(callId)
          .update({'active': false, 'connected': false});
    }
  }
}
