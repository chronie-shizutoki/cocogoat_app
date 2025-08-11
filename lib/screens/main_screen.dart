import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import 'home_screen.dart';
import 'achievements_screen.dart';
import 'export_screen.dart';
import 'settings_screen.dart';
import '../utils/animations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    AchievementsScreen(),
    ExportScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = GenshinAnimations.fadeInAnimation(_animationController);
    _animationController.forward();

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward();
    });
  }

  Future<void> _initializeSampleData(AchievementProvider provider) async {
    // 示例数据初始化已移除，现在使用真实的原神成就数据
    // 数据将在AchievementProvider.loadAchievements()中自动加载
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),
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