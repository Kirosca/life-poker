import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';

class TimeBlockSlot extends StatelessWidget {
  final TimeBlock block;
  final SkillCard? equippedSkill;
  final List<EventCard> events;
  final List<SkillCard> allSkills;
  final VoidCallback onEquipSkill;
  final VoidCallback onAddEvent;
  final ValueChanged<EventCard> onToggleEvent;
  final ValueChanged<EventCard> onRemoveEventFromBlock;
  final VoidCallback? onSleepDisciplineCheck;

  const TimeBlockSlot({
    super.key,
    required this.block,
    required this.equippedSkill,
    required this.events,
    required this.allSkills,
    required this.onEquipSkill,
    required this.onAddEvent,
    required this.onToggleEvent,
    required this.onRemoveEventFromBlock,
    this.onSleepDisciplineCheck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final blockPoints = events.fold<int>(0, (sum, t) => sum + t.points);
    final completedPoints = events
        .where((t) => t.isCompleted)
        .fold<int>(0, (sum, t) => sum + t.points);

    final bool isOverCapacity = blockPoints > block.recommendedCapacity;
    final bool isSleepBlock = equippedSkill?.isSleepSkill ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // ===================== 【槽位 1：主打技能卡槽】 =====================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: equippedSkill != null
                        ? equippedSkill!.suit.color.withValues(alpha: 0.4)
                        : theme.colorScheme.border,
                  ),
                  color: equippedSkill != null
                      ? equippedSkill!.suit.color.withValues(alpha: 0.05)
                      : theme.colorScheme.muted.withValues(alpha: 0.15),
                ),
                child: Row(
                  children: [
                    if (equippedSkill != null) ...[
                      Icon(
                        isSleepBlock ? LucideIcons.moon : equippedSkill!.suit.icon,
                        size: 20,
                        color: equippedSkill!.suit.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isSleepBlock ? '🌙 睡眠恢复与自律' : equippedSkill!.name,
                                  style: theme.textTheme.p.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                ShadBadge.secondary(
                                  child: Text(
                                    isSleepBlock
                                        ? '自律分 ${equippedSkill!.sleepDisciplineScore}'
                                        : 'LV.${equippedSkill!.level}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSleepBlock
                                  ? '纪律达标将激活明日全技能精力充沛状态'
                                  : '攻克本时间块事件将注入经验至此技能',
                              style: theme.textTheme.muted.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (isSleepBlock && onSleepDisciplineCheck != null)
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          leading: const Icon(LucideIcons.checkCheck, size: 14),
                          onPressed: onSleepDisciplineCheck,
                          child: const Text('打卡'),
                        )
                      else
                        ShadButton.ghost(
                          size: ShadButtonSize.sm,
                          onPressed: onEquipSkill,
                          child: const Text('更换技能'),
                        ),
                    ] else ...[
                      Icon(
                        LucideIcons.sparkles,
                        size: 18,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '未装配主打技能牌 (点击装配为事件提供经验加成)',
                          style: theme.textTheme.muted.copyWith(fontSize: 12),
                        ),
                      ),
                      ShadButton.outline(
                        size: ShadButtonSize.sm,
                        onPressed: onEquipSkill,
                        child: const Text('装配技能'),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // ===================== 【槽位 2：事件攻坚槽】 =====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '待攻克事件手牌 (${events.length})',
                    style: theme.textTheme.muted.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.plus, size: 12),
                    onPressed: onAddEvent,
                    child: const Text('打入事件'),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              if (events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.border,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '当前时间块暂无安排事件，点击上方“打入事件”出牌',
                      style: theme.textTheme.muted.copyWith(fontSize: 11),
                    ),
                  ),
                )
              else ...[
                ...events.map((event) {
                  final bool isUrgent = event.isUrgent && !event.isCompleted;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isUrgent
                            ? Colors.redAccent
                            : theme.colorScheme.border,
                        width: isUrgent ? 1.5 : 1,
                      ),
                      color: event.isCompleted
                          ? theme.colorScheme.muted.withValues(alpha: 0.3)
                          : isUrgent
                              ? Colors.redAccent.withValues(alpha: 0.06)
                              : null,
                    ),
                    child: Row(
                      children: [
                        ShadCheckbox(
                          value: event.isCompleted,
                          onChanged: (_) => onToggleEvent(event),
                        ),
                        const SizedBox(width: 8),

                        // 花色 & 点数
                        ShadBadge.secondary(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                event.suit.symbol,
                                style: TextStyle(
                                  color: event.suit.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text('${event.points}点', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 紧迫事件高亮标记
                        if (isUrgent) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.flame, size: 12, color: Colors.redAccent),
                                const SizedBox(width: 2),
                                Text(
                                  event.countdownString.isNotEmpty ? event.countdownString : '紧迫',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // 事件标题
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: theme.textTheme.p.copyWith(
                                  fontSize: 13,
                                  fontWeight: isUrgent ? FontWeight.bold : FontWeight.w500,
                                  decoration: event.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: event.isCompleted
                                      ? theme.colorScheme.mutedForeground
                                      : null,
                                ),
                              ),
                              if (event.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  event.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // 移出按钮
                        ShadIconButton.ghost(
                          icon: const Icon(LucideIcons.x, size: 14),
                          onPressed: () => onRemoveEventFromBlock(event),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
