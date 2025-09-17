import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loopchat/constants.dart';
import 'package:loopchat/cubits/auth_cubit/auth_cubit.dart';
import 'package:loopchat/helper/hint_input_text.dart';
import 'package:loopchat/helper/show_snack_bar.dart';
import 'package:loopchat/helper/update_user_status.dart';
import 'package:loopchat/screens/chat_page.dart';
import 'package:loopchat/widgets/customButton.dart';
import 'package:loopchat/widgets/customTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterPage extends StatefulWidget {
  static String id = "registerPqge";


  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // String? email;
  TextEditingController usernameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  bool obscureText = true;

  CollectionReference users =
      FirebaseFirestore.instance.collection(kUsersCollection);

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          isLoading = false;
          usernameController.clear();
          passwordController.clear();
          emailController.clear();
          updateUserStatus();
          Navigator.pushReplacementNamed(context, ChatPage.id);
        } else if (state is RegisterLoading) {
          isLoading = true;
        } else if (state is RegisterFailure) {
          isLoading = false;
          snackBarMessage(context, state.errMessage);
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: isLoading,
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
                            onChanged: (value) {},
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
                                BlocProvider.of<AuthCubit>(context).registerNewAcc(email: emailController.text.trim(), password: passwordController.text.trim(), userName: usernameController.text.trim());
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
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
