import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unibond/pages/LandingPage/GetStarted.dart';

class SpashScreen extends StatefulWidget {
  const SpashScreen({super.key});

  @override
  State<SpashScreen> createState() => _SpashScreenState();
}

class _SpashScreenState extends State<SpashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) {
          return const GetStarted();
        }),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('lib/assets/home_nobg_cropped.png'),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'A Mobile App for Connecting',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'Bicol University Polangui Students',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
