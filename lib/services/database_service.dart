import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/achievement.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'geshin_achievement.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        reward TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedDate TEXT,
        guide TEXT,
        tags TEXT,
        primogems INTEGER DEFAULT 0,
        version TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        totalCount INTEGER NOT NULL DEFAULT 0,
        completedCount INTEGER NOT NULL DEFAULT 0,
        iconPath TEXT DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 插入默认设置
    await db.insert('settings', {'key': 'language', 'value': 'zh_CN'});
    await db.insert('settings', {'key': 'theme', 'value': 'system'});
  }

  // 成就相关操作
  Future<int> insertAchievement(Achievement achievement) async {
    final db = await database;
    return await db.insert('achievements', {
      'id': achievement.id,
      'name': achievement.name,
      'description': achievement.description,
      'category': achievement.category,
      'reward': achievement.reward,
      'isCompleted': achievement.isCompleted ? 1 : 0,
      'completedDate': achievement.completedDate?.toIso8601String(),
      'guide': achievement.guide,
      'tags': achievement.tags.join(','),
      'primogems': achievement.primogems,
      'version': achievement.version,
    });
  }

  Future<List<Achievement>> getAllAchievements() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('achievements');
    
    return List.generate(maps.length, (i) {
      return Achievement(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        reward: maps[i]['reward'],
        isCompleted: maps[i]['isCompleted'] == 1,
        completedDate: maps[i]['completedDate'] != null 
            ? DateTime.parse(maps[i]['completedDate']) 
            : null,
        guide: maps[i]['guide'],
        tags: maps[i]['tags']?.split(',') ?? [],
        primogems: maps[i]['primogems'] ?? 0,
        version: maps[i]['version'] ?? '',
      );
    });
  }

  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'achievements',
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return List.generate(maps.length, (i) {
      return Achievement(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        reward: maps[i]['reward'],
        isCompleted: maps[i]['isCompleted'] == 1,
        completedDate: maps[i]['completedDate'] != null 
            ? DateTime.parse(maps[i]['completedDate']) 
            : null,
        guide: maps[i]['guide'],
        tags: maps[i]['tags']?.split(',') ?? [],
        primogems: maps[i]['primogems'] ?? 0,
        version: maps[i]['version'] ?? '',
      );
    });
  }

  Future<int> updateAchievement(Achievement achievement) async {
    final db = await database;
    return await db.update(
      'achievements',
      {
        'name': achievement.name,
        'description': achievement.description,
        'category': achievement.category,
        'reward': achievement.reward,
        'isCompleted': achievement.isCompleted ? 1 : 0,
        'completedDate': achievement.completedDate?.toIso8601String(),
        'guide': achievement.guide,
        'tags': achievement.tags.join(','),
        'primogems': achievement.primogems,
        'version': achievement.version,
      },
      where: 'id = ?',
      whereArgs: [achievement.id],
    );
  }

  Future<int> deleteAchievement(int id) async {
    final db = await database;
    return await db.delete(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 设置相关操作
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (maps.isNotEmpty) {
      return maps.first['value'];
    }
    return null;
  }

  Future<int> setSetting(String key, String value) async {
    final db = await database;
    return await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 统计相关操作
  Future<Map<String, int>> getAchievementStats() async {
    final db = await database;
    final totalResult = await db.rawQuery('SELECT COUNT(*) as total FROM achievements');
    final completedResult = await db.rawQuery('SELECT COUNT(*) as completed FROM achievements WHERE isCompleted = 1');
    
    return {
      'total': totalResult.first['total'] as int,
      'completed': completedResult.first['completed'] as int,
    };
  }

  // 清空所有成就数据
  Future<void> clearAllAchievements() async {
    final db = await database;
    await db.delete('achievements');
  }

  // 备份数据到文件
  Future<String?> backupData() async {
    try {
      final achievements = await getAllAchievements();
      final settings = await _getAllSettings();

      final backupData = {
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'settings': settings,
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final String timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
      final file = File('${backupDir.path}/backup_$timestamp.json');
      await file.writeAsString(jsonEncode(backupData));

      return file.path;
    } catch (e) {
      print('Backup failed: $e');
      return null;
    }
  }

  // 从文件恢复数据
  Future<bool> restoreData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final String content = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(content);

      final db = await database;
      await db.transaction((txn) async {
        // 清空现有数据
        await txn.delete('achievements');
        await txn.delete('settings');

        // 恢复成就数据
        final List<dynamic> achievements = backupData['achievements'] ?? [];
        for (final achievementData in achievements) {
          await txn.insert('achievements', achievementData);
        }

        // 恢复设置数据
        final Map<String, dynamic> settings = backupData['settings'] ?? {};
        for (final key in settings.keys) {
          await txn.insert('settings', {'key': key, 'value': settings[key]});
        }
      });

      return true;
    } catch (e) {
      print('Restore failed: $e');
      return false;
    }
  }

  // 获取所有设置
  Future<Map<String, String>> _getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');

    final Map<String, String> settings = {};
    for (final map in maps) {
      settings[map['key']] = map['value'];
    }
    return settings;
  }

  // 清除所有数据（包括成就和设置）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('achievements');
    await db.delete('settings');
    // 重置默认设置
    await db.insert('settings', {'key': 'language', 'value': 'zh_CN'});
    await db.insert('settings', {'key': 'theme', 'value': 'system'});
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}