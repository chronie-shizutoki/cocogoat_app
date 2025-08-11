import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/achievement.dart';

class AchievementDataService {
  // GitLab仓库基础URL
  static const String _gitLabBaseUrl = 'https://gitlab.com/Dimbreath/AnimeGameData/-/raw/13be4fd7343fe4cee8fa0096fe854b1c5b01b124';

  // 缓存数据
  static Map<String, String>? _textMap;
  static List<Map<String, dynamic>>? _achievementData;
  static Map<int, Map<String, dynamic>>? _achievementGoalData;

  // 网络请求客户端
  static const http.Client _httpClient = http.Client();

  // 加载文本映射
  static Future<void> loadTextMap() async {
    if (_textMap != null) return;

    try {
      // 从GitLab仓库加载中文文本映射
      final url = '$_gitLabBaseUrl/TextMap/TextMapCHS.json';
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _textMap = data.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('Failed to load text map: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load text map: $e');
      _textMap = {};
    }
  }

  // 加载成就数据
  static Future<void> loadAchievementData() async {
    if (_achievementData != null) return;

    try {
      // 从GitLab仓库加载成就配置数据
      final url = '$_gitLabBaseUrl/ExcelBinOutput/AchievementExcelConfigData.json';
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _achievementData = data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load achievement data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load achievement data: $e');
      _achievementData = [];
    }
  }

  // 加载成就目标数据
  static Future<void> loadAchievementGoalData() async {
    if (_achievementGoalData != null) return;

    try {
      // 从GitLab仓库加载成就目标数据
      final url = '$_gitLabBaseUrl/ExcelBinOutput/AchievementGoalExcelConfigData.json';
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _achievementGoalData = {};
        for (final item in data) {
          final goalId = item['id'] as int;
          _achievementGoalData![goalId] = item;
        }
      } else {
        throw Exception('Failed to load achievement goal data: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to load achievement goal data: $e');
      _achievementGoalData = {};
    }
  }

  // 根据hash获取文本
  static String getTextByHash(int hash) {
    if (_textMap == null) return '';
    return _textMap![hash.toString()] ?? '';
  }

  // 获取成就分类名称
  static String getCategoryName(int goalId) {
    if (_achievementGoalData == null) return '未知分类';
    
    final goalData = _achievementGoalData![goalId];
    if (goalData == null) return '未知分类';
    
    final nameHash = goalData['nameTextMapHash'] as int?;
    if (nameHash == null) return '未知分类';
    
    return getTextByHash(nameHash);
  }

  // 获取成就奖励信息
  static int getPrimogems(int finishRewardId) {
    // 根据奖励ID计算原石数量
    // 这里简化处理，实际应该从RewardExcelConfigData中获取
    if (finishRewardId >= 800001 && finishRewardId <= 800100) {
      return 5; // 大部分成就奖励5原石
    } else if (finishRewardId >= 800101 && finishRewardId <= 800200) {
      return 10; // 一些成就奖励10原石
    } else if (finishRewardId >= 800201 && finishRewardId <= 800300) {
      return 20; // 困难成就奖励20原石
    }
    return 5; // 默认5原石
  }

  // 解析真实成就数据
  static Future<List<Achievement>> parseRealAchievements() async {
    await loadTextMap();
    await loadAchievementData();
    await loadAchievementGoalData();

    final List<Achievement> achievements = [];

    for (final achievementData in _achievementData!) {
      try {
        final id = achievementData['id'] as int;
        final titleHash = achievementData['titleTextMapHash'] as int;
        final descHash = achievementData['descTextMapHash'] as int;
        final goalId = achievementData['goalId'] as int;
        final finishRewardId = achievementData['finishRewardId'] as int;
        final isShow = achievementData['isShow'] as String;
        final isDisuse = achievementData['isDisuse'] as bool;

        // 跳过隐藏或废弃的成就
        if (isShow != 'SHOWTYPE_SHOW' || isDisuse) {
          continue;
        }

        final name = getTextByHash(titleHash);
        final description = getTextByHash(descHash);
        final category = getCategoryName(goalId);
        final primogems = getPrimogems(finishRewardId);

        // 跳过没有名称的成就
        if (name.isEmpty) {
          continue;
        }

        final achievement = Achievement(
          id: id,
          name: name,
          description: description,
          category: category,
          reward: '原石×$primogems',
          primogems: primogems,
          isCompleted: false,
          tags: _generateTags(category, name, description),
          version: _getVersionFromId(id),
          guide: _generateGuide(achievementData),
        );

        achievements.add(achievement);
      } catch (e) {
        debugPrint('Error parsing achievement ${achievementData['id']}: $e');
        continue;
      }
    }

    // 按ID排序
    achievements.sort((a, b) => a.id.compareTo(b.id));
    
    return achievements;
  }

  // 生成标签
  static List<String> _generateTags(String category, String name, String description) {
    final tags = <String>[category];
    
    // 根据名称和描述添加标签
    if (name.contains('元素') || description.contains('元素')) {
      tags.add('元素');
    }
    if (name.contains('战斗') || description.contains('战斗') || description.contains('击败')) {
      tags.add('战斗');
    }
    if (name.contains('探索') || description.contains('探索') || description.contains('发现')) {
      tags.add('探索');
    }
    if (name.contains('收集') || description.contains('收集') || description.contains('获得')) {
      tags.add('收集');
    }
    if (name.contains('料理') || description.contains('料理') || description.contains('烹饪')) {
      tags.add('料理');
    }
    if (name.contains('深境螺旋') || description.contains('深境螺旋')) {
      tags.add('深境螺旋');
    }
    
    return tags.toSet().toList(); // 去重
  }

  // 根据ID推断版本
  static String _getVersionFromId(int id) {
    if (id >= 80001 && id <= 80500) {
      return '1.0';
    } else if (id >= 80501 && id <= 81000) {
      return '1.1';
    } else if (id >= 81001 && id <= 81500) {
      return '1.2';
    } else if (id >= 81501 && id <= 82000) {
      return '1.3';
    } else if (id >= 82001 && id <= 82500) {
      return '1.4';
    } else if (id >= 82501 && id <= 83000) {
      return '1.5';
    } else if (id >= 83001 && id <= 83500) {
      return '1.6';
    } else if (id >= 83501 && id <= 84000) {
      return '2.0';
    } else if (id >= 84001 && id <= 84500) {
      return '2.1';
    } else if (id >= 84501 && id <= 85000) {
      return '2.2';
    } else if (id >= 85001 && id <= 85500) {
      return '2.3';
    } else if (id >= 85501 && id <= 86000) {
      return '2.4';
    } else if (id >= 86001 && id <= 86500) {
      return '2.5';
    } else if (id >= 86501 && id <= 87000) {
      return '2.6';
    } else if (id >= 87001 && id <= 87500) {
      return '2.7';
    } else if (id >= 87501 && id <= 88000) {
      return '2.8';
    } else if (id >= 88001 && id <= 88500) {
      return '3.0';
    } else if (id >= 88501 && id <= 89000) {
      return '3.1';
    } else if (id >= 89001 && id <= 89500) {
      return '3.2';
    } else if (id >= 89501 && id <= 90000) {
      return '3.3';
    } else if (id >= 90001 && id <= 90500) {
      return '3.4';
    } else if (id >= 90501 && id <= 91000) {
      return '3.5';
    } else if (id >= 91001 && id <= 91500) {
      return '3.6';
    } else if (id >= 91501 && id <= 92000) {
      return '3.7';
    } else if (id >= 92001 && id <= 92500) {
      return '3.8';
    } else if (id >= 92501 && id <= 93000) {
      return '4.0';
    } else if (id >= 93001 && id <= 93500) {
      return '4.1';
    } else if (id >= 93501 && id <= 94000) {
      return '4.2';
    } else if (id >= 94001 && id <= 94500) {
      return '4.3';
    } else if (id >= 94501 && id <= 95000) {
      return '4.4';
    } else if (id >= 95001 && id <= 95500) {
      return '4.5';
    } else if (id >= 95501 && id <= 96000) {
      return '4.6';
    } else if (id >= 96001 && id <= 96500) {
      return '4.7';
    } else if (id >= 96501 && id <= 97000) {
      return '4.8';
    } else if (id >= 97001 && id <= 97500) {
      return '5.0';
    } else if (id >= 97501 && id <= 98000) {
      return '5.1';
    } else if (id >= 98001 && id <= 98500) {
      return '5.2';
    } else if (id >= 98501 && id <= 99000) {
      return '5.3';
    } else if (id >= 99001 && id <= 99500) {
      return '5.4';
    } else if (id >= 99501 && id <= 100000) {
      return '5.5';
    }
    return '未知';
  }

  // 生成攻略提示
  static String? _generateGuide(Map<String, dynamic> achievementData) {
    final triggerConfig = achievementData['triggerConfig'] as Map<String, dynamic>?;
    if (triggerConfig == null) return null;

    final triggerType = triggerConfig['triggerType'] as String?;

    switch (triggerType) {
      case 'TRIGGER_ELEMENT_TYPE_CHANGE':
        return '使用元素技能改变角色元素类型';
      case 'TRIGGER_COLLECT_SET_OF_READINGS':
        return '收集指定的书籍或文献';
      case 'TRIGGER_FORGE_WEAPON':
        return '在铁匠铺锻造武器';
      case 'TRIGGER_UNLOCK_RECIPE':
        return '解锁料理配方';
      case 'TRIGGER_GADGET_INTERACTABLE':
        return '与特定的机关或物品互动';
      case 'TRIGGER_FINISH_QUEST':
        return '完成指定的任务';
      case 'TRIGGER_KILL_MONSTER':
        return '击败指定的怪物';
      case 'TRIGGER_OPEN_CHEST':
        return '开启宝箱';
      case 'TRIGGER_OBTAIN_MATERIAL':
        return '获得指定的材料';
      case 'TRIGGER_LEVEL_UP_AVATAR':
        return '提升角色等级';
      case 'TRIGGER_LEVEL_UP_WEAPON':
        return '提升武器等级';
      case 'TRIGGER_UPGRADE_ARTIFACT':
        return '强化圣遗物';
      case 'TRIGGER_FINISH_DOMAIN':
        return '完成秘境挑战';
      case 'TRIGGER_ABYSS_FLOOR':
        return '通过深境螺旋指定层数';
      default:
        return null;
    }
  }

  // 获取统计信息
  static Future<Map<String, int>> getStatistics() async {
    final achievements = await parseRealAchievements();
    
    final totalCount = achievements.length;
    final completedCount = achievements.where((a) => a.isCompleted).length;
    final totalPrimogems = achievements.fold(0, (sum, a) => sum + a.primogems);
    final earnedPrimogems = achievements
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.primogems);

    return {
      'total': totalCount,
      'completed': completedCount,
      'remaining': totalCount - completedCount,
      'totalPrimogems': totalPrimogems,
      'earnedPrimogems': earnedPrimogems,
      'remainingPrimogems': totalPrimogems - earnedPrimogems,
    };
  }
}

