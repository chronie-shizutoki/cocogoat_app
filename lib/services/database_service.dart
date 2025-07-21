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
    String path = join(documentsDirectory.path, 'cocogoat.db');
    
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

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}