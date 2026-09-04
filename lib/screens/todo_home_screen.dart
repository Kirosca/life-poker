import 'dart:math';
import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../widgets/blackjack_meter.dart';
import '../widgets/todo_card.dart';
import 'add_edit_todo_sheet.dart';
import 'stats_dialog.dart';

enum TodoFilter { all, active, completed }

class TodoHomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const TodoHomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  // Sample initial todo items with Blackjack energy points
  final List<TodoItem> _todos = [
    TodoItem(
      id: '1',
      title: '完成 Flutter Material 3 架构设计',
      description: '统一组件规范、色彩与圆角设计',
      points: 7,
      category: TaskCategory.work,
      priority: TaskPriority.high,
      isCompleted: true,
      dueDate: DateTime.now(),
    ),
    TodoItem(
      id: '2',
      title: '晨间跑步 3 公里',
      description: '增强心肺活力，开启元气满满的一天',
      points: 4,
      category: TaskCategory.health,
      priority: TaskPriority.medium,
      isCompleted: true,
      dueDate: DateTime.now(),
    ),
    TodoItem(
      id: '3',
      title: '阅读《深度工作》一章节',
      description: '做好笔记，萃取核心心智模型',
      points: 5,
      category: TaskCategory.study,
      priority: TaskPriority.medium,
      isCompleted: false,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    TodoItem(
      id: '4',
      title: '给绿植浇水 & 整理工作台',
      description: '保持环境整洁清爽',
      points: 2,
      category: TaskCategory.life,
      priority: TaskPriority.low,
      isCompleted: false,
      dueDate: DateTime.now(),
    ),
  ];

  // Random deck for the "Hit" action (Micro-habits)
  final List<Map<String, dynamic>> _hitHabitsDeck = [
    {
      'title': '饮用一杯温开水',
      'desc': '补充水分，加速代谢',
      'points': 1,
      'category': TaskCategory.health,
    },
    {
      'title': '远眺窗外放松眼部 5 分钟',
      'desc': '缓解视觉疲劳',
      'points': 2,
      'category': TaskCategory.health,
    },
    {
      'title': '整理桌面杂物与文件',
      'desc': '打造专注清爽的工作空间',
      'points': 2,
      'category': TaskCategory.life,
    },
    {
      'title': '站立活动或拉伸全身 3 分钟',
      'desc': '激活筋骨，避免久坐僵硬',
      'points': 2,
      'category': TaskCategory.health,
    },
    {
      'title': '快速复盘今日最重要成果',
      'desc': '记录 1 件让自己自豪的小事',
      'points': 3,
      'category': TaskCategory.study,
    },
    {
      'title': '听一首喜爱的轻音乐',
      'desc': '调节情绪，沉浸放松',
      'points': 1,
      'category': TaskCategory.entertainment,
    },
  ];

  TodoFilter _currentFilter = TodoFilter.all;
  TaskCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Energy Points calculations
  int get _totalPlannedPoints =>
      _todos.fold<int>(0, (sum, item) => sum + item.points);

  int get _totalCompletedPoints => _todos
      .where((item) => item.isCompleted)
      .fold<int>(0, (sum, item) => sum + item.points);

  // Filtered todos
  List<TodoItem> get _filteredTodos {
    return _todos.where((item) {
      // Status filter
      if (_currentFilter == TodoFilter.active && item.isCompleted) return false;
      if (_currentFilter == TodoFilter.completed && !item.isCompleted) return false;

      // Category filter
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = item.title.toLowerCase().contains(query);
        final matchDesc = item.description.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    }).toList();
  }

  void _addOrUpdateTodo(TodoItem item) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        _todos[index] = item;
      } else {
        _todos.insert(0, item);
      }
    });
  }

  void _toggleTodo(TodoItem item, bool? value) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        _todos[index] = item.copyWith(isCompleted: value ?? false);
      }
    });
  }

  void _deleteTodo(TodoItem item) {
    final deleted = item;
    final deletedIndex = _todos.indexWhere((t) => t.id == item.id);

    setState(() {
      _todos.removeWhere((t) => t.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除: ${deleted.title}'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            setState(() {
              _todos.insert(deletedIndex, deleted);
            });
          },
        ),
      ),
    );
  }

  // Hit: Draw a card from habit deck
  void _onHit() {
    final random = Random();
    final habit = _hitHabitsDeck[random.nextInt(_hitHabitsDeck.length)];

    final newTodo = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: habit['title'] as String,
      description: habit['desc'] as String,
      points: habit['points'] as int,
      category: habit['category'] as TaskCategory,
      priority: TaskPriority.low,
      dueDate: DateTime.now(),
    );

    _addOrUpdateTodo(newTodo);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.style, color: Colors.amberAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🃏 抽中微习惯卡牌: ${newTodo.title} (+${newTodo.points}点)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stand: Lock in today's score
  void _onStand() {
    final points = _totalPlannedPoints;
    String message;
    IconData icon;

    if (points > 21) {
      message = '您当前规划为 $points 点，精力已爆牌 (Bust)！建议移除或延期部分任务。';
      icon = Icons.warning_rounded;
    } else if (points == 21) {
      message = '🎉 完美 21 点 (Blackjack)！精力配比已达黄金状态，全力冲刺吧！';
      icon = Icons.celebration_rounded;
    } else if (points >= 17) {
      message = '💪 当前规划 $points 点，是非常优秀的黄金专注区间。今日计划已锁定！';
      icon = Icons.thumb_up_alt_rounded;
    } else {
      message = '当前规划 $points 点，精力充足。还可以点击"Hit"继续抽取任务！';
      icon = Icons.info_outline;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('停牌锁定 (Stand)'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('明白'),
          ),
        ],
      ),
    );
  }

  void _openAddEditSheet([TodoItem? item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddEditTodoSheet(
        initialTodo: item,
        onSave: _addOrUpdateTodo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filtered = _filteredTodos;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索待办任务...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.checklist_rtl_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Life-Blackjack',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
            tooltip: _isSearching ? '关闭搜索' : '搜索任务',
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: '切换明暗模式',
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => StatsDialog(todos: _todos),
              );
            },
            tooltip: '查看数据与精力统计',
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'clear_completed') {
                setState(() {
                  _todos.removeWhere((t) => t.isCompleted);
                });
              } else if (action == 'reset_sample') {
                setState(() {
                  _todos.clear();
                  _todos.addAll([
                    TodoItem(
                      id: '1',
                      title: '完成 Flutter Material 3 架构设计',
                      points: 7,
                      category: TaskCategory.work,
                      priority: TaskPriority.high,
                      isCompleted: true,
                    ),
                    TodoItem(
                      id: '2',
                      title: '晨间慢跑 3 公里',
                      points: 4,
                      category: TaskCategory.health,
                      priority: TaskPriority.medium,
                      isCompleted: true,
                    ),
                    TodoItem(
                      id: '3',
                      title: '阅读《深度工作》一章节',
                      points: 5,
                      category: TaskCategory.study,
                      priority: TaskPriority.medium,
                    ),
                    TodoItem(
                      id: '4',
                      title: '保持办公桌面整洁',
                      points: 2,
                      category: TaskCategory.life,
                      priority: TaskPriority.low,
                    ),
                  ]);
                });
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('清理已完成任务'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset_sample',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('恢复示例数据'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 21-point Energy Meter at top
          BlackjackMeter(
            totalPoints: _totalPlannedPoints,
            completedPoints: _totalCompletedPoints,
            onHit: _onHit,
            onStand: _onStand,
          ),

          // Filters Row: Status Segmented Button + Category Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<TodoFilter>(
                    segments: const [
                      ButtonSegment(
                        value: TodoFilter.all,
                        label: Text('全部'),
                      ),
                      ButtonSegment(
                        value: TodoFilter.active,
                        label: Text('未完成'),
                      ),
                      ButtonSegment(
                        value: TodoFilter.completed,
                        label: Text('已完成'),
                      ),
                    ],
                    selected: {_currentFilter},
                    onSelectionChanged: (set) {
                      setState(() => _currentFilter = set.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Category Horizontal Scrollable Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('全部分类'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = null);
                    },
                  ),
                ),
                ...TaskCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        cat.icon,
                        size: 16,
                        color: isSelected ? colorScheme.onPrimary : cat.color,
                      ),
                      label: Text(cat.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Todo List or Empty State
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_outlined,
                          size: 64,
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '当前没有符合条件的待办任务',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _openAddEditSheet(),
                          icon: const Icon(Icons.add),
                          label: const Text('立即添加待办'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final item = filtered[index];
                      return TodoCard(
                        todo: item,
                        onToggle: (val) => _toggleTodo(item, val),
                        onTap: () => _openAddEditSheet(item),
                        onDelete: () => _deleteTodo(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditSheet(),
        icon: const Icon(Icons.add),
        label: const Text('新增待办'),
      ),
    );
  }
}
