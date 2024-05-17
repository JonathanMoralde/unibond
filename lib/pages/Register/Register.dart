import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/Login/Login.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final registrationFormKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    void handleSubmit() async {
      setState(() {
        isLoading = true;
      });
      final authProvider = context.read<AuthModel>();
      if (registrationFormKey.currentState?.validate() ?? false) {
        if (passwordController.text.trim() !=
            confirmPasswordController.text.trim()) {
          Fluttertoast.showToast(
            msg: "Password does not match with confirm password",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          return;
        }

        authProvider
            .registerUser(fullNameController.text.trim(),
                emailController.text.trim(), passwordController.text.trim())
            .then((_) {
          fullNameController.clear();
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          setState(() {
            isLoading = false;
          });
        });
      } else {
        Fluttertoast.showToast(
          msg: "Please fill up the required fields",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          isLoading = false;
        });
      }
    }

    return Consumer<AuthModel>(builder: (context, value, child) {
      return Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 110,
                        ),
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'UniBond App!',
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Let\'s get started!',
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Form(
                          key: registrationFormKey,
                          child: Column(
                            children: [
                              StyledTextFormField(
                                  obscureText: false,
                                  controller: fullNameController,
                                  hintText: 'Enter your full name'),
                              const SizedBox(
                                height: 20,
                              ),
                              StyledTextFormField(
                                  obscureText: false,
                                  controller: emailController,
                                  hintText: 'Enter your email'),
                              const SizedBox(
                                height: 20,
                              ),
                              StyledTextFormField(
                                  obscureText: true,
                                  controller: passwordController,
                                  hintText: 'Enter password'),
                              const SizedBox(
                                height: 20,
                              ),
                              StyledTextFormField(
                                  obscureText: true,
                                  controller: confirmPasswordController,
                                  hintText: 'Confirm password'),
                              const SizedBox(
                                height: 80,
                              ),
                              StyledButton(
                                btnText: 'Register',
                                onClick: handleSubmit,
                                btnWidth: double.infinity,
                                noShadow: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?'),
                            const SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                    color: Color(0xff00B0FF),
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const Login(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // loading
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
      );
    });
  }
}
