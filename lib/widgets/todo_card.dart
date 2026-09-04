import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoCard extends StatelessWidget {
  final TodoItem todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCompleted = todo.isCompleted;

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        color: isCompleted
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surface,
        elevation: isCompleted ? 0 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: isCompleted,
                    onChanged: onToggle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isCompleted
                              ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: isCompleted ? 0.4 : 0.7,
                            ),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Tags & Info row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Points Badge (Blackjack Style)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCompleted
                                    ? Colors.grey.shade400
                                    : Colors.amber.shade700,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt,
                                  size: 13,
                                  color: isCompleted
                                      ? Colors.grey
                                      : Colors.amber.shade900,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${todo.points} 点',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted
                                      ? Colors.grey
                                      : Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: todo.category.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  todo.category.icon,
                                  size: 13,
                                  color: todo.category.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  todo.category.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: todo.category.color,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Priority Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: todo.priority.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              todo.priority.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: todo.priority.color,
                              ),
                            ),
                          ),

                          // Due Date
                          if (todo.dueDate != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_outlined,
                                  size: 13,
                                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${todo.dueDate!.month}月${todo.dueDate!.day}日',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing actions
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (sheetContext) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit_outlined),
                              title: const Text('编辑任务'),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                onTap();
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                isCompleted
                                    ? Icons.undo_outlined
                                    : Icons.check_circle_outline,
                              ),
                              title: Text(isCompleted ? '标记为未完成' : '标记为已完成'),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                onToggle(!isCompleted);
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: colorScheme.error,
                              ),
                              title: Text(
                                '删除任务',
                                style: TextStyle(color: colorScheme.error),
                              ),
                              onTap: () {
                                Navigator.pop(sheetContext);
                                onDelete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
