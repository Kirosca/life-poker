import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class StatsDialog extends StatelessWidget {
  final List<TodoItem> todos;

  const StatsDialog({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCount = todos.length;
    final completedCount = todos.where((t) => t.isCompleted).length;
    final pendingCount = totalCount - completedCount;

    final totalPoints = todos.fold<int>(0, (sum, t) => sum + t.points);
    final completedPoints = todos
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.points);

    final completionRate = totalCount > 0 ? (completedCount / totalCount * 100).toInt() : 0;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.insights_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('数据统计与精力看板'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Summary cards
              Row(
                children: [
                  _StatTile(
                    title: '待办总计',
                    value: '$totalCount',
                    subtitle: '已完成 $completedCount',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    title: '完成率',
                    value: '$completionRate%',
                    subtitle: '剩余 $pendingCount 项',
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatTile(
                    title: '今日精力点',
                    value: '$totalPoints / 21',
                    subtitle: totalPoints > 21 ? '已超载(Bust)' : '在合理区间',
                    color: totalPoints > 21 ? Colors.red : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    title: '已消耗精力',
                    value: '$completedPoints 点',
                    subtitle: '有效产出点数',
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Category breakdown
              Text(
                '各类别分布',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...TaskCategory.values.map((cat) {
                final catTodos = todos.where((t) => t.category == cat).toList();
                if (catTodos.isEmpty) return const SizedBox.shrink();
                final catPoints = catTodos.fold<int>(0, (s, t) => s + t.points);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 16, color: cat.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${cat.label} (${catTodos.length} 项)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '$catPoints 点',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cat.color,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
