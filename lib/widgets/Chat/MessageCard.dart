import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final bool isRead;
  final Function()? onTap;
  const MessageCard({super.key, required this.isRead, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xffCAE5F1)),
        child: Row(
          children: [
            // Profile pic
            const CircleAvatar(
              backgroundImage: AssetImage('lib/assets/default_profile_pic.png'),
              maxRadius: 30,
            ),
            const SizedBox(
              width: 10,
            ),

            // Name & Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Billy Jeans'),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Hey, how are you?')
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),

            // Time ago
            Text('2m ago')
          ],
        ),
      ),
    );
  }
}
