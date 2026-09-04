import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
    final availableTasks = allTasks
        .where((t) => t.scheduledBlockId == null && !t.isCompleted)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = ShadTheme.of(ctx);
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
                        style: theme.textTheme.h4,
                      ),
                      Text(
                        '${block.title} (${block.timeRange})',
                        style: theme.textTheme.muted.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  ShadIconButton.ghost(
                    icon: const Icon(LucideIcons.x, size: 16),
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
                        Icon(LucideIcons.inbox, size: 36, color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 10),
                        Text('暂无未安排的空闲任务手牌', style: theme.textTheme.p),
                        const SizedBox(height: 4),
                        Text(
                          '可在“任务卡库”中创建新手牌后再打入',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShadCard(
                          padding: const EdgeInsets.all(12),
                          title: Row(
                            children: [
                              ShadBadge.secondary(
                                child: Text(
                                  '${task.suit.symbol} ${task.points}点',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: task.suit.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: theme.textTheme.p.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              ShadButton.outline(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  onAssignTaskToBlock(block.id, task);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('打入'),
                              ),
                            ],
                          ),
                          description: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '技能: ${skill.name} · ${task.suit.domain}',
                              style: theme.textTheme.muted.copyWith(fontSize: 11),
                            ),
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
    final theme = ShadTheme.of(context);
    final scheduledTasks = allTasks.where((t) => t.scheduledBlockId != null).toList();
    final totalPoints = scheduledTasks.fold<int>(0, (sum, t) => sum + t.points);
    final completedPoints = scheduledTasks
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.points);

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: BlackjackMeter(
            totalPoints: totalPoints,
            completedPoints: completedPoints,
            onHit: onHit,
            onStand: onStand,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日牌桌时间块 (Time-Boxing)',
                style: theme.textTheme.p.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '共 ${timeBlocks.length} 个槽位',
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
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
