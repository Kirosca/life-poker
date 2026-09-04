import 'dart:math';
import 'package:flutter/material.dart';
import '../models/poker_card.dart';
import 'poker_table_screen.dart';
import 'task_deck_screen.dart';
import 'skill_deck_screen.dart';
import '../widgets/blackjack_meter.dart';

class MainPokerAppScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainPokerAppScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainPokerAppScreen> createState() => _MainPokerAppScreenState();
}

class _MainPokerAppScreenState extends State<MainPokerAppScreen> {
  int _currentTabIndex = 0;

  // Default initial skills (Deck)
  final List<SkillCard> _skills = [
    SkillCard(
      id: 'skill_1',
      name: 'Flutter & 架构设计',
      suit: CardSuit.spades,
      level: 3,
      exp: 140,
      description: '掌握声明式 UI、状态管理与跨平台架构',
    ),
    SkillCard(
      id: 'skill_2',
      name: '晨跑与耐力训练',
      suit: CardSuit.hearts,
      level: 2,
      exp: 80,
      description: '保持高心肺活力与充沛精力储备',
    ),
    SkillCard(
      id: 'skill_3',
      name: '深度阅读与写作',
      suit: CardSuit.clubs,
      level: 2,
      exp: 110,
      description: '精炼认知模型，输出高质量思考成果',
    ),
    SkillCard(
      id: 'skill_4',
      name: '商业与项目交付',
      suit: CardSuit.diamonds,
      level: 1,
      exp: 60,
      description: '把控交付节奏，推动产品落地与商业价值',
    ),
  ];

  // Default initial time blocks (Poker Table Slots)
  final List<TimeBlock> _timeBlocks = [
    TimeBlock(
      id: 'tb_morning',
      title: '晨间启动与活力蓄能',
      timeRange: '07:30 - 09:00',
      icon: Icons.wb_sunny_outlined,
      recommendedCapacity: 5,
    ),
    TimeBlock(
      id: 'tb_deepwork',
      title: '上午黄金心流区 (深度攻坚)',
      timeRange: '09:00 - 12:00',
      icon: Icons.psychology,
      recommendedCapacity: 8,
    ),
    TimeBlock(
      id: 'tb_afternoon',
      title: '下午高效推进与执行',
      timeRange: '14:00 - 17:30',
      icon: Icons.speed_outlined,
      recommendedCapacity: 6,
    ),
    TimeBlock(
      id: 'tb_evening',
      title: '晚间复盘与充电休息',
      timeRange: '20:00 - 22:00',
      icon: Icons.nightlight_outlined,
      recommendedCapacity: 4,
    ),
  ];

  // Default initial Task Cards
  final List<TaskCard> _tasks = [
    TaskCard(
      id: 't1',
      title: '完成 Life-Poker 牌桌时间块架构',
      description: '实现技能卡、任务卡与时间块无缝联动',
      suit: CardSuit.spades,
      points: 7,
      requiredSkillId: 'skill_1',
      scheduledBlockId: 'tb_deepwork',
      isCompleted: true,
    ),
    TaskCard(
      id: 't2',
      title: '户外慢跑 5 公里',
      description: '晨间有氧，释放多巴胺',
      suit: CardSuit.hearts,
      points: 4,
      requiredSkillId: 'skill_2',
      scheduledBlockId: 'tb_morning',
      isCompleted: true,
    ),
    TaskCard(
      id: 't3',
      title: '研读认知心理学经典章节',
      description: '整理 3 条核心心智模型',
      suit: CardSuit.clubs,
      points: 5,
      requiredSkillId: 'skill_3',
      scheduledBlockId: 'tb_evening',
      isCompleted: false,
    ),
    TaskCard(
      id: 't4',
      title: '梳理本周产品发布路线图',
      description: '明确各关键节点与预期交付产物',
      suit: CardSuit.diamonds,
      points: 3,
      requiredSkillId: 'skill_4',
      scheduledBlockId: 'tb_afternoon',
      isCompleted: false,
    ),
    TaskCard(
      id: 't5',
      title: '整理代码仓库与 CI 流程',
      suit: CardSuit.spades,
      points: 3,
      requiredSkillId: 'skill_1',
      isCompleted: false,
    ),
  ];

  // Habit card deck for Blackjack "Hit"
  final List<Map<String, dynamic>> _hitDeck = [
    {'title': '慢饮一杯温水', 'suit': CardSuit.hearts, 'pts': 1},
    {'title': '远眺护眼与全身伸展', 'suit': CardSuit.hearts, 'pts': 2},
    {'title': '整理桌面杂物营造整洁气场', 'suit': CardSuit.diamonds, 'pts': 2},
    {'title': '速记 1 条即时生活灵感', 'suit': CardSuit.clubs, 'pts': 1},
    {'title': '快速检查当日核心优先级', 'suit': CardSuit.spades, 'pts': 2},
  ];

  // Logic: Toggle Task completion & reward Skill EXP
  void _toggleTask(TaskCard task) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        final newStatus = !_tasks[idx].isCompleted;
        _tasks[idx] = _tasks[idx].copyWith(isCompleted: newStatus);

        // If completed and linked to a skill, give EXP!
        if (newStatus && task.requiredSkillId != null) {
          final skillIdx =
              _skills.indexWhere((s) => s.id == task.requiredSkillId);
          if (skillIdx != -1) {
            final prevLevel = _skills[skillIdx].level;
            _skills[skillIdx].addExp(task.points * 10);
            final newLevel = _skills[skillIdx].level;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  newLevel > prevLevel
                      ? '🎉 技能【${_skills[skillIdx].name}】升级到 LV.$newLevel！'
                      : '✨ 技能【${_skills[skillIdx].name}】获得 +${task.points * 10} EXP！',
                ),
              ),
            );
          }
        }
      }
    });
  }

  void _assignTaskToBlock(String blockId, TaskCard task) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = _tasks[idx].copyWith(scheduledBlockId: blockId);
      }
    });
  }

  void _removeTaskFromBlock(TaskCard task) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = _tasks[idx].copyWith(scheduledBlockId: null);
      }
    });
  }

  void _addTask(TaskCard task) {
    setState(() {
      final idx = _tasks.indexWhere((t) => t.id == task.id);
      if (idx != -1) {
        _tasks[idx] = task;
      } else {
        _tasks.insert(0, task);
      }
    });
  }

  void _deleteTask(TaskCard task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }

  void _addSkill(SkillCard skill) {
    setState(() {
      _skills.add(skill);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已解锁新技能卡牌: ${skill.name}')),
    );
  }

  void _trainSkill(SkillCard skill) {
    setState(() {
      final idx = _skills.indexWhere((s) => s.id == skill.id);
      if (idx != -1) {
        final prevL = _skills[idx].level;
        _skills[idx].addExp(25);
        final newL = _skills[idx].level;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              newL > prevL
                  ? '👑 技能突破！【${skill.name}】提升至 LV.$newL！'
                  : '📖 研习专注！【${skill.name}】+25 EXP',
            ),
          ),
        );
      }
    });
  }

  // Hit: Draw a micro-habit task
  void _onHit() {
    final random = Random();
    final item = _hitDeck[random.nextInt(_hitDeck.length)];
    final newTask = TaskCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: item['title'] as String,
      suit: item['suit'] as CardSuit,
      points: item['pts'] as int,
      scheduledBlockId: 'tb_morning', // default to morning slot
    );
    _addTask(newTask);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('🃏 抽中微行动手牌: ${newTask.title} (+${newTask.points}点)'),
      ),
    );
  }

  // Stand: Lock in today's commitments
  void _onStand() {
    final totalPts = _tasks
        .where((t) => t.scheduledBlockId != null)
        .fold<int>(0, (s, t) => s + t.points);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.amber),
            SizedBox(width: 8),
            Text('牌桌锁定 (Stand)'),
          ],
        ),
        content: Text(
          totalPts > 21
              ? '今日时间块总点数已达 $totalPts 点，已处于精力超载状态 (Bust)！建议移除部分任务。'
              : totalPts == 21
                  ? '🎉 完美 21 点 (Blackjack)！今日时间块精力配比已臻巅峰黄金比例！'
                  : '今日时间块已规划 $totalPts / 21 点，配比健康充沛，专注打好这手牌吧！',
        ),
        actions: [
          TextButton(
            child: const Text('确定'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget body;
    switch (_currentTabIndex) {
      case 0:
        body = PokerTableScreen(
          timeBlocks: _timeBlocks,
          allTasks: _tasks,
          allSkills: _skills,
          onToggleTask: _toggleTask,
          onAssignTaskToBlock: _assignTaskToBlock,
          onRemoveTaskFromBlock: _removeTaskFromBlock,
          onHit: _onHit,
          onStand: _onStand,
        );
        break;
      case 1:
        body = TaskDeckScreen(
          tasks: _tasks,
          allSkills: _skills,
          timeBlocks: _timeBlocks,
          onToggleTask: _toggleTask,
          onAddTask: _addTask,
          onDeleteTask: _deleteTask,
          onAssignToBlock: _assignTaskToBlock,
        );
        break;
      case 2:
        body = SkillDeckScreen(
          skills: _skills,
          onAddSkill: _addSkill,
          onTrainSkill: _trainSkill,
        );
        break;
      case 3:
      default:
        // Blackjack & Stats View
        final scheduled = _tasks.where((t) => t.scheduledBlockId != null).toList();
        final totalPts = scheduled.fold<int>(0, (s, t) => s + t.points);
        final completedPts = scheduled
            .where((t) => t.isCompleted)
            .fold<int>(0, (s, t) => s + t.points);

        body = ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '♠️ 21点精力预算机制 (副功能)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlackjackMeter(
              totalPoints: totalPts,
              completedPoints: completedPts,
              onHit: _onHit,
              onStand: _onStand,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '牌桌规则哲学',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. 时间块即卡槽：将今日任务卡打入对应时间块中，形成出牌组合。\n'
                      '2. 21点精力上限：打入各时间块的任务点数之和建议保持在 16~21 点，防止精力超载 (Bust)。\n'
                      '3. 技能协同：任务完成后将自动为绑定的技能卡积累 EXP 经验，推动技能升级！',
                      style: TextStyle(fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.style, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Life-Poker',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: '切换明暗模式',
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: '牌桌时间块',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl_outlined),
            selectedIcon: Icon(Icons.checklist_rtl),
            label: '任务卡库',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: '技能卡组',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt),
            label: '21点精力',
          ),
        ],
      ),
    );
  }
}
