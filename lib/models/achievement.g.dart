// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      reward: json['reward'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
      guide: json['guide'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      primogems: (json['primogems'] as num?)?.toInt() ?? 0,
      version: json['version'] as String? ?? '',
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'reward': instance.reward,
      'isCompleted': instance.isCompleted,
      'completedDate': instance.completedDate?.toIso8601String(),
      'guide': instance.guide,
      'tags': instance.tags,
      'primogems': instance.primogems,
      'version': instance.version,
    };

AchievementCategory _$AchievementCategoryFromJson(Map<String, dynamic> json) =>
    AchievementCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalCount: (json['totalCount'] as num).toInt(),
      completedCount: (json['completedCount'] as num).toInt(),
      iconPath: json['iconPath'] as String? ?? '',
    );

Map<String, dynamic> _$AchievementCategoryToJson(
        AchievementCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'totalCount': instance.totalCount,
      'completedCount': instance.completedCount,
      'iconPath': instance.iconPath,
    };

ExportFormat _$ExportFormatFromJson(Map<String, dynamic> json) => ExportFormat(
      version: json['version'] as String,
      includeOnlyCompleted: json['includeOnlyCompleted'] as bool,
      fileName: json['fileName'] as String,
      exportDate: DateTime.parse(json['exportDate'] as String),
    );

Map<String, dynamic> _$ExportFormatToJson(ExportFormat instance) =>
    <String, dynamic>{
      'version': instance.version,
      'includeOnlyCompleted': instance.includeOnlyCompleted,
      'fileName': instance.fileName,
      'exportDate': instance.exportDate.toIso8601String(),
    };
