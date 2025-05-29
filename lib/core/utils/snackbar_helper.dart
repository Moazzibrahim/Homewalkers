import 'package:flutter/material.dart';

class SnackbarHelper {
  static void show(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.black87,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
