//customizing text

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Color hintColor;
  final Color textColor;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator; // Add validator

  const CustomTextField({
    required this.hintText,
    this.obscureText = false,
    this.hintColor = Colors.grey,
    this.textColor = Colors.black,
    this.controller,
    this.suffixIcon,
    this.validator, // Initialize validator
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        suffixIcon: suffixIcon,
      ),
      validator: validator, // Attach validator here
    );
  }
}