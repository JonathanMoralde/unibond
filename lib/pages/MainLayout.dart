import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:provider/provider.dart';
import 'package:unibond/main.dart';
import 'package:unibond/model/CallModel.dart';
import 'package:unibond/model/GroupCallModel.dart';
import 'package:unibond/pages/Events/Events.dart';
import 'package:unibond/pages/Messages/CallPage.dart';
import 'package:unibond/pages/Messages/Chats.dart';
import 'package:unibond/pages/Messages/Friends.dart';
import 'package:unibond/pages/Messages/Groups.dart';
import 'package:unibond/pages/Messages/Messages.dart';
import 'package:unibond/pages/Messages/SearchPage.dart';
import 'package:unibond/pages/MyProfile/MyProfile.dart';
import 'package:unibond/pages/Notifications/Notifications.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/pages/Settings/Settings.dart' as SettingsPage;
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/utils/FirebaseMessagingApi.dart';
import 'package:unibond/utils/NotificationService.dart';
import 'package:unibond/widgets/BottomNavBar.dart';
import 'package:unibond/widgets/drawer/pageObject.dart';
import 'package:unibond/widgets/drawer/sideMenu.dart';
import 'package:uuid/uuid.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  late TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the initial length and vsync
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    _tabController?.addListener(_handleTabSelection);

    // Initialize notifications
    // NotificationService.initializeNotification();
    FirebaseMessagingApi().initPushNotification();
    FirebaseMessagingApi().initialize(context);
  }

  void _handleTabSelection() {
    if (_tabController?.index == 2) {
      // Only fetch data if not initialized
      final friendsModel = Provider.of<FriendsModel>(context, listen: false);
      if (!friendsModel.isInitialized) {
        friendsModel.fetchFriendSuggestions();
      }
    }

    // if (_tabController?.index == 1) {
    //   final groupModel = Provider.of<GroupModel>(context, listen: false);

    //   if (!groupModel.isInitialized) {
    //     groupModel.fetchGroups();
    //   }
    // }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(builder: (context, value, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            value.currentIndex == 4
                ? 'My Profile'
                : pages[value.currentIndex].name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation:
              value.currentIndex == 0 ? 1 : const AppBarTheme().elevation,
          bottom: value.currentIndex == 0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: Container(
                    color: Color(0xffFC852B),
                    child: TabBar(
                      unselectedLabelColor: Colors.white,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Chats'),
                        Tab(text: 'Groups'),
                        Tab(text: 'Friends'),
                      ],
                    ),
                  ),
                )
              : null,
          actions: [
            value.currentIndex == 0
                ? IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => SearchPage(
                                initialIndex: _tabController!.index,
                              )));
                    },
                    icon: const Icon(Icons.search))
                : const SizedBox.shrink()
          ],
        ),
        drawer: SideMenu(pages: pages), // Drawer at the root level
        body: Stack(
          children: [
            value.currentIndex == 0
                ? TabBarView(
                    controller: _tabController!,
                    children: const <Widget>[
                      Chats(),
                      Groups(),
                      Friends(),
                    ],
                  )
                : IndexedStack(
                    index: value.currentIndex,
                    children: const <Widget>[
                      Chats(),
                      Notifications(),
                      Events(),
                      SettingsPage.Settings(),
                      MyProfile(),
                    ],
                  ),
            // if (FirebaseAuth.instance.currentUser?.uid != null)
            //   StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            //     stream: value.watchCalls(),
            //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //       endIncomingCall(value.uuid ?? '');
            //       value.activeCall = null;

            //       if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            //         print(snapshot.data?.docs.first);
            //         var callData = snapshot.data!.docs.first;
            //         var callDataMap = snapshot.data!.docs.first.data()
            //             as Map<String, dynamic>;
            //         var call = CallModel(
            //             id: callData.id,
            //             channel: callDataMap['channel'],
            //             caller: callDataMap['caller_uid'],
            //             callerName: callDataMap['caller_name'],
            //             callerPic: callDataMap['caller_pic'],
            //             called: callDataMap['called_uid'],
            //             active: callDataMap['active'],
            //             accepted: callDataMap['accepted'],
            //             rejected: callDataMap['rejected'],
            //             connected: callDataMap['connected'],
            //             isVideoCall: callDataMap['is_video_call']);

            //         if (call.id != value.lastCallId &&
            //             call.active != null &&
            //             call.active == true &&
            //             call.accepted != null &&
            //             call.accepted == false &&
            //             call.rejected != null &&
            //             call.rejected == false &&
            //             call.connected != null &&
            //             call.connected == false) {
            //           value.setLastCallId(call.id!);
            //           value.setNewUuid(Uuid().v4());

            //           showCallkitIncoming(
            //               value.uuid!,
            //               call.callerName,
            //               call.callerPic ??
            //                   'C:/Users/Tantan/AndroidStudioProjects/unibond/lib/assets/default_profile_pic.png');

            //           value.setActiveCall(call);
            //           print(value.activeCall);

            //           // Show notification
            //           // NotificationService.showNotification(
            //           //   title: 'Incoming Call',
            //           //   body:
            //           //       'You have an incoming call from ${call.callerName}',
            //           //   payload: {
            //           //     'navigate': 'true',
            //           //     'callId': call.id!,
            //           //     'channelName': '${call.caller}-${call.called}',
            //           //     'caller': call.caller,
            //           //     'callerName': call.callerName,
            //           //     'called': call.called,
            //           //     'isVideoCall': call.isVideoCall.toString()
            //           //   },
            //           //   category: NotificationCategory.Call,
            //           //   actionButtons: [
            //           //     NotificationActionButton(
            //           //       key: 'ACCEPT',
            //           //       label: 'Accept',
            //           //       actionType: ActionType.Default,
            //           //     ),
            //           //     NotificationActionButton(
            //           //       key: 'REJECT',
            //           //       label: 'Reject',
            //           //       actionType: ActionType.Default,
            //           //     ),
            //           //   ],
            //           // );
            //         }
            //       }

            //       return const SizedBox.shrink();
            //     },
            //   ),

            // // GROUP CALL
            // if (FirebaseAuth.instance.currentUser?.uid != null)
            //   StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            //     stream: value.watchGroupCalls(),
            //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //       if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            //         print(snapshot.data?.docs.first);
            //         var callData = snapshot.data!.docs.first;
            //         var callDataMap = snapshot.data!.docs.first.data()
            //             as Map<String, dynamic>;

            //         var call = GroupCallModel(
            //           id: callData.id,
            //           channel: callDataMap['channel'],
            //           caller: callDataMap['caller_uid'],
            //           callerName: callDataMap['caller_name'],
            //           groupName: callDataMap['group_name'],
            //           joined: (callDataMap['joined'] as List<dynamic>)
            //               .map((e) => e.toString())
            //               .toList(),
            //           members: (callDataMap['members'] as List<dynamic>)
            //               .map((e) => e.toString())
            //               .toList(),
            //           active: callDataMap['active'],
            //           isVideoCall: callDataMap['is_video_call'],
            //           rejected:
            //               ((callDataMap['rejected'] ?? []) as List<dynamic>)
            //                   .map((e) => e.toString())
            //                   .toList(),
            //         );

            //         if (call.id != value.lastCallId &&
            //             NotificationService.isNotifActive == false &&
            //             call.active != null &&
            //             call.active == true &&
            //             !call.rejected.contains(
            //                 Provider.of<ProfileModel>(context, listen: false)
            //                     .userDetails['uid'])) {
            //           value.setLastCallId(call.id!);
            //           NotificationService.isNotifActive = true;
            //           print('this ran');

            //           // Show notification
            //           NotificationService.showNotification(
            //             title: 'Incoming Call',
            //             body:
            //                 '${call.callerName} started a group call in ${call.groupName}',
            //             payload: {
            //               'navigate': 'true',
            //               'callId': call.id!,
            //               'channelName': call.channel,
            //               'caller': call.caller,
            //               'callerName': call.callerName,
            //               'groupName': call.groupName,
            //               'joined': call.joined.join(','),
            //               'rejeceted': call.rejected.join(','),
            //               'chatDocId': callDataMap['chat_doc_id'],
            //               'isVideoCall': call.isVideoCall.toString()
            //             },
            //             category: NotificationCategory.Call,
            //             actionButtons: [
            //               NotificationActionButton(
            //                 key: 'ACCEPT',
            //                 label: 'Accept',
            //                 actionType: ActionType.SilentBackgroundAction,
            //               ),
            //               NotificationActionButton(
            //                 key: 'REJECT',
            //                 label: 'Reject',
            //                 actionType: ActionType.SilentBackgroundAction,
            //               ),
            //             ],
            //           );
            //         }
            //       }

            //       return const SizedBox.shrink();
            //     },
            //   )
          ],
        ),
        bottomNavigationBar: const BottomNavBar(),
      );
    });
  }

  // Future<void> showCallkitIncoming(
  //     String uuid, String callerName, String callerPic) async {
  //   final params = CallKitParams(
  //     id: uuid,
  //     nameCaller: callerName,
  //     appName: 'Callkit',
  //     avatar: callerPic,
  //     handle: '0123456789',
  //     type: 0,
  //     textAccept: 'Accept',
  //     textDecline: 'Decline',
  //     missedCallNotification: const NotificationParams(
  //       showNotification: true,
  //       isShowCallback: false,
  //       subtitle: 'Missed call',
  //       callbackText: 'Call back',
  //     ),
  //     extra: <String, dynamic>{'userId': '1a2b3c4d'},
  //     headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
  //     android: const AndroidParams(
  //       isCustomNotification: true,
  //       isShowLogo: false,
  //       ringtonePath: 'system_ringtone_default',
  //       backgroundColor: '#F5F5F5',
  //       backgroundUrl: 'assets/test.png',
  //       actionColor: '#4CAF50',
  //       textColor: '#ffffff',
  //     ),
  //   );
  //   await FlutterCallkitIncoming.showCallkitIncoming(params);
  // }

  // Future<void> endIncomingCall(String uuid) async {
  //   await FlutterCallkitIncoming.endCall(uuid);
  // }

  // void initializeCallkit() {
  //   FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
  //     switch (event?.event) {
  //       case Event.actionCallAccept:
  //         // Handle call accept
  //         // print(currentCall);

  //         // // Accept call
  //         // FirebaseFirestore.instance
  //         //     .collection('calls')
  //         //     .doc(currentCall!.id)
  //         //     .update({'accepted': true});

  //         // WidgetsBinding.instance.addPostFrameCallback((_) {
  //         //   // Navigate to CallPage using the global navigator key
  //         //   navigatorKey.currentState?.push(
  //         //     MaterialPageRoute(
  //         //       builder: (context) => CallPage(
  //         //         call: CallModel(
  //         //             id: currentCall.id,
  //         //             caller: currentCall.caller ?? '',
  //         //             callerName: currentCall.callerName ?? '',
  //         //             called: currentCall.called ?? '',
  //         //             channel: currentCall.channel ?? '',
  //         //             active: true,
  //         //             accepted: true,
  //         //             rejected: false,
  //         //             connected: false,
  //         //             isVideoCall: currentCall.isVideoCall),
  //         //       ),
  //         //     ),
  //         //   );
  //         // });

  //         break;
  //       case Event.actionCallDecline:
  //         // Handle call decline
  //         break;
  //       default:
  //         break;
  //     }
  //   });
  // }

  // // Future<dynamic> getCurrentCall() async {
  // //   //check current call from pushkit if possible
  // //   var calls = await FlutterCallkitIncoming.activeCalls();
  // //   if (calls is List) {
  // //     if (calls.isNotEmpty) {
  // //       print('DATA: $calls');
  // //       // _currentUuid = calls[0]['id'];
  // //       return calls[0];
  // //     } else {
  // //       // _currentUuid = "";
  // //       return null;
  // //     }
  // //   }
  // //   return calls;
  // // }
}
