import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/LandingPage/SplashScreen.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/CreateGroupChatModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';
import 'package:unibond/provider/GroupConversationModel.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/provider/EditProfileModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => EditProfileModel()),
        ChangeNotifierProvider(create: (_) => ProfileModel()),
        ChangeNotifierProvider(create: (_) => NavigationModel()),
        ChangeNotifierProvider(create: (_) => FriendsModel()),
        ChangeNotifierProvider(create: (_) => ConversationModel()),
        ChangeNotifierProvider(create: (_) => CreateGroupChatModel()),
        ChangeNotifierProvider(create: (_) => GroupModel()),
        ChangeNotifierProvider(create: (_) => GroupConversationModel()),
        ChangeNotifierProvider(create: (_) => GroupChatDetailsModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniBond',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xff00B0FF),
          elevation: 4.0,
          shadowColor: Colors.black,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff00B0FF)),
        scaffoldBackgroundColor: const Color(0xffFAF2F2),
        useMaterial3: true,
      ),
      home: const SpashScreen(),
    );
  }
}
