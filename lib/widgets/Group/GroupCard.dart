import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              const CircleAvatar(
                backgroundImage:
                    AssetImage('lib/assets/default_profile_pic.png'),
                maxRadius: 45,
              ),
              const SizedBox(
                height: 14,
              ),
              const Text(
                'IT Students',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 10,
                  ),
                  const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 10,
                  ),
                  const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 10,
                  ),
                  const CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/default_profile_pic.png'),
                    maxRadius: 10,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '78+',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
