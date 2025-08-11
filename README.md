# 成就管理 App

基于Flutter开发的原神成就管理移动应用，支持完整的成就记录、攻略查询和UIAF标准数据导出。

## 功能特性

### 🎯 核心功能
- **完整成就数据**: 集成真实的原神成就数据（来自AnimeGameData）
- **成就记录**: 标记完成状态，记录完成时间
- **攻略查询**: 提供成就完成攻略和提示
- **数据统计**: 完成进度、原石统计等

### 📊 数据管理
- **本地存储**: 使用SQLite数据库本地存储成就数据
- **UIAF标准**: 完全符合UIAF v1.1标准的导出/导入功能
- **数据同步**: 支持与其他原神工具的数据交换

### 🔍 查找筛选
- **智能搜索**: 按名称、描述、分类搜索成就
- **分类筛选**: 按成就分类快速筛选
- **状态筛选**: 查看已完成/未完成成就
- **版本筛选**: 按游戏版本筛选成就

## 技术架构

### 前端框架
- **Flutter**: 跨平台移动应用开发框架
- **Provider**: 状态管理
- **Material Design**: UI设计语言

### 数据存储
- **SQLite**: 本地数据库存储
- **JSON**: 配置文件和数据交换格式

### 数据源
- **AnimeGameData**: 真实的原神游戏数据
- **UIAF标准**: 统一可交换成就格式

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── achievement.dart      # 成就模型
│   └── achievement.g.dart    # JSON序列化代码
├── services/                 # 业务服务
│   ├── database_service.dart # 数据库服务
│   ├── export_service.dart   # 导出服务
│   └── achievement_data_service.dart # 成就数据处理
├── providers/                # 状态管理
│   └── achievement_provider.dart
├── screens/                  # 页面
│   ├── home_screen.dart      # 首页
│   ├── achievements_screen.dart # 成就列表
│   ├── achievement_detail_screen.dart # 成就详情
│   ├── export_screen.dart    # 导出页面
│   └── settings_screen.dart  # 设置页面
└── data/                     # 示例数据
    └── sample_achievements.dart
```

## 构建说明

### 本地开发

1. 安装Flutter SDK
```bash
# 下载Flutter SDK
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
```

2. 获取依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

### GitHub Actions自动构建

项目配置了GitHub Actions自动构建，每次推送到main分支时会自动：

1. 代码分析和测试
2. 构建Debug和Release版本APK
3. 上传构建产物
4. 创建GitHub Release

### 手动构建APK

```bash
# 构建Debug版本
flutter build apk --debug

# 构建Release版本
flutter build apk --release
```

## UIAF标准支持

本应用完全支持UIAF v1.1标准：

### 导出格式
```json
{
  "info": {
    "export_timestamp": 1640995200,
    "export_app": "cocogoat-app",
    "export_app_version": "1.0.0",
    "uiaf_version": "v1.1"
  },
  "list": [
    {
      "id": 80001,
      "current": 1,
      "status": 2,
      "timestamp": 1640995200
    }
  ]
}
```

### 状态说明
- `status: 1` - INVALID (无效)
- `status: 2` - FINISHED (已完成)
- `status: 3` - POINT_TAKEN (已领取奖励)

## 数据来源

### AnimeGameData
- **仓库**: https://gitlab.com/Dimbreath/AnimeGameData
- **成就数据**: ExcelBinOutput/AchievementExcelConfigData.json
- **文本映射**: TextMap/TextMapCHS.json
- **目标分类**: ExcelBinOutput/AchievementGoalExcelConfigData.json

### 数据处理流程
1. 从AnimeGameData获取原始JSON数据
2. 解析成就配置和文本映射
3. 生成完整的成就信息
4. 存储到本地SQLite数据库

## 开发计划

### 已完成功能
- ✅ Flutter项目框架搭建
- ✅ 成就数据模型设计
- ✅ 本地数据库存储
- ✅ 真实成就数据集成
- ✅ UIAF标准导出
- ✅ GitHub Actions构建配置

### 待优化功能
- 🔄 UI界面优化
- 🔄 性能优化
- 🔄 错误处理完善
- 🔄 用户体验改进

## 许可证

本项目基于MIT许可证开源。

## 贡献指南

欢迎提交Issue和Pull Request来改进项目。

## 致谢

- [AnimeGameData](https://gitlab.com/Dimbreath/AnimeGameData) - 提供真实的原神游戏数据
- [UIAF标准](https://uigf.org/zh/standards/uiaf.html) - 统一可交换成就格式标准
- [Flutter](https://flutter.dev/) - 跨平台移动应用开发框架

