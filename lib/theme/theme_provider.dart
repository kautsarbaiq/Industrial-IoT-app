import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Holds the active brightness. In-memory only (front-end demo); swap for
/// persisted storage when a backend / user-prefs service is wired in.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false; // bright/light look by default

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? AppTheme.dark : AppTheme.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDark(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
  }
}
