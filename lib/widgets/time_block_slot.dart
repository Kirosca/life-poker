import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
    final theme = ShadTheme.of(context);
    final blockPoints = tasks.fold<int>(0, (sum, t) => sum + t.points);
    final completedPoints = tasks
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.points);

    final bool isOverCapacity = blockPoints > block.recommendedCapacity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ShadCard(
        padding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Icon(block.icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.title,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    block.timeRange,
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            ShadBadge(
              backgroundColor: isOverCapacity
                  ? theme.colorScheme.destructive
                  : theme.colorScheme.secondary,
              foregroundColor: isOverCapacity
                  ? theme.colorScheme.destructiveForeground
                  : theme.colorScheme.secondaryForeground,
              child: Text(
                '$completedPoints / $blockPoints 点 (上限${block.recommendedCapacity})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.spade,
                        size: 24,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '此时间块尚未打入卡牌',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      ShadButton.outline(
                        size: ShadButtonSize.sm,
                        leading: const Icon(LucideIcons.plus, size: 14),
                        onPressed: onPlayCard,
                        child: const Text('出牌 (打入任务卡)'),
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
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.border),
                      color: task.isCompleted
                          ? theme.colorScheme.muted.withValues(alpha: 0.3)
                          : null,
                    ),
                    child: Row(
                      children: [
                        ShadCheckbox(
                          value: task.isCompleted,
                          onChanged: (_) => onToggleTask(task),
                        ),
                        const SizedBox(width: 8),
                        ShadBadge.secondary(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(task.suit.symbol,
                                  style: TextStyle(
                                    color: task.suit.color,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(width: 3),
                              Text('${task.points}点',
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: theme.textTheme.p.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? theme.colorScheme.mutedForeground
                                      : null,
                                ),
                              ),
                              if (task.requiredSkillId != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '加成: ${linkedSkill.name} (LV.${linkedSkill.level})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: task.suit.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        ShadIconButton.ghost(
                          icon: const Icon(LucideIcons.x, size: 14),
                          onPressed: () => onRemoveTaskFromBlock(task),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.plus, size: 12),
                    onPressed: onPlayCard,
                    child: const Text('追加手牌'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
