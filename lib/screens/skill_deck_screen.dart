import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';
import '../widgets/skill_card_widget.dart';

import '../models/inventory_item.dart';

class SkillDeckScreen extends StatefulWidget {
  final List<SkillCard> skills;
  final List<InventoryItem> inventoryItems;
  final ValueChanged<SkillCard> onAddSkill;
  final ValueChanged<SkillCard> onTrainSkill;

  const SkillDeckScreen({
    super.key,
    required this.skills,
    this.inventoryItems = const [],
    required this.onAddSkill,
    required this.onTrainSkill,
  });

  @override
  State<SkillDeckScreen> createState() => _SkillDeckScreenState();
}

class _SkillDeckScreenState extends State<SkillDeckScreen> {
  CardSuit? _selectedSuit;

  void _showAddSkillDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    CardSuit suit = CardSuit.spades;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = ShadTheme.of(ctx);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '解锁技能手牌 (Skill Card)',
                          style: theme.textTheme.h4,
                        ),
                        ShadIconButton.ghost(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('技能名称 *', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: nameCtrl,
                      placeholder: const Text('例如：Flutter 架构设计、自由泳、认知心理学'),
                    ),
                    const SizedBox(height: 14),
                    Text('技能掌握目标与愿景', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: descCtrl,
                      placeholder: const Text('设定掌握此技能的目标或关键习惯...'),
                    ),
                    const SizedBox(height: 16),
                    Text('选择花色领域', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: CardSuit.values.map((s) {
                        final isSelected = suit == s;
                        return isSelected
                            ? ShadButton(
                                size: ShadButtonSize.sm,
                                leading: Icon(s.icon, size: 14),
                                onPressed: () {},
                                child: Text('${s.label} (${s.domain})'),
                              )
                            : ShadButton.outline(
                                size: ShadButtonSize.sm,
                                leading: Icon(s.icon, size: 14, color: s.color),
                                onPressed: () => setSheetState(() => suit = s),
                                child: Text('${s.label} (${s.domain})'),
                              );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ShadButton(
                      width: double.infinity,
                      child: const Text('解锁技能手牌'),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final newSkill = SkillCard(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          suit: suit,
                          description: descCtrl.text.trim(),
                        );
                        widget.onAddSkill(newSkill);
                        Navigator.pop(ctx);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final filteredSkills = _selectedSuit == null
        ? widget.skills
        : widget.skills.where((s) => s.suit == _selectedSuit).toList();

    return Scaffold(
      body: Column(
        children: [
          // Filter by Suit badges
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _selectedSuit == null
                      ? ShadBadge(child: const Text('全部技能'))
                      : GestureDetector(
                          onTap: () => setState(() => _selectedSuit = null),
                          child: ShadBadge.outline(child: const Text('全部技能')),
                        ),
                ),
                ...CardSuit.values.map((s) {
                  final isSelected = _selectedSuit == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedSuit = isSelected ? null : s;
                      }),
                      child: isSelected
                          ? ShadBadge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(s.symbol),
                                  const SizedBox(width: 4),
                                  Text('${s.label} · ${s.domain}'),
                                ],
                              ),
                            )
                          : ShadBadge.outline(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(s.symbol, style: TextStyle(color: s.color)),
                                  const SizedBox(width: 4),
                                  Text('${s.label} · ${s.domain}'),
                                ],
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Grid View
          Expanded(
            child: filteredSkills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.sparkles, size: 40, color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 10),
                        Text('暂无该分类技能卡牌', style: theme.textTheme.p),
                        const SizedBox(height: 8),
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          leading: const Icon(LucideIcons.plus, size: 14),
                          onPressed: () => _showAddSkillDialog(context),
                          child: const Text('解锁新技能卡'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 340,
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredSkills.length,
                    itemBuilder: (ctx, i) {
                      final skill = filteredSkills[i];
                      final skillEquippedAssets = widget.inventoryItems
                          .where((item) => item.isAsset && item.boundSkillId == skill.id)
                          .toList();

                      return SkillCardWidget(
                        skill: skill,
                        equippedAssets: skillEquippedAssets,
                        onTrain: () => widget.onTrainSkill(skill),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSkillDialog(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('解锁技能'),
      ),
    );
  }
}
