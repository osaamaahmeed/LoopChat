import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loopchat/blocs/auth_bloc/auth_bloc.dart';
import 'package:loopchat/cubits/auth_cubit/auth_cubit.dart';
import 'package:loopchat/screens/chat_page.dart';
import 'package:loopchat/screens/forget_password_page.dart';
import 'package:loopchat/screens/login_page.dart';
import 'package:loopchat/screens/register_page.dart';
import 'package:loopchat/simple_bloc_observer.dart';
import 'package:loopchat/start/startup_gate.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loopchat/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = Simpleblocobserver();
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [ 
      BlocProvider(create: (context) => AuthCubit()), 
      BlocProvider(create: (context) => AuthBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const StartupGate(),
        routes: {
          LoginPage.id: (context) => const LoginPage(),
          RegisterPage.id: (context) => const RegisterPage(),
          ChatPage.id: (context) => const ChatPage(),
          ForgetPasswordPage.id: (context) => const ForgetPasswordPage()
        },
      ),
    );
  }
}
