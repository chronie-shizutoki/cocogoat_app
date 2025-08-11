import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../services/export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ExportService _exportService = ExportService();
  bool _completedOnly = false;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导出'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          final stats = provider.getStats();
          
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 导出统计
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '导出统计',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(
                                    '总成就',
                                    'stats[\'total\'].toString()',
                                    Icons.emoji_events,
                                    Colors.blue,
                                  ),
                                  _buildStatColumn(
                                    '已完成',
                                    'stats[\'completed\'].toString()',
                                    Icons.check_circle,
                                    Colors.green,
                                  ),
                                  _buildStatColumn(
                                    '原石',
                                    'stats[\'primogems\'].toString()',
                                    Icons.diamond,
                                    Colors.amber,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 导出选项
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '导出选项',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              
                              // 格式选择
                              Text(
                                '导出格式',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.verified, color: Colors.green, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'UIAF v1.1 (推荐)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '统一可交换成就标准，与其他原神工具完全兼容',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              // 内容选择
                              Text(
                                '导出内容',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              SwitchListTile(
                                title: Text('仅导出已完成的成就'),
                                subtitle: Text(
                                  '_completedOnly' 
                                      ? '将导出已完成的成就'
                                      : '将导出全部成就',
                                ),
                                value: '_completedOnly',
                                onChanged: (value) {
                                  setState(() {
                                    '_completedOnly' = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 格式说明
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'UIAF标准说明',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'UIAF (统一可交换成就标准) 是由多个原神工具开发团队共同制定的标准格式，确保成就数据在不同应用间的完全兼容性。',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '支持的应用包括：',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '• Geshin Achievement\n• Snap.Genshin\n• Genshin Achievement Toy\n• Genshin Achievement Export',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 导出按钮
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: '_isExporting || stats[\'total\'] == 0'
                                ? null
                                : () => '_exportData(context, provider)',
                            icon: '_isExporting' 
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(Icons.file_download),
                            label: Text('_isExporting ? \'导出中...\' : \'开始导出\''),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        const Icon(Icons.emoji_events, color: Colors.blue, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, AchievementProvider provider) async {
    final localContext = context;

    setState(() {
      _isExporting = true;
    });

    try {
      final achievements = _completedOnly 
          ? provider.achievements.where((a) => a.isCompleted).toList()
          : provider.achievements;

      final filePath = await _exportService.exportAndSaveUIAF(
        achievements,
        completedOnly: _completedOnly,
      );

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            const SnackBar(
              content: Text('导出成功！文件已保存到: filePath'),
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: '确定',
                onPressed: () {},
              ),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            const SnackBar(
              content: Text('导出失败: e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
