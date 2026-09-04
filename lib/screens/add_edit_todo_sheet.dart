import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class AddEditTodoSheet extends StatefulWidget {
  final TodoItem? initialTodo;
  final ValueChanged<TodoItem> onSave;

  const AddEditTodoSheet({
    super.key,
    this.initialTodo,
    required this.onSave,
  });

  @override
  State<AddEditTodoSheet> createState() => _AddEditTodoSheetState();
}

class _AddEditTodoSheetState extends State<AddEditTodoSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late int _points;
  late TaskCategory _category;
  late TaskPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final todo = widget.initialTodo;
    _title = todo?.title ?? '';
    _description = todo?.description ?? '';
    _points = todo?.points ?? 3;
    _category = todo?.category ?? TaskCategory.life;
    _priority = todo?.priority ?? TaskPriority.medium;
    _dueDate = todo?.dueDate;
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      final item = widget.initialTodo != null
          ? widget.initialTodo!.copyWith(
              title: _title,
              description: _description,
              points: _points,
              category: _category,
              priority: _priority,
              dueDate: _dueDate,
            )
          : TodoItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _title,
              description: _description,
              points: _points,
              category: _category,
              priority: _priority,
              dueDate: _dueDate,
            );
      widget.onSave(item);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.initialTodo != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? '编辑待办任务' : '新增待办任务',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title Input
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: '任务名称 *',
                    hintText: '例如：阅读技术文献 30 分钟',
                    prefixIcon: Icon(Icons.check_box_outlined),
                  ),
                  autofocus: !isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入待办任务名称';
                    }
                    return null;
                  },
                  onSaved: (val) => _title = val!.trim(),
                ),
                const SizedBox(height: 14),

                // Description Input
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(
                    labelText: '详细备注 (选填)',
                    hintText: '添加任务关键细节或目标...',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 2,
                  onSaved: (val) => _description = val?.trim() ?? '',
                ),
                const SizedBox(height: 18),

                // Points Slider (Blackjack Energy Cost: 1 - 11)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '21点精力消耗 (Points)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Text(
                        '$_points 点',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _points.toDouble(),
                  min: 1,
                  max: 11,
                  divisions: 10,
                  label: '$_points 点',
                  onChanged: (val) {
                    setState(() {
                      _points = val.toInt();
                    });
                  },
                ),
                Text(
                  '1~3点: 微习惯/轻松任务 | 4~7点: 常规核心任务 | 8~11点: 重大攻坚战(高精力)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 18),

                // Category Selection
                Text(
                  '分类 (Category)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TaskCategory.values.map((cat) {
                    final isSelected = _category == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      avatar: Icon(
                        cat.icon,
                        size: 16,
                        color: isSelected ? colorScheme.onPrimary : cat.color,
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _category = cat);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Priority Selection
                Text(
                  '优先级 (Priority)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  segments: TaskPriority.values.map((p) {
                    return ButtonSegment<TaskPriority>(
                      value: p,
                      label: Text(p.label),
                    );
                  }).toList(),
                  selected: {_priority},
                  onSelectionChanged: (set) {
                    setState(() => _priority = set.first);
                  },
                ),
                const SizedBox(height: 18),

                // Due Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    _dueDate == null
                        ? '设置截止日期 (可选)'
                        : '截止日期: ${_dueDate!.year}年${_dueDate!.month}月${_dueDate!.day}日',
                  ),
                  trailing: _dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _dueDate = null),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _dueDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(isEditing ? '保存修改' : '确认添加'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
