import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer<ProfileModel>(builder: (context, value, child) {
      final userDetails = value.userDetails;
      fullNameController.text = userDetails['full_name'] ?? '';
      emailController.text = userDetails['email'] ?? '';
      return SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // COVER PHOTO
                if (userDetails['cover_pic'] != '')
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: userDetails['cover_pic'] ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                if (userDetails['cover_pic'] == '')
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(158, 255, 111, 0)),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Upload cover photo'),
                          ],
                        ),
                      ),
                    ),
                  ),

                // PROFILE PHOTO
                Positioned(
                  bottom: 20,
                  child: Container(
                      width:
                          120, // double the maxRadius to cover the entire CircleAvatar
                      height:
                          120, // double the maxRadius to cover the entire CircleAvatar
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.20), // Shadow color with opacity
                            spreadRadius: 0, // Spread radius
                            blurRadius: 3, // Blur radius
                            offset: const Offset(
                                0, 3), // Offset in x and y directions
                          ),
                        ],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff00B0FF), // Border color
                          width: 2.0, // Border width
                        ),
                      ),
                      child: userDetails['profile_pic'] != null
                          ? CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userDetails['profile_pic']),
                              maxRadius: 60,
                            )
                          : const CircleAvatar(
                              backgroundImage: AssetImage(
                                  'lib/assets/default_profile_pic.png'),
                              maxRadius: 60,
                            )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Personal Details'),
                      GestureDetector(
                        child: Text('Edit'),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                      child: Column(
                    children: [
                      StyledTextFormField(
                          controller: fullNameController,
                          hintText: '',
                          isReadOnly: true,
                          obscureText: false),
                      const SizedBox(
                        height: 20,
                      ),
                      StyledTextFormField(
                          controller: emailController,
                          hintText: '',
                          isReadOnly: true,
                          obscureText: false),
                      const SizedBox(
                        height: 20,
                      ),
                      // StyledTextFormField(
                      //     controller: passwordController,
                      //     hintText: '',
                      //     isReadOnly: true,
                      //     obscureText: true),
                    ],
                  ))
                ],
              ),
            )
          ],
        ),
      ));
    }));
  }
}
