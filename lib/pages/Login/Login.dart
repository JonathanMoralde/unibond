import 'package:flutter/material.dart';
import 'package:unibond/pages/ForgotPass/ForgotPass.dart';
import 'package:unibond/pages/Register/Register.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final loginFormKey = GlobalKey<FormState>();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    void handleSubmit() async {
      if (loginFormKey.currentState?.validate() ?? false) {
        // If the form is valid, proceed with the registration
        // Perform registration logic here
        print('true');
      } else {
        print('fill up shits');
      }
    }

    return Scaffold(
      body: SafeArea(
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
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
                        hintText: 'Enter your password'),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => ForgotPass(),
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
                          builder: (BuildContext context) => const Register(),
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
      )),
    );
  }
}
