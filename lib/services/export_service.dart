import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/achievement.dart';

class ExportService {
  static const String _uiafVersion = 'v1.1';
  static const String _appName = 'Geshin Achievement';
  static const String _appVersion = '1.0.0';

  // 导出为UIAF v1.1标准格式
  Future<String> exportToUIAF(List<Achievement> achievements, {bool completedOnly = false}) async {
    final filteredAchievements = completedOnly 
        ? achievements.where((a) => a.isCompleted).toList()
        : achievements;

    final exportData = {
      'info': {
        'export_app': _appName,
        'export_app_version': _appVersion,
        'uiaf_version': _uiafVersion,
        'export_timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000, // UNIX时间戳（秒）
      },
      'list': filteredAchievements.map((achievement) => {
        'id': achievement.id,
        'current': achievement.isCompleted ? 1 : 0, // 简化处理，完成为1，未完成为0
        'status': _getAchievementStatus(achievement),
        'timestamp': _getTimestamp(achievement),
      }).toList(),
    };

    return jsonEncode(exportData);
  }

  // 获取成就状态
  int _getAchievementStatus(Achievement achievement) {
    if (achievement.isCompleted) {
      return 3; // ACHIEVEMENT_POINT_TAKEN - 已完成并领取奖励
    } else {
      return 1; // ACHIEVEMENT_UNFINISHED - 未完成
    }
  }

  // 获取时间戳
  int _getTimestamp(Achievement achievement) {
    if (achievement.isCompleted && achievement.completedDate != null) {
      return achievement.completedDate!.millisecondsSinceEpoch ~/ 1000;
    } else {
      // 对于未完成的成就，使用UIAF标准规定的时间：9999-12-31 23:59:59
      return 253402271999; // 对应 9999-12-31 23:59:59 的UNIX时间戳
    }
  }

  // 保存文件到下载文件夹
  Future<String> saveToFile(String content, String fileName) async {
    try {
      Directory directory;

      if (Platform.isAndroid) {
        // 对于Android，使用下载文件夹
        directory = Directory('/storage/emulated/0/Download');
        // 确保目录存在
        if (!await directory.exists()) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        // 对于iOS，应用无法直接访问下载文件夹
        // 我们仍然使用文档目录，但在返回路径时提示用户
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows) {
        // 对于Windows，使用下载文件夹
        final String? downloadsPath = await _getWindowsDownloadsPath();
        if (downloadsPath != null) {
          directory = Directory(downloadsPath);
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isMacOS) {
        // 对于macOS，使用下载文件夹
        final String homePath = Platform.environment['HOME'] ?? '';
        if (homePath.isNotEmpty) {
          directory = Directory('$homePath/Downloads');
        } else {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // 其他平台，使用文档目录
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }

  // 获取Windows下载文件夹路径
  Future<String?> _getWindowsDownloadsPath() async {
    try {
      final String? userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return '$userProfile\\Downloads';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 导出并保存UIAF文件
  Future<String> exportAndSaveUIAF(
    List<Achievement> achievements, {
    bool completedOnly = false,
    String? customFileName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = customFileName ?? 
        'geshin_achievement_achievements_uiaf_$timestamp.json';

    final content = await exportToUIAF(achievements, completedOnly: completedOnly);
    return await saveToFile(content, fileName);
  }

  // 从UIAF文件导入
  Future<List<Achievement>> importFromUIAF(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content);

      // 验证UIAF格式
      if (!data.containsKey('info') || !data.containsKey('list')) {
        throw Exception('Invalid UIAF format: missing required fields');
      }

      final info = data['info'];
      if (!info.containsKey('uiaf_version')) {
        throw Exception('Invalid UIAF format: missing uiaf_version');
      }

      final version = info['uiaf_version'] as String;
      if (version != 'v1.0' && version != 'v1.1') {
        throw Exception('Unsupported UIAF version: $version');
      }

      return _parseUIAFAchievements(data['list']);
    } catch (e) {
      throw Exception('Failed to import UIAF file: $e');
    }
  }

  List<Achievement> _parseUIAFAchievements(List<dynamic> achievementsData) {
    return achievementsData.map((achievementData) {
      final id = achievementData['id'] as int;
      final status = achievementData['status'] as int;
      final timestamp = achievementData['timestamp'] as int;

      // 根据status判断完成状态
      final isCompleted = status == 2 || status == 3; // FINISHED 或 POINT_TAKEN
      
      // 处理时间戳
      DateTime? completedDate;
      if (isCompleted && timestamp != 253402271999) {
        completedDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }

      return Achievement(
        id: id,
        name: '成就 $id', // 导入时使用默认名称，实际应用中需要从成就数据库匹配
        description: '从UIAF文件导入的成就',
        category: '导入',
        reward: '未知',
        isCompleted: isCompleted,
        completedDate: completedDate,
        primogems: 0, // UIAF格式中没有原石信息
      );
    }).toList();
  }

  // 验证UIAF文件格式
  Future<bool> validateUIAFFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content);

      // 基本结构验证
      if (!data.containsKey('info') || !data.containsKey('list')) {
        return false;
      }

      final info = data['info'];
      if (!info.containsKey('export_app') || !info.containsKey('uiaf_version')) {
        return false;
      }

      final list = data['list'] as List;
      for (final item in list) {
        if (!item.containsKey('id') || 
            !item.containsKey('current') || 
            !item.containsKey('status') || 
            !item.containsKey('timestamp')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // 获取支持的导出格式
  List<String> getSupportedFormats() {
    return ['UIAF v1.1'];
  }
}

