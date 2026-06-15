import 'package:flutter/material.dart';

class Constants {
  static String baseUrl = ''; // 🔥 بقى dynamic
  static const Color maincolor = Color(0xff003178);
  static const Color mainlightmodecolor = Color(0xff003178);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF003178), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color mainDarkmodecolor = Color(0xff003178);
  static const Color backgroundlightmode = Color(0xFFF5F5F5);
  static const Color backgroundDarkmode = Color(0xFF0D0707);
}
