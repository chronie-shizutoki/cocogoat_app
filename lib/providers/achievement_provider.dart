import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../services/achievement_data_service.dart';

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [];
  List<Achievement> _filteredAchievements = [];
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _showCompletedOnly = false;
  bool _isLoading = false;
  late SharedPreferences _prefs;

  List<Achievement> get achievements => _filteredAchievements;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showCompletedOnly => _showCompletedOnly;

  // 初始化 SharedPreferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 加载成就数据
  Future<void> loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _initPrefs();
      
      // 首先尝试从本地存储加载
      final achievementsJson = _prefs.getStringList('achievements');
      
      if (achievementsJson == null || achievementsJson.isEmpty) {
        // 如果本地存储为空，从真实数据源加载
        debugPrint('Loading achievements from real data...');
        final realAchievements = await AchievementDataService.parseRealAchievements();
        
        // 保存到本地存储
        await _saveAchievements(realAchievements);
        
        _achievements = realAchievements;
        debugPrint('Loaded ${realAchievements.length} achievements from real data');
      } else {
        // 从本地存储解析成就数据
        _achievements = achievementsJson
            .map((json) => Achievement.fromJson(jsonDecode(json))) 
            .toList();
        debugPrint('Loaded ${_achievements.length} achievements from local storage');
      }

      _applyFilters();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      _achievements = [];
      _filteredAchievements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 保存成就数据到本地存储
  Future<void> _saveAchievements(List<Achievement> achievements) async {
    final jsonList = achievements
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();
    await _prefs.setStringList('achievements', jsonList);
  }

  // 重新加载真实数据
  Future<void> reloadRealData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _initPrefs();
      
      // 重新加载真实数据
      final realAchievements = await AchievementDataService.parseRealAchievements();
      
      // 保存到本地存储
      await _saveAchievements(realAchievements);
      
      _achievements = realAchievements;
      _applyFilters();
      
      debugPrint('Reloaded ${realAchievements.length} achievements from real data');
    } catch (e) {
      debugPrint('Error reloading real data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加成就
  Future<void> addAchievement(Achievement achievement) async {
    try {
      await _initPrefs();
      
      _achievements.add(achievement);
      await _saveAchievements(_achievements);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding achievement: $e');
    }
  }

  // 更新成就
  Future<void> updateAchievement(Achievement achievement) async {
    try {
      await _initPrefs();
      
      final index = _achievements.indexWhere((a) => a.id == achievement.id);
      if (index != -1) {
        _achievements[index] = achievement;
        await _saveAchievements(_achievements);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating achievement: $e');
    }
  }

  // 删除成就
  Future<void> deleteAchievement(int id) async {
    try {
      await _initPrefs();
      
      _achievements.removeWhere((a) => a.id == id);
      await _saveAchievements(_achievements);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting achievement: $e');
    }
  }

  // 切换成就完成状态
  Future<void> toggleAchievementCompletion(int id) async {
    try {
      await _initPrefs();
      
      final index = _achievements.indexWhere((a) => a.id == id);
      if (index != -1) {
        final achievement = _achievements[index];
        final updatedAchievement = achievement.copyWith(
          isCompleted: !achievement.isCompleted,
          completedDate: !achievement.isCompleted ? DateTime.now() : null,
        );
        
        _achievements[index] = updatedAchievement;
        await _saveAchievements(_achievements);
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling achievement completion: $e');
    }
  }

  // 搜索成就
  void searchAchievements(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // 按分类筛选
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // 显示已完成的成就
  void toggleShowCompletedOnly() {
    _showCompletedOnly = !_showCompletedOnly;
    _applyFilters();
    notifyListeners();
  }

  // 应用筛选条件
  void _applyFilters() {
    _filteredAchievements = _achievements.where((achievement) {
      // 搜索筛选
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!achievement.name.toLowerCase().contains(query) &&
            !achievement.description.toLowerCase().contains(query) &&
            !achievement.category.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 分类筛选
      if (_selectedCategory.isNotEmpty && achievement.category != _selectedCategory) {
        return false;
      }

      // 完成状态筛选
      if (_showCompletedOnly && !achievement.isCompleted) {
        return false;
      }

      return true;
    }).toList();

    // 按完成状态和ID排序
    _filteredAchievements.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1; // 未完成的在前
      }
      return a.id.compareTo(b.id);
    });
  }

  // 获取所有分类
  List<String> getCategories() {
    final categories = _achievements.map((a) => a.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // 获取统计信息
  Map<String, int> getStats() {
    final total = _achievements.length;
    final completed = _achievements.where((a) => a.isCompleted).length;
    final primogems = _achievements
        .where((a) => a.isCompleted)
        .fold(0, (sum, a) => sum + a.primogems);

    return {
      'total': total,
      'completed': completed,
      'remaining': total - completed,
      'primogems': primogems,
    };
  }

  // 根据ID获取成就
  Achievement? getAchievementById(int id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // 清除所有筛选
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _showCompletedOnly = false;
    _applyFilters();
    notifyListeners();
  }
}

