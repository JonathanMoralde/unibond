import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:badges/badges.dart' as badges;
import 'package:unibond/provider/ProfileModel.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List<BottomNavigationBarItem> items = [
    if (FirebaseAuth.instance.currentUser?.uid != null)
      BottomNavigationBarItem(
        icon: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('users_id',
                    arrayContains: FirebaseAuth.instance.currentUser?.uid)
                .where("latest_chat_read", isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int messageCount = snapshot.data?.docs.length ?? 0;

              return badges.Badge(
                showBadge: messageCount > 0,
                badgeContent: Text(
                  messageCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: const Icon(Icons.chat_bubble),
              );
            }),
        label: "Messages",
      ),
    if (FirebaseAuth.instance.currentUser?.uid == null)
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble),
        label: "Messages",
      ),
    if (FirebaseAuth.instance.currentUser?.uid != null)
      BottomNavigationBarItem(
        icon: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('notification')
                .where('receiver_uid',
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where("is_read", isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              int notificationCount = snapshot.data?.docs.length ?? 0;

              return badges.Badge(
                showBadge: notificationCount > 0,
                badgeContent: Text(
                  notificationCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: const Icon(Icons.notifications),
              );
            }),
        label: "Notifications",
      ),
    if (FirebaseAuth.instance.currentUser?.uid == null)
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: "Notifications",
      ),
    if (FirebaseAuth.instance.currentUser?.uid != null)
      BottomNavigationBarItem(
        icon: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('announcements')
                .snapshots(),
            builder: (context, announcementSnapshot) {
              final filteredAnnouncements =
                  announcementSnapshot.data?.docs.where((doc) {
                List<dynamic> views = doc['views'] ??
                    []; // Default to empty array if 'views' is null
                return !views.contains(FirebaseAuth.instance.currentUser?.uid);
              }).toList();
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .snapshots(),
                  builder: (context, eventsSnapshot) {
                    final filteredEvents =
                        eventsSnapshot.data?.docs.where((doc) {
                      List<dynamic> views = doc['views'] ?? [];
                      return !views
                          .contains(FirebaseAuth.instance.currentUser?.uid);
                    }).toList();

                    // Calculate total unread (not viewed) announcements and events
                    int unreadCount = (filteredAnnouncements?.length ?? 0) +
                        (filteredEvents?.length ?? 0);

                    final profileModel =
                        Provider.of<ProfileModel>(context, listen: false);

                    if (profileModel.userDetails['role'] == 'admin') {
                      unreadCount = filteredEvents?.length ?? 0;
                    }
                    return badges.Badge(
                      showBadge: unreadCount > 0,
                      badgeContent: Text(
                        unreadCount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      child: const Icon(Icons.event),
                    );
                  });
            }),
        label: "Events",
      ),
    if (FirebaseAuth.instance.currentUser?.uid == null)
      BottomNavigationBarItem(
        icon: Icon(Icons.event),
        label: 'Events',
      ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext Bcontext) {
    return Consumer<NavigationModel>(builder: (context, value, child) {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 32,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Color.fromARGB(255, 81, 81, 81),
        selectedItemColor: Color(0xffFF5B00),
        items: items,
        currentIndex: value.currentIndex,
        onTap: (int newIndex) {
          setState(() {
            value.changeIndex(newIndex);
          });
        },
      );
    });
  }
}
