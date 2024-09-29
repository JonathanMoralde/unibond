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
import 'package:unibond/pages/Announcements/Annoucements.dart';
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
  late TabController? _eventsTabController;

  int? notifId;
  Map<String, dynamic>? currentCallData;
  bool shouldResetCallData = false;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the initial length and vsync
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _eventsTabController =
        TabController(length: 2, vsync: this, initialIndex: 1);

    _tabController?.addListener(_handleTabSelection);
    _eventsTabController?.addListener(_handleEventsTabSelection);

    FirebaseMessagingApi().initPushNotification((int newNotifId) {
      setState(() {
        notifId = newNotifId;
      });
    }, (Map<String, dynamic> newCallData) {
      setState(() {
        currentCallData = newCallData;
      });
    });
    FirebaseMessagingApi().initialize((int newNotifId) {
      setState(() {
        notifId = newNotifId;
      });
    }, (Map<String, dynamic> newCallData) {
      setState(() {
        currentCallData = newCallData;
      });
    });
  }

  void _handleTabSelection() {
    if (_tabController?.index == 2) {
      // Only fetch data if not initialized
      final friendsModel = Provider.of<FriendsModel>(context, listen: false);
      if (!friendsModel.isInitialized) {
        friendsModel.fetchFriendSuggestions();
      }
    }
  }

  void _handleEventsTabSelection() {
    if (_tabController?.index == 1) {
      // Only fetch data if not initialized
      // final friendsModel = Provider.of<FriendsModel>(context, listen: false);
      // if (!friendsModel.isInitialized) {
      //   friendsModel.fetchFriendSuggestions();
      // }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (shouldResetCallData) {
      Future.microtask(() {
        setState(() {
          currentCallData = null;
          notifId = null;
          shouldResetCallData = false;
        });
      });
    }
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
              : value.currentIndex == 2
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: Container(
                        color: Color(0xffFC852B),
                        child: TabBar(
                          unselectedLabelColor: Colors.white,
                          labelColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.tab,
                          controller: _eventsTabController,
                          tabs: const [
                            Tab(text: 'Events'),
                            Tab(text: 'Announcement'),
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
                : value.currentIndex == 2
                    ? TabBarView(
                        controller: _eventsTabController!,
                        children: const <Widget>[Events(), Announcements()],
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
            if (FirebaseAuth.instance.currentUser?.uid != null &&
                currentCallData != null &&
                notifId != null)
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection(currentCallData!['groupName'] != null
                        ? 'group_calls'
                        : 'calls')
                    .where('id', isEqualTo: currentCallData!['id'])
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    print('NOTIF ID: ${notifId}');

                    final data = snapshot.data!.docs.first.data()
                        as Map<String, dynamic>;

                    if (data['active'] == false) {
                      print("NOTIF ID: ${notifId}");
                      print("call is inactive, removing notifcation");
                      // if call is not active
                      AwesomeNotifications().cancel(notifId!);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          currentCallData = null;
                          notifId = null;
                        });
                      });
                    }

                    return const SizedBox.shrink();
                  }

                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(),
      );
    });
  }
}
