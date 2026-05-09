import 'package:flutter/material.dart';
import 'main.dart'; 


class  AppData{
  // Dark mode
  static bool isDarkMode = false;


  static Color getPrimaryColor() {
    return const Color(0xFF195A64);
  }

  static Color getBackgroundColor() {
    return isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FD);
  }
}