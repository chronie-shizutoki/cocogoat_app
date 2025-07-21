import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/achievement_provider.dart';
import 'screens/home_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/export_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const CocogoatApp());
}

class CocogoatApp extends StatelessWidget {
  const CocogoatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: MaterialApp(
        title: 'Cocogoat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    AchievementsScreen(),
    ExportScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // 初始化时加载成就数据
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AchievementProvider>();
      await provider.loadAchievements();
      
      // 如果没有数据，则初始化示例数据
      if (provider.achievements.isEmpty) {
        await _initializeSampleData(provider);
      }
    });
  }

  Future<void> _initializeSampleData(AchievementProvider provider) async {
    // 示例数据初始化已移除，现在使用真实的原神成就数据
    // 数据将在AchievementProvider.loadAchievements()中自动加载
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '成就',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_download),
            label: '导出',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

