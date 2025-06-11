import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final Widget? prefix;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final bool? enabled;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hint,
    this.prefix,
    this.suffixIcon,
    this.controller,
    this.textInputType,
    this.enabled,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.textInputType,
        enabled: widget.enabled,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            // color: Color.fromRGBO(143, 146, 146, 1),
          ),
          prefixIcon:
              widget.prefix != null
                  ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(child: widget.prefix),
                  )
                  : null,
          suffixIcon: widget.suffixIcon,
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
