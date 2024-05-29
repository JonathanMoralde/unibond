import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/MainLayout.dart';
import 'package:unibond/pages/MyProfile/MyProfile.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/provider/EditProfileModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/Profile/BioContainer.dart';
import 'package:unibond/widgets/Profile/InterestContainer.dart';
import 'package:unibond/widgets/styledButton.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  File? _image;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Fetch interests options once when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editProfileProvider = context.read<EditProfileModel>();
      editProfileProvider.fetchInterestsOptions();
      setState(() {
        _isInitialized = true;
      });
    });
  }

  Future _getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> insertDetails() async {
      final authProvider = context.read<AuthModel>();
      final editProfileProvider = context.read<EditProfileModel>();

      final user = authProvider.user!;
      try {
        if (_image != null) {
          await editProfileProvider.saveProfilePicture(_image!, user);
        }

        if (editProfileProvider.bioController.text.isNotEmpty) {
          await editProfileProvider.saveBio(
              editProfileProvider.bioController.text, user);
        }

        if (editProfileProvider.selectedInterests.isNotEmpty) {
          await editProfileProvider.saveInterests(
              editProfileProvider.selectedInterests, user);
        }
      } catch (e) {
        print(e);
        Fluttertoast.showToast(
          msg: 'Error occured while saving details, please try again!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }

    void handleDone() {
      setState(() {
        isLoading = true;
      });
      insertDetails().whenComplete(() {
        final authProvider = context.read<AuthModel>();
        final editProfileProvider = context.read<EditProfileModel>();
        final profileProvider = context.read<ProfileModel>();

        editProfileProvider.resetState();

        profileProvider.fetchUserDetails(authProvider.user!);

        Fluttertoast.showToast(
          msg: 'Account details were saved!',
          backgroundColor: Colors.green,
          textColor: Colors.black,
        );
        setState(() {
          isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const MainLayout(),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<EditProfileModel, AuthModel>(
          builder: (context, EditProfileModel, AuthModel, child) {
        // fetch options
        // EditProfileModel.fetchInterestsOptions();
        return Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
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
                            child: _image != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(_image!),
                                    maxRadius: 60,
                                  )
                                : const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'lib/assets/default_profile_pic.png'),
                                    maxRadius: 60,
                                  ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StyledButton(
                                btnText: 'Upload new photo',
                                onClick: _getImageFromGallery,
                                // noShadow: true,
                                borderRadius: BorderRadius.circular(16),
                                btnColor: Colors.white,
                                btnIcon: const Icon(Icons.file_upload),
                                textColor: Colors.black,
                                textSize: 14,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                btnHeight: 40,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                'At least 500x500 px recommended',
                                style: TextStyle(fontSize: 10),
                              ),
                              const Text(
                                'JPG or PNG is allowed',
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const BioContainer(),
                      const SizedBox(
                        height: 30,
                      ),
                      if (!_isInitialized) CircularProgressIndicator(),
                      if (_isInitialized)
                        Interestcontainer(
                          title: 'Select',
                          isDisplayOnly: false,
                          options: EditProfileModel.options,
                        ),
                      const SizedBox(
                        height: 30,
                      ),
                      StyledButton(
                          btnWidth: 300, btnText: 'DONE', onClick: handleDone)
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        );
      }),
    );
  }
}
