import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibond/provider/AuthModel.dart';
import 'package:unibond/widgets/styledButton.dart';
import 'package:unibond/widgets/styledTextFormField.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    void handleSubmit() {
      setState(() {
        isLoading = true;
      });
      if (emailController.text.isNotEmpty) {
        final authProvider = context.read<AuthModel>();

        authProvider
            .sendPasswordResetLink(emailController.text.trim())
            .then((_) {
          emailController.clear();
          setState(() {
            isLoading = false;
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffFAF2F2),
      ),
      body: Consumer<AuthModel>(builder: (context, value, child) {
        return SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Forgot Password',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  StyledTextFormField(
                      controller: emailController,
                      hintText: 'Enter your email',
                      obscureText: false),
                  const SizedBox(
                    height: 30,
                  ),
                  StyledButton(
                    btnWidth: double.infinity,
                    btnText: 'Submit',
                    onClick: handleSubmit,
                    noShadow: true,
                  )
                ],
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ));
      }),
    );
  }
}
