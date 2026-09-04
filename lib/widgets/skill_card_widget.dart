import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';

class SkillCardWidget extends StatelessWidget {
  final SkillCard skill;
  final VoidCallback? onTrain;
  final VoidCallback? onTap;

  const SkillCardWidget({
    super.key,
    required this.skill,
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
          Row(
            children: [
              Icon(suit.icon, size: 18, color: suit.color),
              const SizedBox(width: 6),
              Text(
                skill.name,
                style: theme.textTheme.p.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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
                leading: const Icon(LucideIcons.sparkles, size: 14),
                onPressed: onTrain,
                child: const Text('专项研习 (+25 EXP)'),
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
                Text(
                  '熟练度 (${suit.domain})',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
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
          ],
        ),
      ),
    );
  }
}
