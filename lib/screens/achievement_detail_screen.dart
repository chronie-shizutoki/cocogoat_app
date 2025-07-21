import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';

class AchievementDetailScreen extends StatelessWidget {
  final Achievement achievement;

  const AchievementDetailScreen({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 完成状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      achievement.isCompleted 
                          ? Icons.check_circle 
                          : Icons.pending,
                      size: 48,
                      color: achievement.isCompleted 
                          ? Colors.green 
                          : Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.isCompleted ? '已完成' : '未完成',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (achievement.completedDate != null)
                            Text(
                              '完成时间: ${_formatDate(achievement.completedDate!)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                    Consumer<AchievementProvider>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          onPressed: () {
                            provider.toggleAchievementCompletion(achievement.id);
                            Navigator.pop(context);
                          },
                          child: Text(
                            achievement.isCompleted ? '标记未完成' : '标记完成',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 基本信息
            _buildInfoSection(
              context,
              '基本信息',
              [
                _buildInfoRow('名称', achievement.name),
                _buildInfoRow('描述', achievement.description),
                _buildInfoRow('分类', achievement.category),
                _buildInfoRow('奖励', achievement.reward),
                if (achievement.primogems > 0)
                  _buildInfoRow('原石', '${achievement.primogems}'),
                if (achievement.version.isNotEmpty)
                  _buildInfoRow('版本', achievement.version),
              ],
            ),

            // 标签
            if (achievement.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                context,
                '标签',
                [
                  Wrap(
                    spacing: 8,
                    children: achievement.tags.map((tag) => Chip(
                      label: Text(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
              ),
            ],

            // 攻略
            if (achievement.guide != null && achievement.guide!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoSection(
                context,
                '完成攻略',
                [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      achievement.guide!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: achievement.name);
    final descriptionController = TextEditingController(text: achievement.description);
    final categoryController = TextEditingController(text: achievement.category);
    final rewardController = TextEditingController(text: achievement.reward);
    final primogemsController = TextEditingController(text: achievement.primogems.toString());
    final guideController = TextEditingController(text: achievement.guide ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑成就'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '成就名称'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '成就描述'),
                maxLines: 2,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: '分类'),
              ),
              TextField(
                controller: rewardController,
                decoration: const InputDecoration(labelText: '奖励'),
              ),
              TextField(
                controller: primogemsController,
                decoration: const InputDecoration(labelText: '原石数量'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: guideController,
                decoration: const InputDecoration(labelText: '完成攻略'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final updatedAchievement = achievement.copyWith(
                name: nameController.text,
                description: descriptionController.text,
                category: categoryController.text,
                reward: rewardController.text,
                primogems: int.tryParse(primogemsController.text) ?? 0,
                guide: guideController.text.isEmpty ? null : guideController.text,
              );
              
              context.read<AchievementProvider>().updateAchievement(updatedAchievement);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

