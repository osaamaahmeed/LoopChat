import 'package:loopchat/constants.dart';
import 'package:loopchat/helper/hint_input_text.dart';
import 'package:loopchat/helper/show_snack_bar.dart';
import 'package:loopchat/widgets/customButton.dart';
import 'package:loopchat/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});
  static String id = 'forgetPassword';
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  TextEditingController controller = TextEditingController();
  String email = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      // appBar: AppBar(
      //   backgroundColor: kAppBarColor,
      //   title: Text(
      //     "Forget Password",
      //     style: TextStyle(
      //       color: Colors.white,
      //       fontSize: 19,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   centerTitle: true,
      // ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    "Forget Password",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Enter your registered email address below to reset your password",
                    style: TextStyle(color: Colors.grey, fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const HintInputText(text: "Email Address"),
                  const SizedBox(
                    height: 1,
                  ),
                  CustomTextFormField(
                    hint: "your@email.com",
                    controller: controller,
                    prefixIcon: const Icon(Icons.email),
                    onChanged: (data) {
                      email = data;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomButton(
                    text: "Reset Password",
                    onTap: () async {
                      resetPassword();
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    showDialog(
        context: context,
        builder: (contex) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
    try {
      print("\n\n $email \n\n");
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop();
      snackBarMessage(context,
          "If an account with that email exists, a password reset link has been sent.");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();
      String errorMsg;
      if (e.code == 'user-not-found') {
        errorMsg = 'No User found for that email';
      } else {
        errorMsg = e.message ?? 'An unkown error occurred.';
      }
      snackBarMessage(context, errorMsg);
    } catch (e) {
      print("=========== $e =================");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
