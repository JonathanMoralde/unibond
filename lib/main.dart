import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/LandingPage/SplashScreen.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/provider/ChatsModel.dart';
import 'package:unibond/provider/ConversationModel.dart';
import 'package:unibond/provider/CreateEventModel.dart';
import 'package:unibond/provider/CreateGroupChatModel.dart';
import 'package:unibond/provider/EventsModel.dart';
import 'package:unibond/provider/FriendsModel.dart';
import 'package:unibond/provider/GroupChatDetailsModel.dart';
import 'package:unibond/provider/GroupConversationModel.dart';
import 'package:unibond/provider/GroupModel.dart';
import 'package:unibond/provider/NavigationModel.dart';
import 'package:unibond/provider/EditProfileModel.dart';
import 'package:unibond/provider/NotificationModel.dart';
import 'package:unibond/provider/ProfileModel.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();

//   print("Handling a background message: ${message.messageId}");
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await dotenv.load(fileName: ".env");
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
        ChangeNotifierProvider(create: (_) => ChatsModel()),
        ChangeNotifierProvider(create: (_) => CreateEventModel()),
        ChangeNotifierProvider(create: (_) => EventsModel()),
        ChangeNotifierProvider(create: (_) => NotificationModel()),
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
      navigatorKey: navigatorKey,
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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        // canvasColor: Colors.white,
        useMaterial3: true,
      ),
      home: const SpashScreen(),
    );
  }
}
