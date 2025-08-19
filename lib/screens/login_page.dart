import 'package:loopchat/constants.dart';
import 'package:loopchat/helper/hint_input_text.dart';
import 'package:loopchat/helper/show_snack_bar.dart';
import 'package:loopchat/helper/update_user_status.dart';
import 'package:loopchat/screens/chat_page.dart';
import 'package:loopchat/screens/forget_password_page.dart';
import 'package:loopchat/screens/register_page.dart';
import 'package:loopchat/widgets/customButton.dart';
import 'package:loopchat/widgets/customTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = "loginPage";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  String? username;
  bool isLoding = false;
  CollectionReference user =
      FirebaseFirestore.instance.collection(kUsersCollection);
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscureText = true;
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
                    const Image(
                      image: AssetImage(kLogo),
                      height: 100,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const HintInputText(
                      text: "Login",
                    ),
                    CustomTextFormField(
                      prefixIcon: const Icon(Icons.email),
                      hint: "e.g., user@example.com",
                      onChanged: (data) {
                        email = data;
                      },
                      controller: emailController,
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const HintInputText(text: "Password"),
                    CustomTextFormField(
                      prefixIcon: const Icon(Icons.lock),
                      hint: "•••••••••",
                      suffixIcon: IconButton(
                        icon: Icon(obscureText
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                      ),
                      onChanged: (data) {
                        password = data;
                      },
                      obscureText: obscureText,
                      controller: passwordController,
                    ),
                    Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextButton(
                          onPressed: () {
                            emailController.clear();
                            passwordController.clear();
                            Navigator.pushNamed(context, ForgetPasswordPage.id);
                          },
                          child: const Text(
                            "Forget Password?",
                            style: TextStyle(
                                color: Color.fromARGB(255, 54, 150, 180)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    CustomButton(
                      text: "Login",
                      onTap: () async {
                        isLoding = true;
                        setState(() {});
                        try {
                          await loginUser();
                          await getUserId();
                          emailController.clear();
                          passwordController.clear();
                          updateUserStatus();
                          Navigator.pushReplacementNamed(
                            context,
                            ChatPage.id,
                          );
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'invalid-credential') {
                            snackBarMessage(context,
                                "Incorrect email or password. Please try again.");
                          } else {
                            snackBarMessage(
                                context, e.message ?? "unknown error occured");
                          }
                        } catch (e) {
                          debugPrint(
                              "\n================================ error here: $e \n =========================\n");
                          // snackBarMessage(context, "Something went wrong");
                        }
                        isLoding = false;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account ? ",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            emailController.clear();
                            passwordController.clear();
                            Navigator.pushNamed(context, RegisterPage.id);
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(
                                color: Color.fromARGB(255, 54, 150, 180),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    // await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!);
  }

  Future<void> getUserId() async {
    var userQuery = user.where('email', isEqualTo: email).get();
    var querySnapshot = await userQuery;
    if (querySnapshot.docs.isNotEmpty) {
      var document = querySnapshot.docs.first;
      username = (document.data() as Map<String, dynamic>)['username'];
    } else {
      snackBarMessage(context, "Can't Find a username for the email");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
