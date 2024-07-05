import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:unibond/pages/ForgotPass/ForgotPass.dart';
import 'package:unibond/pages/MainLayout.dart';
import 'package:unibond/pages/MyProfile/EditProfile.dart';
import 'package:unibond/pages/Register/Register.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/provider/ProfileModel.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final loginFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void handleSubmit() async {
      setState(() {
        isLoading = true;
      });
      final authProvider = context.read<AuthModel>();

      if (loginFormKey.currentState?.validate() ?? false) {
        await authProvider
            .loginUser(
                emailController.text.trim(), passwordController.text.trim())
            .then((_) async {
          emailController.clear();
          passwordController.clear();

          await authProvider.checkExistingUserDetails().then((response) async {
            setState(() {
              isLoading = false;
            });
            if (response) {
              await Provider.of<ProfileModel>(context, listen: false)
                  .fetchUserDetails(authProvider.user!);

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const MainLayout()),
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const EditProfile()),
                (route) => false,
              );
            }
          }).catchError((e) {
            print('error occured: $e');
            return;
          });
        }).catchError((e) {
          print('error occured: $e');
          return;
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

    return Scaffold(
      body: Stack(
        children: [
          Consumer<AuthModel>(builder: (context, value, child) {
            return SafeArea(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 70,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: const Text(
                        'Welcome Back!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: const Text(
                        'Let\'s help you find friends!',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Image.asset('lib/assets/welcome.png'),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      key: loginFormKey,
                      child: Column(
                        children: [
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
                            hintText: 'Enter your password',
                            isPassword: true,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ForgotPass(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff00B0FF),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          StyledButton(
                            btnText: 'Login',
                            onClick: handleSubmit,
                            btnWidth: double.infinity,
                            noShadow: true,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const Register(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff00B0FF),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ));
          }),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
