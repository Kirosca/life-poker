import 'package:flutter/material.dart';

enum CardSuit {
  spades('黑桃', '♠', '技术/心智', Color(0xFF1E293B), Icons.psychology_outlined),
  hearts('红心', '♥', '健康/活力', Color(0xFFE11D48), Icons.favorite_outline),
  clubs('梅花', '♣', '学习/创造', Color(0xFF0D9488), Icons.auto_awesome_outlined),
  diamonds('方块', '♦', '事业/财富', Color(0xFFD97706), Icons.monetization_on_outlined);

  final String label;
  final String symbol;
  final String domain;
  final Color color;
  final IconData icon;
  const CardSuit(this.label, this.symbol, this.domain, this.color, this.icon);
}

class SkillCard {
  final String id;
  String name;
  CardSuit suit;
  int level;
  int exp;
  int maxExp;
  String description;

  SkillCard({
    required this.id,
    required this.name,
    required this.suit,
    this.level = 1,
    this.exp = 0,
    int? maxExp,
    this.description = '',
  }) : maxExp = maxExp ?? (level * 100);

  void addExp(int amount) {
    exp += amount;
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
  }) {
    return SkillCard(
      id: id ?? this.id,
      name: name ?? this.name,
      suit: suit ?? this.suit,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      maxExp: maxExp ?? this.maxExp,
      description: description ?? this.description,
    );
  }
}

class TaskCard {
  final String id;
  String title;
  String description;
  CardSuit suit;
  int points; // 1~11 (Blackjack energy & difficulty points)
  String? requiredSkillId;
  String? scheduledBlockId; // Assigned to which Time Block
  bool isCompleted;
  DateTime? dueDate;
  DateTime createdAt;

  TaskCard({
    required this.id,
    required this.title,
    this.description = '',
    required this.suit,
    this.points = 3,
    this.requiredSkillId,
    this.scheduledBlockId,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskCard copyWith({
    String? id,
    String? title,
    String? description,
    CardSuit? suit,
    int? points,
    String? requiredSkillId,
    String? scheduledBlockId,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TaskCard(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      suit: suit ?? this.suit,
      points: points ?? this.points,
      requiredSkillId: requiredSkillId ?? this.requiredSkillId,
      scheduledBlockId: scheduledBlockId ?? this.scheduledBlockId,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TimeBlock {
  final String id;
  final String title;
  final String timeRange;
  final IconData icon;
  final int recommendedCapacity; // Maximum recommended points for this slot

  TimeBlock({
    required this.id,
    required this.title,
    required this.timeRange,
    required this.icon,
    this.recommendedCapacity = 7,
  });
}
