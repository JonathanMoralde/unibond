import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/LandingPage/GetStarted.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/widgets/styledButton.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer(builder: (context, value, child) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                StyledButton(
                    btnText: 'temp logout',
                    onClick: () {
                      final authProvider = context.read<AuthModel>();

                      authProvider.signOut().then((_) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    GetStarted()),
                            (route) => false);
                      });
                    })
              ],
            ),
          ),
        );
      }),
    );
  }
}
