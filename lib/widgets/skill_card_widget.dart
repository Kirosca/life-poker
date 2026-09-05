import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';
import '../models/inventory_item.dart';
import 'foil_card_container.dart';

class SkillCardWidget extends StatelessWidget {
  final SkillCard skill;
  final List<InventoryItem> equippedAssets;
  final VoidCallback? onTrain;
  final VoidCallback? onEvolve;
  final VoidCallback? onTap;

  const SkillCardWidget({
    super.key,
    required this.skill,
    this.equippedAssets = const [],
    this.onTrain,
    this.onEvolve,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final suit = skill.suit;
    final rarity = skill.rarity;

    final card = ShadCard(
      padding: const EdgeInsets.all(16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(suit.icon, size: 18, color: suit.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  skill.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: rarity.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: rarity.color.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(rarity.icon, size: 10, color: rarity.color),
                    const SizedBox(width: 3),
                    Text(
                      rarity.label,
                      style: TextStyle(fontSize: 10, color: rarity.color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (skill.isEvolved) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber.withAlpha(80)),
                  ),
                  child: const Text(
                    '★ 高阶觉醒',
                    style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
              ],
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
       footer: (onTrain != null || (onEvolve != null && skill.canEvolve))
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: (onEvolve != null && skill.canEvolve)
                  ? Row(
                      children: [
                        if (onTrain != null)
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onTrain,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF334155)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.sparkles, size: 12, color: Colors.white70),
                                      SizedBox(width: 4),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('研习 (+25)', style: TextStyle(fontSize: 11, color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (onTrain != null) const SizedBox(width: 6),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onEvolve,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber[700],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.flame, size: 12, color: Colors.black),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '演化派生新牌',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTrain,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF334155)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.sparkles, size: 12, color: Colors.white70),
                              SizedBox(width: 6),
                              Text('研习 (+25 EXP)', style: TextStyle(fontSize: 11, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
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
            if (skill.buffDescription != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.zap, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        skill.buffDescription!,
                        style: const TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    return FoilCardContainer(
      rarity: rarity,
      child: card,
    );
  }
}
