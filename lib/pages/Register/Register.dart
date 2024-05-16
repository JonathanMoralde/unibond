import 'package:flutter/material.dart';
import 'package:unibond/pages/Login/Login.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final registrationFormKey = GlobalKey<FormState>();

    void handleSubmit() async {
      if (registrationFormKey.currentState?.validate() ?? false) {
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
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'UniBond App!',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
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
                            controller: fullNameController,
                            hintText: 'Enter your full name'),
                        const SizedBox(
                          height: 20,
                        ),
                        StyledTextFormField(
                            controller: emailController,
                            hintText: 'Enter your email'),
                        const SizedBox(
                          height: 20,
                        ),
                        StyledTextFormField(
                            controller: passwordController,
                            hintText: 'Enter password'),
                        const SizedBox(
                          height: 20,
                        ),
                        StyledTextFormField(
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
                              builder: (BuildContext context) => const Login(),
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
    );
  }
}
