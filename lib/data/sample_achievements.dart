import '../models/achievement.dart';

class SampleAchievements {
  static List<Achievement> getSampleData() {
    return [
      const Achievement(
        id: 1,
        name: '初出茅庐',
        description: '完成第一个任务',
        category: '新手指引',
        reward: '原石×5',
        primogems: 5,
        guide: '跟随任务指引完成即可',
        tags: ['新手', '任务'],
        version: '1.0',
      ),
      const Achievement(
        id: 2,
        name: '探索者',
        description: '解锁第一个传送锚点',
        category: '探索',
        reward: '原石×5',
        primogems: 5,
        guide: '在地图上找到传送锚点并激活',
        tags: ['探索', '传送'],
        version: '1.0',
      ),
      const Achievement(
        id: 3,
        name: '收集家',
        description: '收集100个物品',
        category: '收集',
        reward: '原石×10',
        primogems: 10,
        guide: '在野外收集各种材料，累计达到100个',
        tags: ['收集', '材料'],
        version: '1.0',
      ),
      const Achievement(
        id: 4,
        name: '战斗专家',
        description: '击败100个敌人',
        category: '战斗',
        reward: '原石×10',
        primogems: 10,
        guide: '在野外或副本中击败敌人，累计达到100个',
        tags: ['战斗', '敌人'],
        version: '1.0',
      ),
      const Achievement(
        id: 5,
        name: '料理大师',
        description: '制作50道料理',
        category: '生活',
        reward: '原石×10',
        primogems: 10,
        guide: '使用料理锅制作各种料理，累计达到50道',
        tags: ['料理', '生活'],
        version: '1.1',
      ),
      const Achievement(
        id: 6,
        name: '深渊挑战者',
        description: '通过深境螺旋第8层',
        category: '深境螺旋',
        reward: '原石×20',
        primogems: 20,
        guide: '组建强力队伍，挑战深境螺旋并通过第8层',
        tags: ['深境螺旋', '挑战'],
        version: '1.0',
      ),
      const Achievement(
        id: 7,
        name: '元素大师',
        description: '触发1000次元素反应',
        category: '战斗',
        reward: '原石×15',
        primogems: 15,
        guide: '在战斗中合理搭配元素，触发各种元素反应',
        tags: ['元素', '反应'],
        version: '1.0',
      ),
      const Achievement(
        id: 8,
        name: '宝箱猎人',
        description: '开启500个宝箱',
        category: '探索',
        reward: '原石×20',
        primogems: 20,
        guide: '在各个地区探索，寻找并开启宝箱',
        tags: ['宝箱', '探索'],
        version: '1.0',
      ),
      const Achievement(
        id: 9,
        name: '社交达人',
        description: '与10个NPC对话',
        category: '社交',
        reward: '原石×5',
        primogems: 5,
        guide: '在城镇中与各种NPC进行对话',
        tags: ['NPC', '对话'],
        version: '1.0',
      ),
      const Achievement(
        id: 10,
        name: '摄影师',
        description: '拍摄100张照片',
        category: '生活',
        reward: '原石×10',
        primogems: 10,
        guide: '使用相机功能拍摄各种场景和角色',
        tags: ['拍照', '相机'],
        version: '1.2',
      ),
    ];
  }

  static Future<void> initializeSampleData() async {
    // 这个方法可以用来初始化示例数据到数据库
    // 在实际应用中，可以在首次启动时调用
  }
}

