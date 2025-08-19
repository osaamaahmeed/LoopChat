import 'package:loopchat/constants.dart';
import 'package:loopchat/helper/device_id_service.dart';
import 'package:loopchat/helper/hint_input_text.dart';
import 'package:loopchat/helper/show_snack_bar.dart';
import 'package:loopchat/helper/update_user_status.dart';
import 'package:loopchat/screens/chat_page.dart';
import 'package:loopchat/widgets/customButton.dart';
import 'package:loopchat/widgets/customTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static String id = "registerPqge";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // String? email;
  // String? username;
  // String? password;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoding = false;
  bool obscureText = true;
  CollectionReference users =
      FirebaseFirestore.instance.collection(kUsersCollection);
  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoding,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
              key: formKey,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Join our community today!",
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      ),
                      const SizedBox(height: 25),
                      const HintInputText(text: "Username"),
                      CustomTextFormField(
                        hint: "Enter your username",
                        prefixIcon: const Icon(Icons.person),
                        controller: usernameController,
                      ),
                      const SizedBox(height: 15),
                      const HintInputText(text: "Email Address"),
                      CustomTextFormField(
                        hint: "Enter your email address",
                        prefixIcon: const Icon(Icons.email),
                        controller: emailController,
                      ),
                      const SizedBox(height: 15),
                      const HintInputText(text: "Password"),
                      CustomTextFormField(
                        hint: "Create a password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                            icon: Icon(obscureText
                                ? Icons.visibility
                                : Icons.visibility_off)),
                        obscureText: obscureText,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 25),
                      CustomButton(
                        text: "Register",
                        onTap: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isLoding = true;
                            });
                            try {
                              await registerNewAcc();
                              if (mounted) {
                                Navigator.pushNamed(context, ChatPage.id);
                              }
                              usernameController.clear();
                              passwordController.clear();
                              emailController.clear();
                              updateUserStatus();
                            } on FirebaseFunctionsException catch (e) {
                              if (mounted) {
                                if (e.code == 'resource-exhausted') {
                                  snackBarMessage(context,
                                      'Account limit reached for this device.');
                                } else {
                                  snackBarMessage(
                                      context,
                                      e.message ??
                                          'An unknown error occurred.');
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              if (mounted) {
                                if (e.code == 'weak-password') {
                                  snackBarMessage(context, "Weak Password !");
                                } else if (e.code == 'email-already-in-use') {
                                  snackBarMessage(
                                      context, "Are you a hacker ?!");
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                snackBarMessage(context, e.toString());
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  isLoding = false;
                                });
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account ? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.lightBlue),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  Future<void> registerNewAcc() async {
    final String? deviceId = await DeviceIdService.getDeviceId();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();
    final String username = usernameController.text.trim();
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      throw "Please fill in all fields";
    }

    if (deviceId == null) {
      throw "Unable to get the user's device id";
    }
    try {
      final HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('registerUserWithDeviceCheck');
      final result = await callable.call<Map<String, dynamic>>({
        'email': email,
        'password': password,
        'username': username,
        'deviceId': deviceId
      });
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseFunctionsException {
      rethrow;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
