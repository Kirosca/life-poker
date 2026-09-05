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
  final Function(SkillCard parentSkill, SkillEvolutionOption option)? onEvolveSkill;

  const SkillDeckScreen({
    super.key,
    required this.skills,
    this.inventoryItems = const [],
    required this.onAddSkill,
    required this.onTrainSkill,
    this.onEvolveSkill,
  });

  @override
  State<SkillDeckScreen> createState() => _SkillDeckScreenState();
}

class _SkillDeckScreenState extends State<SkillDeckScreen> {
  CardSuit? _selectedSuit;

  void _showEvolutionDialog(BuildContext context, SkillCard skill) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = ShadTheme.of(ctx);
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.flame, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '技能演化与专精派生',
                            style: theme.textTheme.h4.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '【${skill.name}】已达到 LV.${skill.level}，满足觉醒条件！请选择一个分支演化为全新高阶技能手牌：',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ...skill.evolutionOptions.map((opt) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withAlpha(80)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(opt.suit.icon, size: 16, color: opt.suit.color),
                              const SizedBox(width: 6),
                              Text(
                                opt.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '高阶觉醒',
                                  style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            opt.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.zap, size: 12, color: Colors.amber),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '被动专精: ${opt.buffDescription}',
                                    style: const TextStyle(fontSize: 11, color: Colors.amber),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(LucideIcons.sparkles, size: 14),
                              label: Text(
                                '演化觉醒【${opt.name}】',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              onPressed: () {
                                widget.onEvolveSkill?.call(skill, opt);
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
                        onEvolve: widget.onEvolveSkill != null ? () => _showEvolutionDialog(context, skill) : null,
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
