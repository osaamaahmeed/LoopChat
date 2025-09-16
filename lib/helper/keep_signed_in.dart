import 'dart:convert';
import 'package:loopchat/helper/update_user_status.dart';
import 'package:loopchat/screens/chat_page.dart';
import 'package:loopchat/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final String jsonUrl =
      "https://firebasestorage.googleapis.com/v0/b/chat-app-a416b.firebasestorage.app/o/update_info.json?alt=media&token=e80866a2-a0bc-4162-8061-da1d811e7fea";
  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          updateUserStatus();

          return const ChatPage();
        } else {
          return LoginPage();
        }
      },
    );
  }

  Future<void> checkForUpdate() async {
    if (!mounted) return;
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      final int currentVersion = int.parse(info.buildNumber);
      final response = await http.get(Uri.parse(jsonUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final int latestVersion = jsonResponse['latest_version_code'];
        final String latestVersionName = jsonResponse['latest_version_name'];
        final String downloadUrl = jsonResponse['apk_download_url'];

        if (latestVersion > currentVersion && mounted) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PopScope(
                canPop: false,
                    child: AlertDialog(
                    title: const Text("Update Available"),
                    content: Text(
                        "A new version ($latestVersionName) is available. Please update to continue."),
                    actions: [
                      ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(downloadUrl);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Text("Update Now"))
                    ],
                  )));
        }
      }
    } catch (e) {
      debugPrint("Error checking for update $e");
    }
  }
}

/*


*/
