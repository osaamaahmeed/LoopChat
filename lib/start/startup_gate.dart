import 'package:loopchat/helper/keep_signed_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loopchat/start/onboarding_screen.dart';

class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  Future<bool> _seenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _seenOnboarding(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Material(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data! ? const AuthWrapper() : const OnboardingScreen();
      },
    );
  }
}
