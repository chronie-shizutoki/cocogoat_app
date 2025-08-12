import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/main_screen.dart';
import 'theme/theme.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(const GenshinAchievementApp());
}

class GenshinAchievementApp extends StatelessWidget {
  const GenshinAchievementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return MaterialApp(
              theme: GenshinTheme.lightTheme,
              darkTheme: GenshinTheme.darkTheme,
              themeMode: ThemeMode.system,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'Genshin Achievement',
            theme: GenshinTheme.lightTheme,
            darkTheme: GenshinTheme.darkTheme,
            themeMode: settingsProvider.theme == 'system'
                ? ThemeMode.system
                : settingsProvider.theme == 'dark'
                    ? ThemeMode.dark
                    : ThemeMode.light,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

