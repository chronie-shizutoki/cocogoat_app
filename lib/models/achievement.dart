import 'package:json_annotation/json_annotation.dart';

part 'achievement.g.dart';

@JsonSerializable()
class Achievement {
  final int id;
  final String name;
  final String description;
  final String category;
  final String reward;
  final bool isCompleted;
  final DateTime? completedDate;
  final String? guide;
  final List<String> tags;
  final int primogems;
  final String version;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.reward,
    this.isCompleted = false,
    this.completedDate,
    this.guide,
    this.tags = const [],
    this.primogems = 0,
    this.version = '',
  });

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementToJson(this);

  Achievement copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? reward,
    bool? isCompleted,
    DateTime? completedDate,
    String? guide,
    List<String>? tags,
    int? primogems,
    String? version,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      guide: guide ?? this.guide,
      tags: tags ?? this.tags,
      primogems: primogems ?? this.primogems,
      version: version ?? this.version,
    );
  }
}

@JsonSerializable()
class AchievementCategory {
  final String id;
  final String name;
  final String description;
  final int totalCount;
  final int completedCount;
  final String iconPath;

  const AchievementCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.totalCount,
    required this.completedCount,
    this.iconPath = '',
  });

  factory AchievementCategory.fromJson(Map<String, dynamic> json) =>
      _$AchievementCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementCategoryToJson(this);

  double get completionRate => totalCount > 0 ? completedCount / totalCount : 0.0;
}

@JsonSerializable()
class ExportFormat {
  final String version;
  final bool includeOnlyCompleted;
  final String fileName;
  final DateTime exportDate;

  const ExportFormat({
    required this.version,
    required this.includeOnlyCompleted,
    required this.fileName,
    required this.exportDate,
  });

  factory ExportFormat.fromJson(Map<String, dynamic> json) =>
      _$ExportFormatFromJson(json);

  Map<String, dynamic> toJson() => _$ExportFormatToJson(this);
}

