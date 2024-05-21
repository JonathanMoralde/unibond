import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Events/Events.dart';
import 'package:unibond/pages/Messages/Messages.dart';
import 'package:unibond/pages/MyProfile/MyProfile.dart';
import 'package:unibond/pages/Notifications/Notifications.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/pages/Settings/Settings.dart' as SettingsPage;
import 'package:unibond/widgets/BottomNavBar.dart';
import 'package:unibond/widgets/drawer/pageObject.dart';
import 'package:unibond/widgets/drawer/sideMenu.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(builder: (context, value, child) {
      print(value.currentIndex);
      return Scaffold(
        appBar: AppBar(
          title: Text(
            value.currentIndex == 4
                ? 'My Profile'
                : pages[value.currentIndex].name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        drawer: SideMenu(pages: pages), // Drawer at the root level
        body: IndexedStack(
          index: value.currentIndex,
          children: const <Widget>[
            Messages(),
            Notifications(),
            Events(),
            SettingsPage.Settings(),
            MyProfile(),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(),
      );
    });
  }
}
