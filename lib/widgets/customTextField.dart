// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      required this.hint,
      this.onChanged,
      this.obscureText = false,
      required this.controller,
      this.prefixIcon,
      this.suffixIcon});
  final String hint;
  final Function(String)? onChanged;
  final bool? obscureText;
  final TextEditingController controller;
  final Icon? prefixIcon;
  final IconButton? suffixIcon;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText!,
      validator: (data) {
        if (data!.isEmpty || data.trim().isEmpty) return "Field is required";
        if (data.contains(' ')) return "Spaces are not allowed";
        return null;
      },
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white
      ),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 126, 226, 254)),
          ),
          border: const OutlineInputBorder(
            // borderSide: BorderSide(color: Colors.white),
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            // borderSide: BorderSide(color: Colors.white),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14)),
    );
  }
}
