import 'package:flutter/material.dart';
import 'package:unibond/widgets/Group/GroupCard.dart';

class Groups extends StatelessWidget {
  const Groups({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: [
              // CREATE GROUP CARD
              GestureDetector(
                onTap: () {},
                child: FractionallySizedBox(
                  widthFactor: 0.47,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50)),
                          child: Icon(
                            Icons.add_rounded,
                            size: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Create New',
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 27,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              GroupCard()
            ],
          ),
        ),
      )),
    );
  }
}
