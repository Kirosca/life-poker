import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';
import '../models/inventory_item.dart';
import 'foil_card_container.dart';

class SkillTechTreeView extends StatefulWidget {
  final List<SkillCard> skills;
  final List<InventoryItem> inventoryItems;
  final ValueChanged<SkillCard> onTrainSkill;
  final Function(SkillCard parentSkill, SkillEvolutionOption option)? onEvolveSkill;

  const SkillTechTreeView({
    super.key,
    required this.skills,
    this.inventoryItems = const [],
    required this.onTrainSkill,
    this.onEvolveSkill,
  });

  @override
  State<SkillTechTreeView> createState() => _SkillTechTreeViewState();
}

class _SkillTechTreeViewState extends State<SkillTechTreeView> {
  CardSuit? _activeSuitFilter;

  void _showNodeDetailsDialog(BuildContext context, SkillCard skill) {
    final theme = ShadTheme.of(context);
    final equippedAssets = widget.inventoryItems
        .where((i) => i.isAsset && i.boundSkillId == skill.id)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: skill.rarity.color.withAlpha(120), width: 1.5),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
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
                        Icon(skill.suit.icon, color: skill.suit.color, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          skill.name,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: skill.rarity.color.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: skill.rarity.color.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(skill.rarity.icon, size: 12, color: skill.rarity.color),
                          const SizedBox(width: 4),
                          Text(
                            skill.rarity.label,
                            style: TextStyle(fontSize: 11, color: skill.rarity.color, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShadBadge.secondary(
                      child: Text('LV.${skill.level} (${skill.suit.domain})'),
                    ),
                    if (skill.isEvolved) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '★ 觉醒派生手牌',
                        style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                if (skill.description.isNotEmpty) ...[
                  Text(
                    skill.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 12),
                ],
                if (skill.buffDescription != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withAlpha(70)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.zap, color: Colors.amber, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '专精被动: ${skill.buffDescription}',
                            style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // 熟练度
                Text(
                  '熟练度积累: ${skill.exp} / ${skill.maxExp} EXP',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: skill.progress,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(skill.suit.color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                // 装备加成
                if (equippedAssets.isNotEmpty) ...[
                  Text(
                    '已装配加成装备:',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: equippedAssets.map((a) {
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF3B82F6).withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(a.icon, size: 12, color: const Color(0xFF60A5FA)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${a.name} (${a.buffEffect ?? "加成"})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF93C5FD)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        onPressed: () {
                          widget.onTrainSkill(skill);
                          Navigator.pop(ctx);
                        },
                        leading: const Icon(LucideIcons.sparkles, size: 14),
                        child: const Text('立即研习 (+25 EXP)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillNode(SkillCard skill, {bool isChild = false}) {
    final rarity = skill.rarity;

    final content = Container(
      width: isChild ? 240 : 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isChild ? Colors.amber.withAlpha(120) : const Color(0xFF334155),
          width: isChild ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(skill.suit.icon, size: 16, color: skill.suit.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  skill.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: rarity.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rarity.label,
                  style: TextStyle(fontSize: 9, color: rarity.color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LV.${skill.level}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: skill.suit.color),
              ),
              Text(
                '${skill.exp}/${skill.maxExp} EXP',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: skill.progress,
              minHeight: 4,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(skill.suit.color),
            ),
          ),
          if (skill.buffDescription != null) ...[
            const SizedBox(height: 6),
            Text(
              '⚡ ${skill.buffDescription}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.amber),
            ),
          ],
        ],
      ),
    );

    return InkWell(
      onTap: () => _showNodeDetailsDialog(context, skill),
      borderRadius: BorderRadius.circular(10),
      child: FoilCardContainer(
        rarity: rarity,
        child: content,
      ),
    );
  }

  Widget _buildBranchOptionNode(SkillCard parentSkill, SkillEvolutionOption option) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.amber.withAlpha(160),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.gitBranch, size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  option.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.amber,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('可觉醒', style: TextStyle(fontSize: 9, color: Colors.amber)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            option.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 26,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () => widget.onEvolveSkill?.call(parentSkill, option),
              child: const Text(
                '演化觉醒',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter root skills (not evolved from another skill)
    final rootSkills = widget.skills.where((s) => !s.isEvolved).toList();
    final filteredRoots = _activeSuitFilter == null
        ? rootSkills
        : rootSkills.where((s) => s.suit == _activeSuitFilter).toList();

    // Stats calculation
    final totalSkills = widget.skills.length;
    final evolvedSkillsCount = widget.skills.where((s) => s.isEvolved).length;
    final totalLevels = widget.skills.fold<int>(0, (sum, s) => sum + s.level);

    String masteryTitle = '博雅启蒙者';
    if (totalLevels >= 25) {
      masteryTitle = '传奇全栈大师';
    } else if (totalLevels >= 15) {
      masteryTitle = '卓越领域学者';
    } else if (totalLevels >= 8) {
      masteryTitle = '多维进阶达人';
    }

    return Column(
      children: [
        // 顶部图鉴与成就统计栏 (Stats Bar)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.crown, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '科技树段位: $masteryTitle',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.purple.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '总等级 LV.$totalLevels',
                            style: const TextStyle(fontSize: 10, color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '已收录 $totalSkills 张技能牌 · 已完成 $evolvedSkillsCount 次高阶分支觉醒',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 花色领域筛选
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _activeSuitFilter == null
                    ? ShadBadge(child: const Text('全部科技树'))
                    : GestureDetector(
                        onTap: () => setState(() => _activeSuitFilter = null),
                        child: ShadBadge.outline(child: const Text('全部科技树')),
                      ),
              ),
              ...CardSuit.values.map((s) {
                final isSel = _activeSuitFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeSuitFilter = isSel ? null : s),
                    child: isSel
                        ? ShadBadge(child: Text('${s.symbol} ${s.label}'))
                        : ShadBadge.outline(
                            child: Text(
                              '${s.symbol} ${s.label}',
                              style: TextStyle(color: s.color),
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // 科技树网状流视图 (TreeView)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: filteredRoots.length,
            itemBuilder: (ctx, i) {
              final rootSkill = filteredRoots[i];
              // 找到所有由此技能演化出的高阶手牌
              final evolvedChildren = widget.skills
                  .where((s) => s.evolvedFromSkillId == rootSkill.id)
                  .toList();
              final availableOptions = rootSkill.evolutionOptions;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withAlpha(180),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: rootSkill.suit.color.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 领域标题
                    Row(
                      children: [
                        Icon(rootSkill.suit.icon, size: 16, color: rootSkill.suit.color),
                        const SizedBox(width: 6),
                        Text(
                          '${rootSkill.suit.label}科技谱系 · ${rootSkill.suit.domain}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rootSkill.suit.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 树状展示：父技能 -> 连接分支 -> 派生子牌/可觉醒节点
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // 左侧：父节点
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.withAlpha(40),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('根基核心 (Base Skill)', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                            ),
                            _buildSkillNode(rootSkill),
                          ],
                        ),

                        // 中间：演化连接指示
                        if (evolvedChildren.isNotEmpty || availableOptions.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 2,
                                color: Colors.amber.withAlpha(120),
                              ),
                              const Icon(LucideIcons.chevronRight, size: 16, color: Colors.amber),
                            ],
                          ),

                        // 右侧：演化出来的子牌与待演化分支
                        if (evolvedChildren.isNotEmpty || availableOptions.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(30),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('高阶派生分支 (Awakened Branches)', style: TextStyle(fontSize: 9, color: Colors.amber)),
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  // 已派生出来的卡牌
                                  ...evolvedChildren.map((c) => _buildSkillNode(c, isChild: true)),
                                  // 待演化选项
                                  ...availableOptions.map((opt) => _buildBranchOptionNode(rootSkill, opt)),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
