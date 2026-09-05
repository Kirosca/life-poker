import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';

import '../models/inventory_item.dart';

class SkillCardWidget extends StatelessWidget {
  final SkillCard skill;
  final List<InventoryItem> equippedAssets;
  final VoidCallback? onTrain;
  final VoidCallback? onTap;

  const SkillCardWidget({
    super.key,
    required this.skill,
    this.equippedAssets = const [],
    this.onTrain,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final suit = skill.suit;

    return ShadCard(
      padding: const EdgeInsets.all(16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(suit.icon, size: 18, color: suit.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    skill.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ShadBadge.secondary(
            child: Text(
              'LV.${skill.level}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: suit.color,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      description: skill.description.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                skill.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.muted.copyWith(fontSize: 12),
              ),
            )
          : null,
       footer: onTrain != null
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ShadButton.outline(
                width: double.infinity,
                size: ShadButtonSize.sm,
                leading: const Icon(LucideIcons.sparkles, size: 12),
                onPressed: onTrain,
                child: const Text('研习 (+25 EXP)', style: TextStyle(fontSize: 11)),
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '熟练度 (${suit.domain})',
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${skill.exp}/${skill.maxExp} EXP',
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ShadProgress(
              value: skill.progress,
              minHeight: 6,
            ),
            if (equippedAssets.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: equippedAssets.map((asset) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3B82F6).withAlpha(70)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(asset.icon, size: 10, color: const Color(0xFF60A5FA)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${asset.name} · ${asset.buffEffect ?? "装备中"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF93C5FD)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
