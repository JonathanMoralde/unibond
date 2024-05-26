import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/NavigationModel.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  List<BottomNavigationBarItem> items = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble),
      label: "Messages",
    ),
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
