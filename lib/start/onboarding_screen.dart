import 'package:loopchat/helper/keep_signed_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _Page(
        title: "Welcome to LoopChat",
        body: "Jump into themed rooms, meet people, and keep chats synced.",
        imagePath: "assets/images/welcome.png",
      ),
      const _Page(
        title: "Fast & Secure",
        body: "Built on Firebase — realtime, encrypted in transit.",
        imagePath: "assets/images/secure.png",
      ),
      const _Page(
        title: "Ready?",
        body: "Create an account or sign in to start chatting.",
        imagePath: "assets/images/rocket.png",
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: const WormEffect(dotHeight: 10, dotWidth: 10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finish,
                    child: const Text("Skip"),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_index == pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Text(
                        _index == pages.length - 1 ? "Get started" : "Next"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.body,
    required this.imagePath,
  });

  final String title;
  final String body;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 24),
          Text(title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(body,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
