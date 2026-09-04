import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';

class TaskDeckScreen extends StatefulWidget {
  final List<TaskCard> tasks;
  final List<SkillCard> allSkills;
  final List<TimeBlock> timeBlocks;
  final ValueChanged<TaskCard> onToggleTask;
  final ValueChanged<TaskCard> onAddTask;
  final ValueChanged<TaskCard> onDeleteTask;
  final Function(String blockId, TaskCard task) onAssignToBlock;

  const TaskDeckScreen({
    super.key,
    required this.tasks,
    required this.allSkills,
    required this.timeBlocks,
    required this.onToggleTask,
    required this.onAddTask,
    required this.onDeleteTask,
    required this.onAssignToBlock,
  });

  @override
  State<TaskDeckScreen> createState() => _TaskDeckScreenState();
}

class _TaskDeckScreenState extends State<TaskDeckScreen> {
  int _statusFilter = 0; // 0: All, 1: Active, 2: Completed
  CardSuit? _suitFilter;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, [TaskCard? editingTask]) {
    final titleCtrl = TextEditingController(text: editingTask?.title ?? '');
    final descCtrl = TextEditingController(text: editingTask?.description ?? '');
    CardSuit suit = editingTask?.suit ?? CardSuit.spades;
    int points = editingTask?.points ?? 3;
    String? skillId = editingTask?.requiredSkillId;

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
                          editingTask != null ? '编辑任务卡牌' : '新增任务卡牌 (Task Card)',
                          style: theme.textTheme.h4,
                        ),
                        ShadIconButton.ghost(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('任务名称 *', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: titleCtrl,
                      placeholder: const Text('例如：重构核心逻辑、完成间歇训练'),
                    ),
                    const SizedBox(height: 14),
                    Text('详细备注与交付标准', style: theme.textTheme.muted.copyWith(fontSize: 12)),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: descCtrl,
                      placeholder: const Text('选填：交付目标与细节...'),
                    ),
                    const SizedBox(height: 16),

                    // Suit selection
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
                    const SizedBox(height: 16),

                    // Points Slider (1~11)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('精力点数 (Points: 1~11)', style: theme.textTheme.muted.copyWith(fontSize: 12)),
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

                    // Link Skill
                    Text('关联加成技能', style: theme.textTheme.muted.copyWith(fontSize: 12)),
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
                        final item = editingTask != null
                            ? editingTask.copyWith(
                                title: text,
                                description: descCtrl.text.trim(),
                                suit: suit,
                                points: points,
                                requiredSkillId: skillId,
                              )
                            : TaskCard(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: text,
                                description: descCtrl.text.trim(),
                                suit: suit,
                                points: points,
                                requiredSkillId: skillId,
                              );
                        widget.onAddTask(item);
                        Navigator.pop(ctx);
                      },
                      child: Text(editingTask != null ? '保存修改' : '放入任务卡库'),
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

  void _showAssignBlockModal(BuildContext context, TaskCard task) {
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
                  '将【${task.title}】打入时间块：',
                  style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...widget.timeBlocks.map((block) {
                  return ListTile(
                    leading: Icon(block.icon, size: 20),
                    title: Text(block.title, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(block.timeRange, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(LucideIcons.chevronRight, size: 16),
                    onTap: () {
                      widget.onAssignToBlock(block.id, task);
                      Navigator.pop(ctx);
                    },
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

    final filtered = widget.tasks.where((t) {
      if (_statusFilter == 1 && t.isCompleted) return false;
      if (_statusFilter == 2 && !t.isCompleted) return false;
      if (_suitFilter != null && t.suit != _suitFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !t.description.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: ShadInput(
              controller: _searchCtrl,
              placeholder: const Text('搜索任务手牌...'),
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

          // Status Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _statusFilter == 0
                          ? ShadButton(
                              size: ShadButtonSize.sm,
                              child: const Text('全部'),
                              onPressed: () {},
                            )
                          : ShadButton.ghost(
                              size: ShadButtonSize.sm,
                              child: const Text('全部'),
                              onPressed: () => setState(() => _statusFilter = 0),
                            ),
                      const SizedBox(width: 6),
                      _statusFilter == 1
                          ? ShadButton(
                              size: ShadButtonSize.sm,
                              child: const Text('待打出'),
                              onPressed: () {},
                            )
                          : ShadButton.ghost(
                              size: ShadButtonSize.sm,
                              child: const Text('待打出'),
                              onPressed: () => setState(() => _statusFilter = 1),
                            ),
                      const SizedBox(width: 6),
                      _statusFilter == 2
                          ? ShadButton(
                              size: ShadButtonSize.sm,
                              child: const Text('已攻克'),
                              onPressed: () {},
                            )
                          : ShadButton.ghost(
                              size: ShadButtonSize.sm,
                              child: const Text('已攻克'),
                              onPressed: () => setState(() => _statusFilter = 2),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Suit Chips
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

          // Task List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.inbox, size: 40, color: theme.colorScheme.mutedForeground),
                        const SizedBox(height: 10),
                        Text('暂无符合条件的手牌', style: theme.textTheme.p),
                        const SizedBox(height: 8),
                        ShadButton.outline(
                          size: ShadButtonSize.sm,
                          leading: const Icon(LucideIcons.plus, size: 14),
                          onPressed: () => _showAddEditDialog(context),
                          child: const Text('新增任务卡牌'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final task = filtered[i];
                      final skill = widget.allSkills.firstWhere(
                        (s) => s.id == task.requiredSkillId,
                        orElse: () => SkillCard(
                          id: 'none',
                          name: '通用',
                          suit: task.suit,
                        ),
                      );

                      final isScheduled = task.scheduledBlockId != null;
                      final block = isScheduled
                          ? widget.timeBlocks.firstWhere(
                              (b) => b.id == task.scheduledBlockId,
                              orElse: () => TimeBlock(
                                id: '',
                                title: '未知时间块',
                                timeRange: '',
                                icon: LucideIcons.clock,
                              ),
                            )
                          : null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShadCard(
                          padding: const EdgeInsets.all(12),
                          title: Row(
                            children: [
                              ShadCheckbox(
                                value: task.isCompleted,
                                onChanged: (_) => widget.onToggleTask(task),
                              ),
                              const SizedBox(width: 8),
                              ShadBadge.secondary(
                                child: Text(
                                  '${task.suit.symbol} ${task.points}点',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: task.suit.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: theme.textTheme.p.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: task.isCompleted
                                            ? theme.colorScheme.mutedForeground
                                            : null,
                                      ),
                                    ),
                                    if (task.description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        task.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.muted.copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!task.isCompleted && !isScheduled)
                                ShadButton.outline(
                                  size: ShadButtonSize.sm,
                                  leading: const Icon(LucideIcons.arrowUpRight, size: 14),
                                  onPressed: () => _showAssignBlockModal(context, task),
                                  child: const Text('出牌'),
                                ),
                              ShadIconButton.ghost(
                                icon: const Icon(LucideIcons.trash2, size: 14),
                                onPressed: () => widget.onDeleteTask(task),
                              ),
                            ],
                          ),
                          description: Row(
                            children: [
                              if (task.requiredSkillId != null) ...[
                                Text(
                                  '加成: ${skill.name} (LV.${skill.level})',
                                  style: TextStyle(fontSize: 11, color: task.suit.color),
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
        label: const Text('新增任务卡'),
      ),
    );
  }
}
