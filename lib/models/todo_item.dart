import 'package:flutter/material.dart';

enum TaskPriority {
  low('低优先级', Colors.blue, 1),
  medium('中优先级', Colors.orange, 2),
  high('高优先级', Colors.red, 3);

  final String label;
  final MaterialColor color;
  final int level;
  const TaskPriority(this.label, this.color, this.level);
}

enum TaskCategory {
  work('工作', Icons.work_outline, Color(0xFF3F51B5)),
  life('生活', Icons.home_outlined, Color(0xFF4CAF50)),
  study('学习', Icons.school_outlined, Color(0xFF9C27B0)),
  health('健康', Icons.fitness_center_outlined, Color(0xFFE91E63)),
  entertainment('休闲', Icons.sports_esports_outlined, Color(0xFFFF9800));

  final String label;
  final IconData icon;
  final Color color;
  const TaskCategory(this.label, this.icon, this.color);
}

class TodoItem {
  final String id;
  String title;
  String description;
  int points; // 1 to 11 points (Blackjack style energy consumption)
  TaskCategory category;
  TaskPriority priority;
  bool isCompleted;
  DateTime? dueDate;
  DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.points = 3,
    this.category = TaskCategory.life,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    TaskCategory? category,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'category': category.name,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      points: (json['points'] as int?) ?? 3,
      category: TaskCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TaskCategory.life,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }
}
