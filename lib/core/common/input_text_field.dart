import 'package:flutter/material.dart';

class UTextField extends StatelessWidget {
  const UTextField(
      {super.key, required this.controller, required this.labelText, this.validator, this.suffixIcon, required this.prefixIcon, this.keyboardType, this.obscureText = false});

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller:controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
      validator: validator,
    );
  }
}
