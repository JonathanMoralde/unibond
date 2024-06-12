import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Events/Events.dart';
import 'package:unibond/pages/Messages/Chats.dart';
import 'package:unibond/pages/Messages/Friends.dart';
import 'package:unibond/pages/Messages/Groups.dart';
import 'package:unibond/pages/Messages/Messages.dart';
import 'package:unibond/pages/MyProfile/MyProfile.dart';
import 'package:unibond/pages/Notifications/Notifications.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/GroupModel.dart';
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

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  late TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the initial length and vsync
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

    _tabController?.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController?.index == 2) {
      // Only fetch data if not initialized
      final friendsModel = Provider.of<FriendsModel>(context, listen: false);
      if (!friendsModel.isInitialized) {
        friendsModel.fetchFriendSuggestions();
      }
    }

    if (_tabController?.index == 1) {
      final groupModel = Provider.of<GroupModel>(context, listen: false);

      if (!groupModel.isInitialized) {
        groupModel.fetchGroups();
      }
    }
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
        ),
        drawer: SideMenu(pages: pages), // Drawer at the root level
        body: value.currentIndex == 0
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
        bottomNavigationBar: const BottomNavBar(),
      );
    });
  }
}
