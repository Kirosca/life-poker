import 'package:flutter/material.dart';
import '../models/poker_card.dart';

class TimeBlockSlot extends StatelessWidget {
  final TimeBlock block;
  final List<TaskCard> tasks;
  final List<SkillCard> allSkills;
  final VoidCallback onPlayCard;
  final ValueChanged<TaskCard> onToggleTask;
  final ValueChanged<TaskCard> onRemoveTaskFromBlock;

  const TimeBlockSlot({
    super.key,
    required this.block,
    required this.tasks,
    required this.allSkills,
    required this.onPlayCard,
    required this.onToggleTask,
    required this.onRemoveTaskFromBlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final blockPoints = tasks.fold<int>(0, (sum, t) => sum + t.points);
    final completedPoints = tasks
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.points);

    final bool isOverCapacity = blockPoints > block.recommendedCapacity;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverCapacity
              ? Colors.redAccent.withValues(alpha: 0.6)
              : colorScheme.outlineVariant,
          width: isOverCapacity ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Block Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    block.icon,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        block.timeRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Points in slot badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverCapacity
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOverCapacity ? Colors.red : Colors.blue,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$completedPoints / $blockPoints 点 (上限${block.recommendedCapacity})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOverCapacity ? Colors.red.shade700 : Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Played Cards in Slot
            if (tasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.style_outlined,
                      size: 28,
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '此时间块尚未打入卡牌',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: onPlayCard,
                      icon: const Icon(Icons.add_circle_outline, size: 16),
                      label: const Text('出牌 (打入任务卡)'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ...tasks.map((task) {
                final linkedSkill = allSkills.firstWhere(
                  (s) => s.id == task.requiredSkillId,
                  orElse: () => SkillCard(
                    id: 'none',
                    name: '通用',
                    suit: task.suit,
                  ),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                        : task.suit.color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: task.isCompleted
                          ? Colors.grey.shade300
                          : task.suit.color.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => onToggleTask(task),
                      ),
                      // Card Suit & Rank
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: task.suit.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${task.suit.symbol} ${task.points}点',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: task.suit.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Task title & skill linkage
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted
                                    ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                                    : null,
                              ),
                            ),
                            if (task.requiredSkillId != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.flash_on, size: 12, color: task.suit.color),
                                  const SizedBox(width: 2),
                                  Text(
                                    '关联技能: ${linkedSkill.name} (LV.${linkedSkill.level})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: task.suit.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Remove card from this time block
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        tooltip: '移出该时间块',
                        onPressed: () => onRemoveTaskFromBlock(task),
                      ),
                    ],
                  ),
                );
              }),
              // Add more cards button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onPlayCard,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('追加卡牌'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
