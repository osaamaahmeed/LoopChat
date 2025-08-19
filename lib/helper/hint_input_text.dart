import 'package:flutter/material.dart';

class HintInputText extends StatelessWidget {
  const HintInputText({
    super.key,
    required this.text
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 17),
        ),
      ),
    );
  }
}