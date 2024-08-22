import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:badges/badges.dart' as badges;

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List<BottomNavigationBarItem> items = [
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
    BottomNavigationBarItem(
      icon: Icon(Icons.event),
      label: "Events",
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
