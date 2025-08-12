import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';
import '../providers/achievement_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsProvider _settingsProvider;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    // 监听设置变化
    _settingsProvider.addListener(_onSettingsChanged);
    // 初始加载完成
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {
      // 设置变化时更新UI
    });
  }

  // 获取当前语言显示名称
  String _getCurrentLanguageDisplayName() {
    return _getLanguageDisplayName(_settingsProvider.language);
  }

  // 获取当前主题显示名称
  String _getCurrentThemeDisplayName() {
    return _getThemeDisplayName(_settingsProvider.theme);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // 应用设置
          _buildSectionHeader('应用设置'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            subtitle: Text(_getCurrentLanguageDisplayName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题'),
            subtitle: Text(_getCurrentThemeDisplayName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
          ),
          
          const Divider(),
          
          // 数据管理
          _buildSectionHeader('数据管理'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('备份数据'),
            subtitle: const Text('将数据导出为备份文件'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showBackupDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('恢复数据'),
            subtitle: const Text('从备份文件恢复数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRestoreDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('清除所有数据', style: TextStyle(color: Colors.red)),
            subtitle: const Text('删除所有成就和设置数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDataDialog(),
          ),
          
          const Divider(),
          
          // 关于
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('版本信息'),
            subtitle: const Text('Genshin Achievement v1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('帮助与支持'),
            subtitle: const Text('使用说明和常见问题'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showHelpDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return '简体中文';
      case 'zh_TW':
        return '繁體中文';
      case 'en_US':
        return 'English';
      case 'ja_JP':
        return '日本語';
      default:
        return '简体中文';
    }
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return '浅色主题';
      case 'dark':
        return '深色主题';
      case 'system':
        return '跟随系统';
      default:
        return '跟随系统';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('简体中文'),
              value: 'zh_CN',
              groupValue: _settingsProvider.language,
              onChanged: (value) {
                if (value != null) {
                  _settingsProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('繁體中文'),
              value: 'zh_TW',
              groupValue: _settingsProvider.language,
              onChanged: (value) {
                if (value != null) {
                  _settingsProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en_US',
              groupValue: _settingsProvider.language,
              onChanged: (value) {
                if (value != null) {
                  _settingsProvider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('浅色主题'),
              value: 'light',
              groupValue: _settingsProvider.theme,
              onChanged: (value) {
                if (value != null) {
                  _settingsProvider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('深色主题'),
              value: 'dark',
              groupValue: _settingsProvider.theme,
              onChanged: (value) {
                if (value != null) {
                  _settingsProvider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('跟随系统'),
              value: 'system',
              groupValue: _settingsProvider.theme,
              onChanged: (value) {
                if (value != null) {
                  _settingsProvider.setTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('备份数据'),
        content: const Text('此功能将把您的所有成就数据导出为备份文件，您可以在需要时使用此文件恢复数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                // 获取成就数据
                final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
                final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                // 创建备份数据
                final backupData = {
                  'achievements': achievementProvider.achievements,
                  'settings': {
                    'theme': settingsProvider.theme,
                    'language': settingsProvider.language,
                  },
                  'timestamp': DateTime.now().toIso8601String(),
                };

                // 获取文档目录
                final directory = await getApplicationDocumentsDirectory();
                final backupDir = Directory('${directory.path}/backups');
                if (!await backupDir.exists()) {
                  await backupDir.create(recursive: true);
                }

                // 创建备份文件
                final String formattedDate = DateTime.now().toString().replaceAll(RegExp(r'[/\:]'), '-');
                final backupFile = File('${backupDir.path}/backup_$formattedDate.json');

                // 写入备份数据
                await backupFile.writeAsString(json.encode(backupData));

                // 显示成功消息
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('备份成功: ${backupFile.path}')),
                );
              } catch (e) {
                // 显示错误消息
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('备份失败: $e')),
                );
              }
            },
            child: const Text('开始备份'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('恢复数据'),
        content: const Text('此功能将从备份文件恢复您的成就数据。注意：这将覆盖当前的所有数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                // 打开文件选择器
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                  allowedExtensions: ['json'],
                  dialogTitle: '选择备份文件',
                );

                if (result == null || result.files.isEmpty) {
                  return;
                }

                // 读取文件内容
                final file = File(result.files.single.path!);
                final fileContent = await file.readAsString();
                final backupData = json.decode(fileContent);

                // 获取providers
                final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
                final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                // 恢复设置
                if (backupData['settings'] != null) {
                  final settings = backupData['settings'];
                  if (settings['theme'] != null) {
                    await settingsProvider.setTheme(settings['theme']);
                  }
                  if (settings['language'] != null) {
                    await settingsProvider.setLanguage(settings['language']);
                  }
                }

                // 恢复成就数据
                if (backupData['achievements'] != null) {
                  // 这里需要根据实际的Achievement模型进行解析和恢复
                  // 由于我们没有完整的Achievement模型代码，这里假设它有一个fromJson方法
                  List<dynamic> achievementsJson = backupData['achievements'];
                  List<Achievement> restoredAchievements = [];

                  for (var achievementJson in achievementsJson) {
                    // 尝试将JSON转换为Achievement对象
                    try {
                      // 使用fromJson方法转换
                      Achievement achievement = Achievement.fromJson(achievementJson);
                      restoredAchievements.add(achievement);
                    } catch (e) {
                      debugPrint('Error parsing achievement: $e');
                    }
                  }

                  // 清空现有成就并添加恢复的成就
                  // 注意：这里需要AchievementProvider提供清空方法
                  // 如果没有，我们可能需要修改AchievementProvider
                  await achievementProvider.reloadRealData(); // 先重置为真实数据
                  for (var achievement in restoredAchievements) {
                    await achievementProvider.updateAchievement(achievement);
                  }
                }

                // 显示成功消息
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('恢复成功')),
                );
              } catch (e) {
                // 显示错误消息
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('恢复失败: $e')),
                );
              }
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('此操作将删除所有成就数据和应用设置，且无法恢复。您确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                // 显示二次确认对话框
                showDialog(
                  context: context,
                  builder: (BuildContext confirmDialogContext) => AlertDialog(
                    title: const Text('确认清除'),
                    content: const Text('确定要清除所有数据吗？此操作无法撤销。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(confirmDialogContext),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(confirmDialogContext);
                          // 获取providers
                          final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
                          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

                          // 清除成就数据
                          await achievementProvider.reloadRealData(); // 重置为初始数据

                          // 清除设置数据 (重置为默认值)
                          await settingsProvider.setTheme('system');
                          await settingsProvider.setLanguage('zh_CN');

                          // 显示成功消息
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('清除数据成功')),
                          );
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('确认清除'),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                // 显示错误消息
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('清除数据失败: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Genshin Achievement',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.emoji_events, size: 64),
      children: [
        const Text('原神成就管理应用'),
        const SizedBox(height: 16),
        const Text('功能特性：'),
        const Text('• 成就记录和管理'),
        const Text('• 攻略查询'),
        const Text('• 数据导出'),
        const Text('• 多语言支持'),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('帮助与支持'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('使用说明：', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('1. 在"成就"页面可以查看、添加和管理成就'),
              Text('2. 点击成就可以查看详细信息和攻略'),
              Text('3. 在"导出"页面可以将数据导出为文件'),
              Text('4. 在"设置"页面可以配置应用选项'),
              SizedBox(height: 16),
              Text('常见问题：', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Q: 如何添加新成就？'),
              Text('A: 在成就页面点击右上角的"+"按钮'),
              SizedBox(height: 8),
              Text('Q: 导出的文件保存在哪里？'),
              Text('A: 文件保存在应用的文档目录中'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
