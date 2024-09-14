import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Settings/ChangePassword.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledButton.dart';
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

  bool isLocked = true;

  Future _getImageFromGallery() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('cover_pictures/${userUid}.jpg');
      await storageRef.putFile(File(pickedImage.path));

      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();

      // Update the user's profile information in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUid)
          .update({'cover_pic': imageUrl}).then((_) {
        Fluttertoast.showToast(
            msg: 'Cover pic was saved successfully',
            gravity: ToastGravity.CENTER);

        Provider.of<ProfileModel>(context, listen: false)
            .fetchUserDetails(FirebaseAuth.instance.currentUser!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 1,
          child: Image.asset(
            'lib/assets/announcementbg.png',
            alignment: AlignmentDirectional.bottomEnd,
          ),
        ),
        Consumer<ProfileModel>(builder: (context, value, child) {
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
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: userDetails['cover_pic'] ?? '',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 20,
                              top: 20,
                              child: InkWell(
                                onTap: () {
                                  _getImageFromGallery();
                                },
                                child: const Icon(Icons.camera_alt),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (userDetails['cover_pic'] == '')
                      GestureDetector(
                        onTap: () {
                          _getImageFromGallery();
                        },
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
                                color: Colors.black.withOpacity(
                                    0.20), // Shadow color with opacity
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
                            onTap: () async {
                              if (isLocked) {
                                setState(() {
                                  isLocked = false;
                                });
                              } else {
                                try {
                                  if (fullNameController.text.isNotEmpty &&
                                      fullNameController.text !=
                                          value.userDetails['full_name']) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update({
                                      'full_name': fullNameController.text
                                    }).then((_) {
                                      value.fetchUserDetails(
                                          FirebaseAuth.instance.currentUser!);
                                      Fluttertoast.showToast(
                                          msg:
                                              'Full name was successfully updated!',
                                          gravity: ToastGravity.CENTER);
                                    });
                                  }
                                  if (emailController.text.isNotEmpty &&
                                      emailController.text !=
                                          value.userDetails['email']) {
                                    if (!emailController.text
                                        .endsWith('@bicol-u.edu.ph')) {
                                      Fluttertoast.showToast(
                                        msg: 'Invalid email address',
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                      return; // Exit the function if the email domain is not allowed
                                    }

                                    // Show re-authentication dialog
                                    String? password =
                                        await showReAuthDialog(context);

                                    if (password != null) {
                                      User? user =
                                          FirebaseAuth.instance.currentUser;
                                      AuthCredential credential =
                                          EmailAuthProvider.credential(
                                        email: user!.email!,
                                        password: password,
                                      );

                                      await user
                                          .reauthenticateWithCredential(
                                              credential)
                                          .then((_) async {
                                        await user
                                            .verifyBeforeUpdateEmail(
                                                emailController.text)
                                            .then((_) async {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            'email': emailController.text
                                          }).then((_) {
                                            value.fetchUserDetails(FirebaseAuth
                                                .instance.currentUser!);
                                            Fluttertoast.showToast(
                                                msg:
                                                    'An email verification link has been sent to the new email',
                                                gravity: ToastGravity.CENTER);
                                          });
                                        });
                                      }).catchError((error) {
                                        Fluttertoast.showToast(
                                          msg:
                                              'Re-authentication failed. Please try again.',
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      });
                                    }
                                  }
                                } catch (e) {
                                  print("error saving new details: $e");
                                }

                                setState(() {
                                  isLocked = true;
                                });
                              }
                            },
                            child: Text(isLocked ? 'Edit' : 'Save'),
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
                              isReadOnly: isLocked,
                              obscureText: false),
                          const SizedBox(
                            height: 20,
                          ),
                          StyledTextFormField(
                              controller: emailController,
                              hintText: '',
                              isReadOnly: isLocked,
                              obscureText: false),
                          const SizedBox(
                            height: 20,
                          ),
                          if (!isLocked)
                            StyledButton(
                              btnText: 'Change password',
                              onClick: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChangePassword(),
                                  ),
                                );
                              },
                              btnWidth: double.infinity,
                              noShadow: true,
                              isBorder: true,
                              borderColor: const Color(0xff00B0FF),
                              btnColor: Colors.white,
                              textColor: Colors.black,
                              textSize: 16,
                              btnIcon: const Icon(Icons.password),
                              borderRadius: BorderRadius.circular(50),
                              fontWeight: FontWeight.normal,
                            )
                        ],
                      ))
                    ],
                  ),
                )
              ],
            ),
          ));
        }),
      ],
    ));
  }

  Future<String?> showReAuthDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Re-authenticate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
