import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';
import '../widgets/time_block_slot.dart';

import '../models/inventory_item.dart';

class PokerTableScreen extends StatelessWidget {
  final List<TimeBlock> timeBlocks;
  final List<EventCard> allEvents;
  final List<SkillCard> allSkills;
  final List<InventoryItem> inventoryItems;
  final ValueChanged<EventCard> onToggleEvent;
  final Function(String blockId, EventCard event) onAssignEventToBlock;
  final ValueChanged<EventCard> onRemoveEventFromBlock;
  final Function(String blockId, String skillId) onEquipSkillToBlock;
  final Function(String blockId, InventoryItem item)? onUseConsumableInBlock;
  final VoidCallback onNightlyPrep;
  final VoidCallback onSleepCheckIn;

  const PokerTableScreen({
    super.key,
    required this.timeBlocks,
    required this.allEvents,
    required this.allSkills,
    this.inventoryItems = const [],
    required this.onToggleEvent,
    required this.onAssignEventToBlock,
    required this.onRemoveEventFromBlock,
    required this.onEquipSkillToBlock,
    this.onUseConsumableInBlock,
    required this.onNightlyPrep,
    required this.onSleepCheckIn,
  });

  void _showEquipSkillSheet(BuildContext context, TimeBlock block) {
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
                      Text('为时间块装配主打技能牌', style: theme.textTheme.h4),
                      Text('${block.title} (${block.timeRange})',
                          style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    ],
                  ),
                  ShadIconButton.ghost(
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allSkills.length,
                  itemBuilder: (c, i) {
                    final skill = allSkills[i];
                    final isEquipped = block.activeSkillId == skill.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ShadCard(
                        padding: const EdgeInsets.all(12),
                        title: Row(
                          children: [
                            Icon(
                              skill.isSleepSkill ? LucideIcons.moon : skill.suit.icon,
                              size: 18,
                              color: skill.suit.color,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(skill.name,
                                      style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold)),
                                  Text(
                                    skill.isSleepSkill
                                        ? '自律打卡 · 次日状态加成'
                                        : 'LV.${skill.level} · ${skill.exp}/${skill.maxExp} EXP',
                                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            isEquipped
                                ? ShadBadge(child: const Text('当前装配'))
                                : ShadButton.outline(
                                    size: ShadButtonSize.sm,
                                    onPressed: () {
                                      onEquipSkillToBlock(block.id, skill.id);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('装配此牌'),
                                  ),
                          ],
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

  void _showAddEventSheet(BuildContext context, TimeBlock block) {
    final unassignedEvents = allEvents
        .where((e) => e.scheduledBlockId == null && !e.isCompleted)
        .toList();

    // Sort: Urgent events first!
    unassignedEvents.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return 0;
    });

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
                      Text('打入事件手牌', style: theme.textTheme.h4),
                      Text('${block.title} (${block.timeRange})',
                          style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    ],
                  ),
                  ShadIconButton.ghost(
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (unassignedEvents.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.inbox, size: 36, color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 10),
                        Text('暂无可安排的待办事件', style: theme.textTheme.p),
                        const SizedBox(height: 4),
                        Text('可在“事件卡库”中创建新任务', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: unassignedEvents.length,
                    itemBuilder: (c, i) {
                      final event = unassignedEvents[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShadCard(
                          padding: const EdgeInsets.all(12),
                          title: Row(
                            children: [
                              ShadBadge.secondary(
                                child: Text(
                                  '${event.suit.symbol} ${event.points}点',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: event.suit.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (event.isUrgent) ...[
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
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: theme.textTheme.p.copyWith(
                                    fontWeight: event.isUrgent ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              ShadButton.outline(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  onAssignEventToBlock(block.id, event);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('打入'),
                              ),
                            ],
                          ),
                          description: event.description.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    event.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                                  ),
                                )
                              : null,
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
    final urgentCount = allEvents.where((e) => e.isUrgent && !e.isCompleted).length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // 顶部备战与警报横幅
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: ShadCard(
            padding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.calendarDays, size: 18),
                    const SizedBox(width: 8),
                    Text('今日实战牌桌', style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  leading: const Icon(LucideIcons.sparkles, size: 14),
                  onPressed: onNightlyPrep,
                  child: const Text('晚间备战 / 模板'),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  if (urgentCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.flame, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            '$urgentCount 项紧迫事件待处理',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        const Icon(LucideIcons.checkCircle2, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('暂无危机紧迫事件，牌局节奏平稳', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),

        // 时间块列表
        ...timeBlocks.map((block) {
          final blockEvents = allEvents
              .where((e) => e.scheduledBlockId == block.id)
              .toList();

          final equippedSkill = allSkills.firstWhere(
            (s) => s.id == block.activeSkillId,
            orElse: () => SkillCard(
              id: 'none',
              name: '未装配技能',
              suit: CardSuit.spades,
            ),
          );

          final hasEquipped = block.activeSkillId != null;
          final allConsumables = inventoryItems.where((i) => i.isConsumable).toList();
          final equippedAssets = hasEquipped
              ? inventoryItems.where((i) => i.isAsset && i.boundSkillId == equippedSkill.id).toList()
              : <InventoryItem>[];

          return TimeBlockSlot(
            block: block,
            equippedSkill: hasEquipped ? equippedSkill : null,
            events: blockEvents,
            allSkills: allSkills,
            allConsumables: allConsumables,
            equippedAssets: equippedAssets,
            onEquipSkill: () => _showEquipSkillSheet(context, block),
            onAddEvent: () => _showAddEventSheet(context, block),
            onToggleEvent: onToggleEvent,
            onRemoveEventFromBlock: onRemoveEventFromBlock,
            onUseConsumable: onUseConsumableInBlock != null
                ? (item) => onUseConsumableInBlock!(block.id, item)
                : null,
            onSleepDisciplineCheck: onSleepCheckIn,
          );
        }),
      ],
    );
  }
}
