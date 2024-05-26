// It creates an instance of an object with name, and widget
// used for adding pages in sideMenu.dart
import 'package:flutter/material.dart';
import 'package:unibond/pages/Events/Events.dart';
import 'package:unibond/pages/Messages/Chats.dart';
import 'package:unibond/pages/Messages/Messages.dart';
import 'package:unibond/pages/Notifications/Notifications.dart';
import 'package:unibond/pages/Settings/Settings.dart';

class SideMenuPage {
  final String name;
  final Widget page; //used for navigator
  final Widget? icon;

  SideMenuPage({required this.name, required this.page, this.icon});
}

// * THESE LIST ARE TO BE PASSED AS PARAMETER IN SIDEMENU
// * IMPORTING pageObject.dart automatically gives access to it

List<SideMenuPage> pages = [
  SideMenuPage(
      name: "Messages",
      page: const Chats(),
      icon: const Icon(Icons.chat_bubble)),
  SideMenuPage(
      name: "Notifications",
      page: const Notifications(),
      icon: const Icon(Icons.notifications)),
  SideMenuPage(
      name: "Events", page: const Events(), icon: const Icon(Icons.event)),
  SideMenuPage(
      name: "Settings",
      page: const Settings(),
      icon: const Icon(Icons.settings)),
];
