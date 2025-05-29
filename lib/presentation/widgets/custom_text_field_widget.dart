import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final Widget? prefix;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hint,
    this.prefix,
    this.suffixIcon,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            // color: Color.fromRGBO(143, 146, 146, 1),
          ),
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(child: prefix),
                )
              : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xffE1E1E1)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
