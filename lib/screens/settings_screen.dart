import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  String _currentLanguage = 'zh_CN';
  String _currentTheme = 'system';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final language = await _databaseService.getSetting('language') ?? 'zh_CN';
      final theme = await _databaseService.getSetting('theme') ?? 'system';
      
      setState(() {
        _currentLanguage = language;
        _currentTheme = theme;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, String value) async {
    try {
      await _databaseService.setSetting(key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存设置失败: $e')),
        );
      }
    }
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
            subtitle: Text(_getLanguageDisplayName(_currentLanguage)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('主题'),
            subtitle: Text(_getThemeDisplayName(_currentTheme)),
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
            subtitle: const Text('Geshin Achievement v1.0.0'),
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
              groupValue: _currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentLanguage = value;
                  });
                  _saveSetting('language', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('繁體中文'),
              value: 'zh_TW',
              groupValue: _currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentLanguage = value;
                  });
                  _saveSetting('language', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en_US',
              groupValue: _currentLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentLanguage = value;
                  });
                  _saveSetting('language', value);
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
              groupValue: _currentTheme,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentTheme = value;
                  });
                  _saveSetting('theme', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('深色主题'),
              value: 'dark',
              groupValue: _currentTheme,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentTheme = value;
                  });
                  _saveSetting('theme', value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('跟随系统'),
              value: 'system',
              groupValue: _currentTheme,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentTheme = value;
                  });
                  _saveSetting('theme', value);
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
                setState(() {
                  _isLoading = true;
                });
                final String? backupPath = await _databaseService.backupData();
                setState(() {
                  _isLoading = false;
                });
                if (mounted) {
                  if (backupPath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('备份成功！文件路径: $backupPath')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('备份失败，请重试')),
                    );
                  }
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('备份失败: $e')),
                  );
                }
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
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result != null && result.files.isNotEmpty) {
                  setState(() {
                    _isLoading = true;
                  });
                  final String filePath = result.files.single.path!;
                  final bool success = await _databaseService.restoreData(filePath);
                  setState(() {
                    _isLoading = false;
                  });
                  if (mounted) {
                    if (success) {
                      // 重新加载设置
                      await _loadSettings();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('恢复成功！')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('恢复失败，请检查文件格式')),
                      );
                    }
                  }
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('恢复失败: $e')),
                  );
                }
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
                setState(() {
                  _isLoading = true;
                });
                await _databaseService.clearAllData();
                // 重新加载设置前检查mounted状态
                if (mounted) {
                  await _loadSettings();
                  setState(() {
                    _isLoading = false;
                  });
                  // 重新加载设置后再次检查mounted状态
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据已清除！')),
                    );
                  }
                } else {
                  setState(() {
                    _isLoading = false;
                  });
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('清除失败: $e')),
                  );
                }
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
      applicationName: 'Geshin Achievement',
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
