import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme.dart';

class SettingsProvider with ChangeNotifier {
  String _theme = 'system';
  String _language = 'zh_CN';
  bool _isLoading = true;

  SettingsProvider() {
    _loadSettings();
  }

  String get theme => _theme;
  String get language => _language;
  bool get isLoading => _isLoading;

  // 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = prefs.getString('theme') ?? 'system';
      _language = prefs.getString('language') ?? 'zh_CN';
      _isLoading = false;
    });
  }

  // 设置主题
  Future<void> setTheme(String theme) async {
    if (theme == _theme) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);

    setState(() {
      _theme = theme;
    });
  }

  // 设置语言
  Future<void> setLanguage(String language) async {
    if (language == _language) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    setState(() {
      _language = language;
    });
  }

  // 获取当前主题
  ThemeData getCurrentTheme() {
    if (_theme == 'dark') {
      return GenshinTheme.darkTheme;
    } else if (_theme == 'light') {
      return GenshinTheme.lightTheme;
    } else {
      // 跟随系统
      return MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness == Brightness.dark
          ? GenshinTheme.darkTheme
          : GenshinTheme.lightTheme;
    }
  }

  // 更新状态
  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }
}