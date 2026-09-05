import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum CardSuit {
  spades('黑桃', '♠', '技术/心智', Color(0xFF64748B), LucideIcons.spade),
  hearts('红心', '♥', '健康/活力', Color(0xFFF43F5E), LucideIcons.heart),
  clubs('梅花', '♣', '学习/创造', Color(0xFF14B8A6), LucideIcons.club),
  diamonds('方块', '♦', '事业/财富', Color(0xFFF59E0B), LucideIcons.gem);

  final String label;
  final String symbol;
  final String domain;
  final Color color;
  final IconData icon;
  const CardSuit(this.label, this.symbol, this.domain, this.color, this.icon);
}

enum CardRarity {
  common('普通手牌', Color(0xFF94A3B8), LucideIcons.badge),
  rare('稀有进阶', Color(0xFF38BDF8), LucideIcons.gem),
  epic('史诗觉醒', Color(0xFFA855F7), LucideIcons.sparkles),
  legendary('传奇天命', Color(0xFFF59E0B), LucideIcons.crown);

  final String label;
  final Color color;
  final IconData icon;
  const CardRarity(this.label, this.color, this.icon);
}

class SkillEvolutionOption {
  final String id;
  final String name;
  final String description;
  final CardSuit suit;
  final int requiredParentLevel;
  final String buffDescription;

  const SkillEvolutionOption({
    required this.id,
    required this.name,
    required this.description,
    required this.suit,
    this.requiredParentLevel = 3,
    required this.buffDescription,
  });
}

class SleepDisciplineState {
  int streakDays;
  int disciplineScore;
  bool isNextDayBoostActive;
  DateTime? lastSettlementDate;

  SleepDisciplineState({
    this.streakDays = 3,
    this.disciplineScore = 92,
    this.isNextDayBoostActive = true,
    this.lastSettlementDate,
  });

  SleepDisciplineState copyWith({
    int? streakDays,
    int? disciplineScore,
    bool? isNextDayBoostActive,
    DateTime? lastSettlementDate,
  }) {
    return SleepDisciplineState(
      streakDays: streakDays ?? this.streakDays,
      disciplineScore: disciplineScore ?? this.disciplineScore,
      isNextDayBoostActive: isNextDayBoostActive ?? this.isNextDayBoostActive,
      lastSettlementDate: lastSettlementDate ?? this.lastSettlementDate,
    );
  }
}

class SkillCard {
  final String id;
  String name;
  CardSuit suit;
  int level;
  int exp;
  int maxExp;
  String description;
  bool isSleepSkill; // 特殊睡眠技能牌
  int sleepDisciplineScore; // 睡眠自律连续打卡分
  String? parentTag; // 父级/分类标签
  List<String> equippedAssetIds; // 装备的固定资产 ID 列表
  String? evolvedFromSkillId; // 演化自哪张父级技能
  String? buffDescription; // 演化专精带来的被动效果
  List<SkillEvolutionOption> evolutionOptions; // 可演化分支列表

  SkillCard({
    required this.id,
    required this.name,
    required this.suit,
    this.level = 1,
    this.exp = 0,
    int? maxExp,
    this.description = '',
    this.isSleepSkill = false,
    this.sleepDisciplineScore = 90,
    this.parentTag,
    List<String>? equippedAssetIds,
    this.evolvedFromSkillId,
    this.buffDescription,
    List<SkillEvolutionOption>? evolutionOptions,
  })  : maxExp = maxExp ?? (level * 100),
        equippedAssetIds = equippedAssetIds != null ? List<String>.from(equippedAssetIds) : [],
        evolutionOptions = evolutionOptions != null ? List<SkillEvolutionOption>.from(evolutionOptions) : [];

  bool get isEvolved => evolvedFromSkillId != null;
  bool get canEvolve => !isEvolved && level >= 3 && evolutionOptions.isNotEmpty;

  CardRarity get rarity {
    if (level >= 5 || (isEvolved && level >= 3)) return CardRarity.legendary;
    if (isEvolved) return CardRarity.epic;
    if (level >= 3) return CardRarity.rare;
    return CardRarity.common;
  }

  void addExp(int amount, {bool hasNextDayDisciplineBoost = false}) {
    final effectiveAmount = hasNextDayDisciplineBoost ? (amount * 1.5).round() : amount;
    exp += effectiveAmount;
    while (exp >= maxExp) {
      exp -= maxExp;
      level += 1;
      maxExp = level * 100;
    }
  }

  double get progress => (exp / maxExp).clamp(0.0, 1.0);

  SkillCard copyWith({
    String? id,
    String? name,
    CardSuit? suit,
    int? level,
    int? exp,
    int? maxExp,
    String? description,
    bool? isSleepSkill,
    int? sleepDisciplineScore,
    String? parentTag,
    List<String>? equippedAssetIds,
    String? evolvedFromSkillId,
    String? buffDescription,
    List<SkillEvolutionOption>? evolutionOptions,
  }) {
    return SkillCard(
      id: id ?? this.id,
      name: name ?? this.name,
      suit: suit ?? this.suit,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      maxExp: maxExp ?? this.maxExp,
      description: description ?? this.description,
      isSleepSkill: isSleepSkill ?? this.isSleepSkill,
      sleepDisciplineScore: sleepDisciplineScore ?? this.sleepDisciplineScore,
      parentTag: parentTag ?? this.parentTag,
      equippedAssetIds: equippedAssetIds ?? List.from(this.equippedAssetIds),
      evolvedFromSkillId: evolvedFromSkillId ?? this.evolvedFromSkillId,
      buffDescription: buffDescription ?? this.buffDescription,
      evolutionOptions: evolutionOptions ?? List.from(this.evolutionOptions),
    );
  }
}

class EventCard {
  final String id;
  String title;
  String description;
  CardSuit suit;
  int points; // 难度/耗能点数 (1~11)
  bool isUrgent; // 是否为未来紧迫事件卡
  DateTime? deadline; // 截止倒计时
  String? scheduledBlockId; // 当前打入的时间块 ID
  String? requiredSkillId; // 关联技能牌 ID
  bool isCompleted;
  DateTime createdAt;

  EventCard({
    required this.id,
    required this.title,
    this.description = '',
    required this.suit,
    this.points = 3,
    this.isUrgent = false,
    this.deadline,
    this.scheduledBlockId,
    this.requiredSkillId,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 计算倒计时状态
  String get countdownString {
    if (deadline == null) return '';
    final now = DateTime.now();
    final diff = deadline!.difference(now);
    if (diff.isNegative) {
      return '已逾期';
    } else if (diff.inDays > 0) {
      return '剩余 ${diff.inDays} 天';
    } else if (diff.inHours > 0) {
      return '剩余 ${diff.inHours} 小时';
    } else {
      return '剩余 ${diff.inMinutes} 分钟';
    }
  }

  EventCard copyWith({
    String? id,
    String? title,
    String? description,
    CardSuit? suit,
    int? points,
    bool? isUrgent,
    DateTime? deadline,
    String? scheduledBlockId,
    String? requiredSkillId,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return EventCard(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      suit: suit ?? this.suit,
      points: points ?? this.points,
      isUrgent: isUrgent ?? this.isUrgent,
      deadline: deadline ?? this.deadline,
      scheduledBlockId: scheduledBlockId ?? this.scheduledBlockId,
      requiredSkillId: requiredSkillId ?? this.requiredSkillId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TimeBlock {
  final String id;
  final String title;
  final String timeRange;
  final IconData icon;
  final int recommendedCapacity; // 建议容量
  String? activeSkillId; // 【技能卡槽】：当前时间块挂载的主打技能牌
  List<String> usedConsumableIds; // 【消耗品道具槽】：当前时间块已使用的消耗品

  TimeBlock({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.icon,
    this.recommendedCapacity = 7,
    this.activeSkillId,
    List<String>? usedConsumableIds,
  }) : usedConsumableIds = usedConsumableIds ?? [];

  TimeBlock copyWith({
    String? id,
    String? title,
    String? timeRange,
    IconData? icon,
    int? recommendedCapacity,
    String? activeSkillId,
    List<String>? usedConsumableIds,
  }) {
    return TimeBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      timeRange: timeRange ?? this.timeRange,
      icon: icon ?? this.icon,
      recommendedCapacity: recommendedCapacity ?? this.recommendedCapacity,
      activeSkillId: activeSkillId ?? this.activeSkillId,
      usedConsumableIds: usedConsumableIds ?? List.from(this.usedConsumableIds),
    );
  }
}
