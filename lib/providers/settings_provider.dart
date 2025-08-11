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
    _theme = prefs.getString('theme') ?? 'system';
    _language = prefs.getString('language') ?? 'zh_CN';
    _isLoading = false;
    notifyListeners();
  }

  // 设置主题
  Future<void> setTheme(String theme) async {
    if (theme == _theme) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);

    _theme = theme;
    notifyListeners();
  }

  // 设置语言
  Future<void> setLanguage(String language) async {
    if (language == _language) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    _language = language;
    notifyListeners();
  }

  // 获取当前主题
  ThemeData getCurrentTheme() {
    if (_theme == 'dark') {
      return GenshinTheme.darkTheme;
    } else if (_theme == 'light') {
      return GenshinTheme.lightTheme;
    } else {
      // 跟随系统
      // 跟随系统
      final view = WidgetsBinding.instance.platformDispatcher.implicitView;
      if (view != null) {
        return MediaQueryData.fromView(view).platformBrightness == Brightness.dark
            ? GenshinTheme.darkTheme
            : GenshinTheme.lightTheme;
      } else {
        // 默认使用浅色主题
        return GenshinTheme.lightTheme;
      }
    }
  }

  // 移除了 setState 方法，Provider 中不需要此方法
  // 直接修改状态变量后调用 notifyListeners() 即可
}