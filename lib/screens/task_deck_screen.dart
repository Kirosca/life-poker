import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';

class TaskDeckScreen extends StatefulWidget {
  final List<EventCard> events;
  final List<SkillCard> allSkills;
  final List<TimeBlock> timeBlocks;
  final ValueChanged<EventCard> onToggleEvent;
  final ValueChanged<EventCard> onAddEvent;
  final ValueChanged<EventCard> onDeleteEvent;
  final Function(String blockId, EventCard event) onAssignToBlock;

  const TaskDeckScreen({
    super.key,
    required this.events,
    required this.allSkills,
    required this.timeBlocks,
    required this.onToggleEvent,
    required this.onAddEvent,
    required this.onDeleteEvent,
    required this.onAssignToBlock,
  });

  @override
  State<TaskDeckScreen> createState() => _TaskDeckScreenState();
}

class _TaskDeckScreenState extends State<TaskDeckScreen> {
  int _statusFilter = 0; // 0: All, 1: Urgent Only (紧迫), 2: Active (待办), 3: Completed (已攻克)
  CardSuit? _suitFilter;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, [EventCard? editingEvent]) {
    final titleCtrl = TextEditingController(text: editingEvent?.title ?? '');
    final descCtrl = TextEditingController(text: editingEvent?.description ?? '');
    CardSuit suit = editingEvent?.suit ?? CardSuit.spades;
    int points = editingEvent?.points ?? 3;
    bool isUrgent = editingEvent?.isUrgent ?? false;
    DateTime? deadline = editingEvent?.deadline;
    String? skillId = editingEvent?.requiredSkillId;

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
                          editingEvent != null ? '编辑事件卡牌' : '新增事件卡牌 (Event Card)',
                          style: theme.textTheme.h4,
                        ),
                        ShadIconButton.ghost(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 紧迫事件开关
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.redAccent.withValues(alpha: 0.1) : theme.colorScheme.muted.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isUrgent ? Colors.redAccent : theme.colorScheme.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.flame,
                                size: 18,
                                color: isUrgent ? Colors.redAccent : theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '未来紧迫事件卡 (Urgent Event)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isUrgent ? Colors.redAccent : null,
                                    ),
                                  ),
                                  Text(
                                    '开启后具有倒计时警报并在备战中置顶提示',
                                    style: theme.textTheme.muted.copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ShadSwitch(
                            value: isUrgent,
                            onChanged: (val) {
                              setSheetState(() {
                                isUrgent = val;
                                if (isUrgent && deadline == null) {
                                  deadline = DateTime.now().add(const Duration(days: 1));
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('事件名称 *', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: titleCtrl,
                      placeholder: const Text('例如：完成核心业务上线、备战体能测试'),
                    ),
                    const SizedBox(height: 14),
                    Text('详细要求与验收标准', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: descCtrl,
                      placeholder: const Text('选填：交付目标与细节...'),
                    ),
                    const SizedBox(height: 16),

                    // 截止日期选择
                    if (isUrgent) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('截止倒计时 (Deadline)', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                          ShadButton.outline(
                            size: ShadButtonSize.sm,
                            leading: const Icon(LucideIcons.calendar, size: 14),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: deadline ?? DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setSheetState(() => deadline = picked);
                              }
                            },
                            child: Text(
                              deadline != null
                                  ? '${deadline!.month}月${deadline!.day}日'
                                  : '选择截止日期',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 花色领域
                    Text('所属领域花色', style: theme.textTheme.muted.copyWith(fontSize: 12)),
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
                    const SizedBox(height: 16),

                    // 点数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('难度与耗能点数 (1~11)', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                        ShadBadge.secondary(
                          child: Text('$points 点', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Slider(
                      value: points.toDouble(),
                      min: 1,
                      max: 11,
                      divisions: 10,
                      onChanged: (val) {
                        setSheetState(() => points = val.toInt());
                      },
                    ),
                    const SizedBox(height: 12),

                    // 关联技能
                    Text('关联技能牌 (完成后注入EXP)', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: skillId,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.border),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('无特殊关联技能', style: TextStyle(fontSize: 13)),
                        ),
                        ...widget.allSkills.map((s) {
                          return DropdownMenuItem(
                            value: s.id,
                            child: Row(
                              children: [
                                Icon(s.suit.icon, size: 14, color: s.suit.color),
                                const SizedBox(width: 6),
                                Text('${s.name} (LV.${s.level})', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) => setSheetState(() => skillId = val),
                    ),
                    const SizedBox(height: 24),

                    ShadButton(
                      width: double.infinity,
                      onPressed: () {
                        final text = titleCtrl.text.trim();
                        if (text.isEmpty) return;
                        final item = editingEvent != null
                            ? editingEvent.copyWith(
                                title: text,
                                description: descCtrl.text.trim(),
                                suit: suit,
                                points: points,
                                isUrgent: isUrgent,
                                deadline: deadline,
                                requiredSkillId: skillId,
                              )
                            : EventCard(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: text,
                                description: descCtrl.text.trim(),
                                suit: suit,
                                points: points,
                                isUrgent: isUrgent,
                                deadline: deadline,
                                requiredSkillId: skillId,
                              );
                        widget.onAddEvent(item);
                        Navigator.pop(ctx);
                      },
                      child: Text(editingEvent != null ? '保存修改' : '放入事件卡库'),
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

  void _showAssignBlockModal(BuildContext context, EventCard event) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final theme = ShadTheme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '将【${event.title}】打入时间块：',
                  style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...widget.timeBlocks.map((block) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272A).withAlpha(140),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          widget.onAssignToBlock(block.id, event);
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Icon(block.icon, size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(block.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text(block.timeRange, style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                                  ],
                                ),
                              ),
                              const Icon(LucideIcons.chevronRight, size: 16, color: Color(0xFF71717A)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    final filtered = widget.events.where((e) {
      if (_statusFilter == 1 && (!e.isUrgent || e.isCompleted)) return false; // 紧迫事件
      if (_statusFilter == 2 && e.isCompleted) return false; // 待办
      if (_statusFilter == 3 && !e.isCompleted) return false; // 已攻克
      if (_suitFilter != null && e.suit != _suitFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!e.title.toLowerCase().contains(q) &&
            !e.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    // 默认让紧迫事件排在最前
    filtered.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return 0;
    });

    final urgentTotal = widget.events.where((e) => e.isUrgent && !e.isCompleted).length;

    return Scaffold(
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: ShadInput(
              controller: _searchCtrl,
              placeholder: const Text('搜索事件手牌...'),
              leading: const Icon(LucideIcons.search, size: 16),
              trailing: _search.isNotEmpty
                  ? ShadIconButton.ghost(
                      icon: const Icon(LucideIcons.x, size: 14),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    )
                  : null,
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),

          // 状态筛选 Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterButton(0, '全部'),
                  const SizedBox(width: 6),
                  _filterButton(1, '🔥 紧迫事件 ($urgentTotal)', isWarning: true),
                  const SizedBox(width: 6),
                  _filterButton(2, '待攻克'),
                  const SizedBox(width: 6),
                  _filterButton(3, '已完成'),
                ],
              ),
            ),
          ),

          // 花色筛选
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _suitFilter == null
                      ? ShadBadge(child: const Text('全花色'))
                      : GestureDetector(
                          onTap: () => setState(() => _suitFilter = null),
                          child: ShadBadge.outline(child: const Text('全花色')),
                        ),
                ),
                ...CardSuit.values.map((s) {
                  final isSelected = _suitFilter == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _suitFilter = isSelected ? null : s;
                        });
                      },
                      child: isSelected
                          ? ShadBadge(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(s.symbol),
                                  const SizedBox(width: 4),
                                  Text(s.label),
                                ],
                              ),
                            )
                          : ShadBadge.outline(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(s.symbol, style: TextStyle(color: s.color)),
                                  const SizedBox(width: 4),
                                  Text(s.label),
                                ],
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 事件卡列表
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.inbox, size: 40, color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 10),
                        Text('暂无符合条件的事件卡', style: theme.textTheme.p),
                        const SizedBox(height: 8),
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          leading: const Icon(LucideIcons.plus, size: 14),
                          onPressed: () => _showAddEditDialog(context),
                          child: const Text('新增事件卡牌'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final event = filtered[i];
                      final skill = widget.allSkills.firstWhere(
                        (s) => s.id == event.requiredSkillId,
                        orElse: () => SkillCard(
                          id: 'none',
                          name: '通用',
                          suit: event.suit,
                        ),
                      );

                      final isScheduled = event.scheduledBlockId != null;
                      final block = isScheduled
                          ? widget.timeBlocks.firstWhere(
                              (b) => b.id == event.scheduledBlockId,
                              orElse: () => TimeBlock(
                                id: '',
                                title: '未知时间块',
                                timeRange: '',
                                icon: LucideIcons.clock,
                              ),
                            )
                          : null;

                      final bool isUrgent = event.isUrgent && !event.isCompleted;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShadCard(
                          padding: const EdgeInsets.all(12),
                          title: Row(
                            children: [
                              ShadCheckbox(
                                value: event.isCompleted,
                                onChanged: (_) => widget.onToggleEvent(event),
                              ),
                              const SizedBox(width: 8),
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
                              if (!event.isCompleted && !isScheduled)
                                ShadButton.outline(
                                  size: ShadButtonSize.sm,
                                  leading: const Icon(LucideIcons.arrowUpRight, size: 14),
                                  onPressed: () => _showAssignBlockModal(context, event),
                                  child: const Text('出牌'),
                                ),
                              ShadIconButton.ghost(
                                icon: const Icon(LucideIcons.trash2, size: 14),
                                onPressed: () => widget.onDeleteEvent(event),
                              ),
                            ],
                          ),
                          description: Row(
                            children: [
                              if (event.requiredSkillId != null) ...[
                                Text(
                                  '加成技能: ${skill.name} (LV.${skill.level})',
                                  style: TextStyle(fontSize: 11, color: event.suit.color),
                                ),
                                const SizedBox(width: 10),
                              ],
                              if (isScheduled && block != null) ...[
                                Icon(LucideIcons.clock, size: 12, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  block.title,
                                  style: TextStyle(fontSize: 11, color: theme.colorScheme.primary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('新增事件卡'),
      ),
    );
  }

  Widget _filterButton(int index, String label, {bool isWarning = false}) {
    final isSelected = _statusFilter == index;
    if (isSelected) {
      return ShadButton(
        size: ShadButtonSize.sm,
        backgroundColor: isWarning ? Colors.redAccent : null,
        onPressed: () {},
        child: Text(label),
      );
    }
    return ShadButton.ghost(
      size: ShadButtonSize.sm,
      foregroundColor: isWarning ? Colors.redAccent : null,
      onPressed: () => setState(() => _statusFilter = index),
      child: Text(label),
    );
  }
}
