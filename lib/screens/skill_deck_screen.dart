import 'package:flutter/material.dart';
import '../models/poker_card.dart';
import '../widgets/skill_card_widget.dart';

class SkillDeckScreen extends StatefulWidget {
  final List<SkillCard> skills;
  final ValueChanged<SkillCard> onAddSkill;
  final ValueChanged<SkillCard> onTrainSkill;

  const SkillDeckScreen({
    super.key,
    required this.skills,
    required this.onAddSkill,
    required this.onTrainSkill,
  });

  @override
  State<SkillDeckScreen> createState() => _SkillDeckScreenState();
}

class _SkillDeckScreenState extends State<SkillDeckScreen> {
  CardSuit? _selectedSuit;

  void _showAddSkillDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    CardSuit suit = CardSuit.spades;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '新增技能手牌 (Skill Card)',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '技能名称 *',
                          hintText: '例如：Flutter 架构设计、自由泳、英文写作',
                          prefixIcon: Icon(Icons.psychology),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? '请输入技能名称' : null,
                        onSaved: (v) => name = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '技能描述与掌握目标',
                          hintText: '设定此技能的关键指标...',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 2,
                        onSaved: (v) => description = v?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '选择扑克花色领域',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: CardSuit.values.map((s) {
                          final isSelected = suit == s;
                          return ChoiceChip(
                            avatar: Text(s.symbol,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : s.color,
                                  fontWeight: FontWeight.bold,
                                )),
                            label: Text('${s.label} (${s.domain})'),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setSheetState(() => suit = s);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          child: const Text('解锁技能卡牌'),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              formKey.currentState!.save();
                              final newSkill = SkillCard(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                name: name,
                                suit: suit,
                                description: description,
                              );
                              widget.onAddSkill(newSkill);
                              Navigator.pop(ctx);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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
    final filteredSkills = _selectedSuit == null
        ? widget.skills
        : widget.skills.where((s) => s.suit == _selectedSuit).toList();

    return Scaffold(
      body: Column(
        children: [
          // Filter by Suit chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('全部技能'),
                    selected: _selectedSuit == null,
                    onSelected: (s) {
                      if (s) setState(() => _selectedSuit = null);
                    },
                  ),
                ),
                ...CardSuit.values.map((s) {
                  final isSelected = _selectedSuit == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Text(
                        s.symbol,
                        style: TextStyle(
                          color: isSelected ? Colors.white : s.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: Text('${s.label} · ${s.domain}'),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _selectedSuit = val ? s : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Skills Grid View
          Expanded(
            child: filteredSkills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.style, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('暂无该分类技能卡牌'),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddSkillDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('解锁新技能卡'),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 320,
                      childAspectRatio: 0.88,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredSkills.length,
                    itemBuilder: (ctx, i) {
                      final skill = filteredSkills[i];
                      return SkillCardWidget(
                        skill: skill,
                        onTrain: () => widget.onTrainSkill(skill),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSkillDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('解锁技能'),
      ),
    );
  }
}
