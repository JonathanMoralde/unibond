import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldPassController = TextEditingController();

  final newPassController = TextEditingController();

  final confirmPassController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Change Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StyledTextFormField(
                    controller: oldPassController,
                    hintText: 'Old Password',
                    obscureText: true,
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StyledTextFormField(
                    controller: newPassController,
                    hintText: 'New Password',
                    obscureText: true,
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StyledTextFormField(
                    controller: confirmPassController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    isPassword: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  StyledButton(
                    btnText: 'Submit',
                    onClick: () async {
                      setState(() {
                        isLoading = true;
                      });

                      if (newPassController.text.isNotEmpty &&
                          confirmPassController.text.isNotEmpty &&
                          oldPassController.text.isNotEmpty) {
                        if (newPassController.text !=
                            confirmPassController.text) {
                          Fluttertoast.showToast(
                              msg:
                                  "New password does not match the confirm password",
                              gravity: ToastGravity.CENTER);
                          return;
                        }

                        try {
                          final cred = EmailAuthProvider.credential(
                              email: FirebaseAuth.instance.currentUser!.email!,
                              password: oldPassController.text);
                          await FirebaseAuth.instance.currentUser!
                              .reauthenticateWithCredential(cred)
                              .then((_) {
                            FirebaseAuth.instance.currentUser!
                                .updatePassword(newPassController.text)
                                .then((_) {
                              Fluttertoast.showToast(
                                  msg: 'Successfully changed the password',
                                  gravity: ToastGravity.CENTER);
                              setState(() {
                                isLoading = false;
                                oldPassController.clear();
                                newPassController.clear();
                                confirmPassController.clear();
                              });
                            });
                          }).catchError((e) {
                            Fluttertoast.showToast(
                                msg: 'Error: $e', gravity: ToastGravity.CENTER);
                            setState(() {
                              isLoading = false;
                            });
                          });
                        } catch (e) {
                          print("error changing password: $e");
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                    btnWidth: double.infinity,
                  )
                ],
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }
}
