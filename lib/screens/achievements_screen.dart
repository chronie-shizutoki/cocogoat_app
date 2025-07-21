import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';
import 'achievement_detail_screen.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成就'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAchievementDialog(context),
          ),
        ],
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 搜索和筛选栏
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 搜索框
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索成就...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.searchAchievements('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: provider.searchAchievements,
                    ),
                    const SizedBox(height: 8),
                    
                    // 筛选选项
                    Row(
                      children: [
                        // 分类筛选
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: provider.selectedCategory,
                            decoration: const InputDecoration(
                              labelText: '分类',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: 'all',
                                child: Text('全部分类'),
                              ),
                              ...provider.getCategories().map((category) =>
                                DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                provider.filterByCategory(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // 完成状态筛选
                        FilterChip(
                          label: const Text('仅已完成'),
                          selected: provider.showCompletedOnly,
                          onSelected: (selected) => provider.toggleShowCompletedOnly(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 成就列表
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.achievements.isEmpty
                        ? const Center(
                            child: Text('暂无成就数据'),
                          )
                        : ListView.builder(
                            itemCount: provider.achievements.length,
                            itemBuilder: (context, index) {
                              final achievement = provider.achievements[index];
                              return _buildAchievementTile(context, achievement, provider);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementTile(
    BuildContext context,
    Achievement achievement,
    AchievementProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: achievement.isCompleted 
              ? Colors.green 
              : Colors.grey,
          child: Icon(
            achievement.isCompleted 
                ? Icons.check 
                : Icons.emoji_events,
            color: Colors.white,
          ),
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            decoration: achievement.isCompleted 
                ? TextDecoration.lineThrough 
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    achievement.category,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                if (achievement.primogems > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, size: 16, color: Colors.amber),
                      Text('${achievement.primogems}'),
                    ],
                  ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            achievement.isCompleted 
                ? Icons.check_box 
                : Icons.check_box_outline_blank,
          ),
          onPressed: () {
            provider.toggleAchievementCompletion(achievement.id);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AchievementDetailScreen(achievement: achievement),
            ),
          );
        },
      ),
    );
  }

  void _showAddAchievementDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final rewardController = TextEditingController();
    final primogemsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加成就'),
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
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                final achievement = Achievement(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                  reward: rewardController.text,
                  primogems: int.tryParse(primogemsController.text) ?? 0,
                );
                
                context.read<AchievementProvider>().addAchievement(achievement);
                Navigator.pop(context);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

