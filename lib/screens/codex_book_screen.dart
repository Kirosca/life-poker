import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/codex_entry.dart';
import '../models/inventory_item.dart';
import '../models/poker_card.dart';

class CodexBookScreen extends StatefulWidget {
  final List<CodexEntry> entries;
  final List<SkillCard> allSkills;
  final List<InventoryItem> allAssets;
  final Function(String entryId, int itemIndex) onToggleChecklistItem;
  final Function(CodexEntry entry, String taskTitle) onCreateEventFromCodex;
  final Function(CodexEntry newEntry) onAddCodexEntry;
  final Function(String entryId) onDeleteCodexEntry;

  const CodexBookScreen({
    super.key,
    required this.entries,
    required this.allSkills,
    required this.allAssets,
    required this.onToggleChecklistItem,
    required this.onCreateEventFromCodex,
    required this.onAddCodexEntry,
    required this.onDeleteCodexEntry,
  });

  @override
  State<CodexBookScreen> createState() => _CodexBookScreenState();
}

class _CodexBookScreenState extends State<CodexBookScreen> {
  CodexDomain _selectedDomain = CodexDomain.clothing;
  RuleLevel? _selectedLevelFilter;
  String _searchQuery = '';
  final Set<String> _expandedEntryIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Filtered entries
    final domainEntries = widget.entries.where((e) {
      if (e.domain != _selectedDomain) return false;
      if (_selectedLevelFilter != null && e.level != _selectedLevelFilter) return false;
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchTitle = e.title.toLowerCase().contains(q);
        final matchSummary = e.summary.toLowerCase().contains(q);
        final matchContent = e.content.toLowerCase().contains(q);
        final matchTags = e.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchSummary && !matchContent && !matchTags) return false;
      }
      return true;
    }).toList();

    // Stats
    final allInDomain = widget.entries.where((e) => e.domain == _selectedDomain).toList();
    final ironCount = allInDomain.where((e) => e.level == RuleLevel.iron).length;
    final sopCount = allInDomain.where((e) => e.level == RuleLevel.sop).length;
    final insightCount = allInDomain.where((e) => e.level == RuleLevel.insight).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(LucideIcons.bookOpen, size: 20),
            SizedBox(width: 8),
            Text('衣食住行之书 (Life Codex)', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ShadButton.outline(
              size: ShadButtonSize.sm,
              leading: const Icon(LucideIcons.plus, size: 14),
              onPressed: _openAddEntryDialog,
              child: const Text('编纂新准则'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Four Volumes Tab Bar
                _buildVolumeTabs(theme),
                const SizedBox(height: 16),

                // 2. Volume Header & Stats Banner
                _buildVolumeBanner(theme, allInDomain.length, ironCount, sopCount, insightCount),
                const SizedBox(height: 20),

                // 3. Search & Filter Bar
                _buildFilterBar(theme),
                const SizedBox(height: 20),

                // 4. Codex Entries List
                if (domainEntries.isEmpty)
                  _buildEmptyState(theme)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: domainEntries.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (ctx, idx) {
                      return _buildCodexCard(theme, domainEntries[idx]);
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeTabs(ShadThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        return isMobile
            ? Column(
                children: CodexDomain.values.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildVolumeTabButton(d, isExpanded: true),
                )).toList(),
              )
            : Row(
                children: CodexDomain.values.map((d) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildVolumeTabButton(d),
                  ),
                )).toList(),
              );
      },
    );
  }

  Widget _buildVolumeTabButton(CodexDomain domain, {bool isExpanded = false}) {
    final isSelected = _selectedDomain == domain;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? domain.color.withAlpha(35) : Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? domain.color : Colors.white.withAlpha(20),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              _selectedDomain = domain;
              _selectedLevelFilter = null;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(domain.icon, size: 18, color: isSelected ? domain.color : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  domain.title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? domain.color : Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeBanner(
    ShadThemeData theme,
    int totalCount,
    int ironCount,
    int sopCount,
    int insightCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _selectedDomain.color.withAlpha(45),
                _selectedDomain.color.withAlpha(10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _selectedDomain.color.withAlpha(70)),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _selectedDomain.color.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_selectedDomain.icon, size: 24, color: _selectedDomain.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedDomain.title,
                                style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _selectedDomain.description,
                                style: theme.textTheme.muted.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildMiniBadge(RuleLevel.iron, '$ironCount 条铁律'),
                        _buildMiniBadge(RuleLevel.sop, '$sopCount 条SOP'),
                        _buildMiniBadge(RuleLevel.insight, '$insightCount 篇笔记'),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedDomain.color.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_selectedDomain.icon, size: 32, color: _selectedDomain.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _selectedDomain.title,
                                style: theme.textTheme.h4.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              ShadBadge.secondary(
                                child: Text('$totalCount 篇准则/笔记'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDomain.description,
                            style: theme.textTheme.muted.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildMiniBadge(RuleLevel.iron, '$ironCount 条铁律'),
                        _buildMiniBadge(RuleLevel.sop, '$sopCount 条SOP'),
                        _buildMiniBadge(RuleLevel.insight, '$insightCount 篇笔记'),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildMiniBadge(RuleLevel level, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: level.color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: level.color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(level.icon, size: 12, color: level.color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: level.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ShadThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;
        return isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShadInput(
                    placeholder: const Text('搜索准则标题、内容、标签...'),
                    leading: const Icon(LucideIcons.search, size: 16),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterPill('全部', _selectedLevelFilter == null, () {
                          setState(() => _selectedLevelFilter = null);
                        }),
                        const SizedBox(width: 6),
                        _buildFilterPill('🔴 铁律', _selectedLevelFilter == RuleLevel.iron, () {
                          setState(() => _selectedLevelFilter = RuleLevel.iron);
                        }),
                        const SizedBox(width: 6),
                        _buildFilterPill('🟡 SOP', _selectedLevelFilter == RuleLevel.sop, () {
                          setState(() => _selectedLevelFilter = RuleLevel.sop);
                        }),
                        const SizedBox(width: 6),
                        _buildFilterPill('🟢 笔记', _selectedLevelFilter == RuleLevel.insight, () {
                          setState(() => _selectedLevelFilter = RuleLevel.insight);
                        }),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: ShadInput(
                      placeholder: const Text('搜索准则标题、内容、标签...'),
                      leading: const Icon(LucideIcons.search, size: 16),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildFilterPill('全部', _selectedLevelFilter == null, () {
                    setState(() => _selectedLevelFilter = null);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterPill('🔴 铁律', _selectedLevelFilter == RuleLevel.iron, () {
                    setState(() => _selectedLevelFilter = RuleLevel.iron);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterPill('🟡 SOP', _selectedLevelFilter == RuleLevel.sop, () {
                    setState(() => _selectedLevelFilter = RuleLevel.sop);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterPill('🟢 笔记', _selectedLevelFilter == RuleLevel.insight, () {
                    setState(() => _selectedLevelFilter = RuleLevel.insight);
                  }),
                ],
              );
      },
    );
  }

  Widget _buildFilterPill(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withAlpha(25) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? Colors.white70 : Colors.white24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodexCard(ShadThemeData theme, CodexEntry entry) {
    final isExpanded = _expandedEntryIds.contains(entry.id);
    final relatedSkill = entry.relatedSkillId != null
        ? widget.allSkills.where((s) => s.id == entry.relatedSkillId).firstOrNull
        : null;
    final relatedAssets = widget.allAssets
        .where((a) => entry.relatedAssetIds.contains(a.id))
        .toList();

    return ShadCard(
      padding: const EdgeInsets.all(18),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: entry.level.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: entry.level.color.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(entry.level.icon, size: 12, color: entry.level.color),
                    const SizedBox(width: 4),
                    Text(
                      entry.level.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: entry.level.color,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions (Convert to Event Card + Delete)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShadButton.outline(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.sparkles, size: 13, color: Colors.amber),
                    onPressed: () => _promptCreateEventFromEntry(entry),
                    child: const Text('打成事件卡', style: TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 6),
                  ShadIconButton.ghost(
                    icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                    onPressed: () => widget.onDeleteCodexEntry(entry.id),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            entry.title,
            style: theme.textTheme.h4.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Summary
          Text(
            entry.summary,
            style: theme.textTheme.muted.copyWith(fontSize: 13),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags and associations
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...entry.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('#$tag', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  )),
              if (relatedSkill != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: relatedSkill.suit.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: relatedSkill.suit.color.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(relatedSkill.suit.icon, size: 10, color: relatedSkill.suit.color),
                      const SizedBox(width: 4),
                      Text('技能: ${relatedSkill.name}',
                          style: TextStyle(fontSize: 11, color: relatedSkill.suit.color)),
                    ],
                  ),
                ),
              ...relatedAssets.map((asset) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF3B82F6).withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(asset.icon, size: 10, color: const Color(0xFF60A5FA)),
                        const SizedBox(width: 4),
                        Text('装备: ${asset.name}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF93C5FD))),
                      ],
                    ),
                  )),
            ],
          ),

          // Checklist (if any)
          if (entry.checklist.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '执行准则清单 (${entry.checklistChecked.where((b) => b).length}/${entry.checklist.length})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      Text(
                        '实时记录遵守情况',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.mutedForeground),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(entry.checklist.length, (i) {
                    final isChecked = i < entry.checklistChecked.length && entry.checklistChecked[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isChecked ? Colors.green.withAlpha(15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () => widget.onToggleChecklistItem(entry.id, i),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    isChecked ? LucideIcons.checkSquare : LucideIcons.square,
                                    size: 16,
                                    color: isChecked ? Colors.greenAccent : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.checklist[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                        color: isChecked ? Colors.white38 : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // Detailed Content (Expandable)
          const SizedBox(height: 12),
          if (isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(60),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Text(
                entry.content,
                style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Toggle Expand Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ShadButton.ghost(
                size: ShadButtonSize.sm,
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedEntryIds.remove(entry.id);
                    } else {
                      _expandedEntryIds.add(entry.id);
                    }
                  });
                },
                trailing: Icon(
                  isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 14,
                ),
                child: Text(
                  isExpanded ? '收起详述' : '展开阅读完整准则',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ShadThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        children: [
          Icon(_selectedDomain.icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text('《${_selectedDomain.title}》暂无符合条件的条目', style: theme.textTheme.h4),
          const SizedBox(height: 6),
          Text('点击右上角「编纂新准则」，记录属于你的人生操作规范与哲学', style: theme.textTheme.muted),
        ],
      ),
    );
  }

  void _promptCreateEventFromEntry(CodexEntry entry) {
    showShadDialog(
      context: context,
      builder: (ctx) {
        return ShadDialog(
          title: const Text('转化准则为 Life-Poker 事件卡牌'),
          description: Text('将《${entry.title}》转化为牌桌待办手牌，注入牌桌时间块中执行。'),
          actions: [
            ShadButton.outline(
              child: const Text('取消'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ShadButton(
              child: const Text('立即生成事件卡'),
              onPressed: () {
                widget.onCreateEventFromCodex(entry, entry.title);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已打入事件手牌库！准则「${entry.title}」已生成为事件卡牌。'),
                  ),
                );
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '卡牌概要：${entry.summary}\n准则级别：${entry.level.label}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        );
      },
    );
  }

  void _openAddEntryDialog() {
    String title = '';
    String summary = '';
    String content = '';
    String tagsStr = '';
    String checklistStr = '';
    RuleLevel level = RuleLevel.sop;
    String? selectedSkillId;

    showShadDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ShadDialog(
              title: Text('编纂《${_selectedDomain.title}》新准则'),
              description: const Text('记录关于此维度的生活哲学、硬性要求或标准操作流程 (SOP)。'),
              actions: [
                ShadButton.outline(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ShadButton(
                  child: const Text('录入典籍'),
                  onPressed: () {
                    if (title.trim().isEmpty) return;
                    final tags = tagsStr
                        .split(RegExp(r'[,，\s]+'))
                        .where((s) => s.isNotEmpty)
                        .toList();
                    final checklist = checklistStr
                        .split('\n')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    final newEntry = CodexEntry(
                      id: 'codex_${DateTime.now().millisecondsSinceEpoch}',
                      domain: _selectedDomain,
                      title: title.trim(),
                      summary: summary.trim().isEmpty ? title.trim() : summary.trim(),
                      content: content.trim().isEmpty ? summary.trim() : content.trim(),
                      level: level,
                      tags: tags,
                      checklist: checklist,
                      relatedSkillId: selectedSkillId,
                      relatedAssetIds: [],
                    );

                    widget.onAddCodexEntry(newEntry);
                    Navigator.pop(ctx);
                  },
                ),
              ],
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 准则级别
                      const Text('准则权威级别', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Row(
                        children: RuleLevel.values.map((lvl) {
                          final isSelected = level == lvl;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? lvl.color.withAlpha(40) : Colors.white.withAlpha(10),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? lvl.color : Colors.white24,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => setDialogState(() => level = lvl),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(lvl.icon, size: 12, color: lvl.color),
                                          const SizedBox(width: 4),
                                          Text(
                                            lvl.label,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? lvl.color : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // 标题
                      const Text('准则名称 / 规范标题', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      ShadInput(
                        placeholder: const Text('如：极简胶囊衣橱配方、黄金睡眠环境控制'),
                        onChanged: (val) => title = val,
                      ),
                      const SizedBox(height: 12),

                      // 一句话摘要
                      const Text('核心准则一句话总结', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      ShadInput(
                        placeholder: const Text('如：室温控制在 20 度，睡前 1 小时严禁进食高糖'),
                        onChanged: (val) => summary = val,
                      ),
                      const SizedBox(height: 12),

                      // 详细内容
                      const Text('详细知识要求 / 操作步骤规范', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      ShadInput(
                        maxLines: 4,
                        placeholder: const Text('详述该领域的个人要求、清洗保养规则或执行流程...'),
                        onChanged: (val) => content = val,
                      ),
                      const SizedBox(height: 12),

                      // 检查清单
                      const Text('可打勾执行项 (每行一项)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      ShadInput(
                        maxLines: 3,
                        placeholder: const Text('睡前开启加湿器\n关闭全部发光电源\n手机留在书房充电'),
                        onChanged: (val) => checklistStr = val,
                      ),
                      const SizedBox(height: 12),

                      // 标签
                      const Text('标签分类 (空格或逗号隔开)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      ShadInput(
                        placeholder: const Text('胶囊衣橱 材质保养 极简'),
                        onChanged: (val) => tagsStr = val,
                      ),
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
}
