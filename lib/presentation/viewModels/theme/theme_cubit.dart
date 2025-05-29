// lib/presentation/viewModels/theme/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(super.initialState);

  void toggleTheme() async {
    final newTheme =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    emit(newTheme);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newTheme == ThemeMode.dark);
  }
}
