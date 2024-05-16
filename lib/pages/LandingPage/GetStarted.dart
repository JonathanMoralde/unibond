import 'package:flutter/material.dart';
import 'package:unibond/pages/Register/Register.dart';
import 'package:unibond/widgets/styledButton.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('lib/assets/get_started.png'),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Find friends inside BU Polangui',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              StyledButton(
                btnWidth: double.infinity,
                btnText: 'Get Started',
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => Register(),
                    ),
                  );
                },
                noShadow: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
