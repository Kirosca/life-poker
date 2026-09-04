import 'package:flutter/material.dart';
import '../models/poker_card.dart';
import '../widgets/blackjack_meter.dart';
import '../widgets/time_block_slot.dart';

class PokerTableScreen extends StatelessWidget {
  final List<TimeBlock> timeBlocks;
  final List<TaskCard> allTasks;
  final List<SkillCard> allSkills;
  final ValueChanged<TaskCard> onToggleTask;
  final Function(String blockId, TaskCard task) onAssignTaskToBlock;
  final ValueChanged<TaskCard> onRemoveTaskFromBlock;
  final VoidCallback onHit;
  final VoidCallback onStand;

  const PokerTableScreen({
    super.key,
    required this.timeBlocks,
    required this.allTasks,
    required this.allSkills,
    required this.onToggleTask,
    required this.onAssignTaskToBlock,
    required this.onRemoveTaskFromBlock,
    required this.onHit,
    required this.onStand,
  });

  void _showPlayCardSheet(BuildContext context, TimeBlock block) {
    // Show tasks that are not yet assigned to any time block
    final availableTasks = allTasks
        .where((t) => t.scheduledBlockId == null && !t.isCompleted)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '出牌：打入时间块',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${block.title} (${block.timeRange})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (availableTasks.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.style_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('暂无未安排的空闲任务手牌'),
                        const SizedBox(height: 8),
                        Text(
                          '可在“任务卡库”中创建新任务后再出牌',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: availableTasks.length,
                    itemBuilder: (c, i) {
                      final task = availableTasks[i];
                      final skill = allSkills.firstWhere(
                        (s) => s.id == task.requiredSkillId,
                        orElse: () => SkillCard(
                          id: 'none',
                          name: '通用',
                          suit: task.suit,
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.suit.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${task.suit.symbol} ${task.points}点',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: task.suit.color,
                              ),
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '加成技能: ${skill.name} · ${task.suit.domain}',
                            style: TextStyle(fontSize: 12, color: task.suit.color),
                          ),
                          trailing: FilledButton.tonal(
                            child: const Text('打入'),
                            onPressed: () {
                              onAssignTaskToBlock(block.id, task);
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total planned points across all scheduled time blocks
    final scheduledTasks = allTasks.where((t) => t.scheduledBlockId != null).toList();
    final totalPoints = scheduledTasks.fold<int>(0, (sum, t) => sum + t.points);
    final completedPoints = scheduledTasks
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.points);

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Blackjack Energy Meter (as secondary supervisor feature)
        BlackjackMeter(
          totalPoints: totalPoints,
          completedPoints: completedPoints,
          onHit: onHit,
          onStand: onStand,
        ),

        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.dashboard_customize_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '今日牌桌时间块 (Time-Boxing)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(
                '共 ${timeBlocks.length} 个卡槽',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Time block slots
        ...timeBlocks.map((block) {
          final blockTasks = allTasks
              .where((t) => t.scheduledBlockId == block.id)
              .toList();

          return TimeBlockSlot(
            block: block,
            tasks: blockTasks,
            allSkills: allSkills,
            onPlayCard: () => _showPlayCardSheet(context, block),
            onToggleTask: onToggleTask,
            onRemoveTaskFromBlock: onRemoveTaskFromBlock,
          );
        }),
      ],
    );
  }
}
