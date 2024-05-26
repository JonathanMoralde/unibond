import 'package:flutter/material.dart';
import 'package:unibond/widgets/Chat/MessageCard.dart';

class Chats extends StatelessWidget {
  const Chats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            MessageCard(
              isRead: false,
              onTap: () {},
            ),
            MessageCard(
              isRead: true,
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }
}
