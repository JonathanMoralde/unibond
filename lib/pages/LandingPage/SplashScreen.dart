import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/LandingPage/GetStarted.dart';
import 'package:unibond/pages/MainLayout.dart';
import 'package:unibond/provider/AuthModel.dart';

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
      _navigateBasedOnAuthState().then((response) {
        print(response);
        if (response == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
              return const MainLayout();
            }),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
              return const GetStarted();
            }),
            (route) => false,
          );
        }
      });
    });
  }

  Future<bool> _navigateBasedOnAuthState() async {
    // initialize the provider first before delay
    final authProvider = Provider.of<AuthModel>(context, listen: false);

    await Future.delayed(const Duration(seconds: 3));

    print('authProvider');
    print(authProvider.user);
    if (authProvider.user == null) {
      return false;
    } else {
      return true;
    }
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
            Image.asset('lib/assets/newlogo.png'),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Uni',
                  style: TextStyle(
                      color: Color(0xff0072A5),
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Bond',
                  style: TextStyle(
                      color: Color(0xffFF6E00),
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
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
