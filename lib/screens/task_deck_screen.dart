import 'package:flutter/material.dart';
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
    final formKey = GlobalKey<FormState>();
    String title = editingTask?.title ?? '';
    String description = editingTask?.description ?? '';
    CardSuit suit = editingTask?.suit ?? CardSuit.spades;
    int points = editingTask?.points ?? 3;
    String? skillId = editingTask?.requiredSkillId;
    DateTime? dueDate = editingTask?.dueDate;

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
                            editingTask != null ? '编辑任务卡牌' : '新增任务卡牌 (Task Card)',
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
                        initialValue: title,
                        decoration: const InputDecoration(
                          labelText: '任务名称 *',
                          hintText: '例如：重构核心逻辑、完成高强度间歇训练',
                          prefixIcon: Icon(Icons.style),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? '请输入任务名称' : null,
                        onSaved: (v) => title = v!.trim(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: description,
                        decoration: const InputDecoration(
                          labelText: '详细备注与交付标准',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 2,
                        onSaved: (v) => description = v?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),

                      // Suit selection
                      Text(
                        '任务扑克花色',
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
                            avatar: Text(
                              s.symbol,
                              style: TextStyle(
                                color: isSelected ? Colors.white : s.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            label: Text(s.label),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setSheetState(() => suit = s);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Points (1~11)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '精力与点数 (Points: 1~11)',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade700),
                            ),
                            child: Text(
                              '$points 点',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
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

                      // Link Skill Card
                      Text(
                        '关联加成技能',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        initialValue: skillId,
                        decoration: const InputDecoration(
                          hintText: '选择加成技能（完成后自动增加技能EXP）',
                          prefixIcon: Icon(Icons.auto_awesome),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('无特殊关联技能'),
                          ),
                          ...widget.allSkills.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Row(
                                children: [
                                  Text(s.suit.symbol,
                                      style: TextStyle(color: s.suit.color)),
                                  const SizedBox(width: 6),
                                  Text('${s.name} (LV.${s.level})'),
                                ],
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) => setSheetState(() => skillId = val),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          child: Text(editingTask != null ? '保存修改' : '放入任务卡库'),
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              formKey.currentState!.save();
                              final item = editingTask != null
                                  ? editingTask.copyWith(
                                      title: title,
                                      description: description,
                                      suit: suit,
                                      points: points,
                                      requiredSkillId: skillId,
                                      dueDate: dueDate,
                                    )
                                  : TaskCard(
                                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                                      title: title,
                                      description: description,
                                      suit: suit,
                                      points: points,
                                      requiredSkillId: skillId,
                                      dueDate: dueDate,
                                    );
                              widget.onAddTask(item);
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

  void _showAssignBlockModal(BuildContext context, TaskCard task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '将【${task.title}】打入牌桌时间块：',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...widget.timeBlocks.map((block) {
                  return ListTile(
                    leading: Icon(block.icon),
                    title: Text(block.title),
                    subtitle: Text(block.timeRange),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      widget.onAssignToBlock(block.id, task);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已打入时间块: ${block.title}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索任务卡牌...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),

          // Status & Suit Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('全部')),
                      ButtonSegment(value: 1, label: Text('待打出')),
                      ButtonSegment(value: 2, label: Text('已攻克')),
                    ],
                    selected: {_statusFilter},
                    onSelectionChanged: (s) =>
                        setState(() => _statusFilter = s.first),
                  ),
                ),
              ],
            ),
          ),

          // Suit chips
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: const Text('全花色'),
                    selected: _suitFilter == null,
                    onSelected: (s) {
                      if (s) setState(() => _suitFilter = null);
                    },
                  ),
                ),
                ...CardSuit.values.map((s) {
                  final isSelected = _suitFilter == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Text(
                        s.symbol,
                        style: TextStyle(
                          color: isSelected ? Colors.white : s.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: Text(s.label),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _suitFilter = val ? s : null);
                      },
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
                        const Icon(Icons.inbox_outlined, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('暂无符合条件的手牌'),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showAddEditDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('新增任务卡牌'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
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
                                icon: Icons.schedule,
                              ),
                            )
                          : null;

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: colorScheme.errorContainer,
                          child: Icon(Icons.delete, color: colorScheme.onErrorContainer),
                        ),
                        onDismissed: (_) => widget.onDeleteTask(task),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          elevation: task.isCompleted ? 0 : 1,
                          color: task.isCompleted
                              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                              : colorScheme.surface,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _showAddEditDialog(context, task),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) => widget.onToggleTask(task),
                                  ),
                                  // Suit Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: task.suit.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${task.suit.symbol} ${task.points}点',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: task.suit.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            decoration: task.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            task.description,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodySmall?.color
                                                  ?.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (task.requiredSkillId != null) ...[
                                              Icon(Icons.bolt, size: 12, color: task.suit.color),
                                              Text(
                                                skill.name,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: task.suit.color,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            if (isScheduled && block != null) ...[
                                              Icon(Icons.schedule, size: 12, color: Colors.blue.shade700),
                                              const SizedBox(width: 2),
                                              Text(
                                                block.title,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Assign button
                                  if (!task.isCompleted && !isScheduled)
                                    IconButton.filledTonal(
                                      icon: const Icon(Icons.outbox_rounded, size: 18),
                                      tooltip: '打入时间块',
                                      onPressed: () => _showAssignBlockModal(context, task),
                                    ),
                                ],
                              ),
                            ),
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
        icon: const Icon(Icons.add),
        label: const Text('新增任务卡'),
      ),
    );
  }
}
