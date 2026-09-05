import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/poker_card.dart';
import '../models/inventory_item.dart';
import '../models/codex_entry.dart';
import 'poker_table_screen.dart';
import 'task_deck_screen.dart';
import 'skill_deck_screen.dart';
import 'vault_inventory_screen.dart';
import 'codex_book_screen.dart';
import 'blackjack_game_screen.dart';

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

  // 资产、消耗品背包与资金账户 (Phase 2)
  final List<InventoryItem> _inventoryItems = DefaultInventoryData.getInitialItems();
  final List<TransactionRecord> _transactions = DefaultInventoryData.getInitialTransactions();
  double _cashBalance = 15800.0;

  // 衣食住行之书 (Phase 3)
  final List<CodexEntry> _codexEntries = CodexEntry.getInitialEntries();

  // 技能卡组 (包含普通技能与特殊睡眠技能卡)
  final List<SkillCard> _skills = [
    SkillCard(
      id: 'skill_sleep',
      name: '睡眠恢复与节律',
      suit: CardSuit.hearts,
      level: 4,
      exp: 280,
      maxExp: 400,
      description: '保持规律作息与深层睡眠，激活次日全技能精力充沛',
      isSleepSkill: true,
      sleepDisciplineScore: 92,
    ),
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

  // 时间块骨架 (支持挂载 activeSkillId 技能卡槽)
  final List<TimeBlock> _timeBlocks = [
    TimeBlock(
      id: 'tb_morning',
      title: '晨间启动与活力蓄能',
      timeRange: '07:30 - 09:00',
      icon: LucideIcons.sunrise,
      recommendedCapacity: 5,
      activeSkillId: 'skill_2',
    ),
    TimeBlock(
      id: 'tb_deepwork',
      title: '上午黄金心流区 (深度攻坚)',
      timeRange: '09:00 - 12:00',
      icon: LucideIcons.brain,
      recommendedCapacity: 8,
      activeSkillId: 'skill_1',
    ),
    TimeBlock(
      id: 'tb_afternoon',
      title: '下午高效推进与执行',
      timeRange: '14:00 - 17:30',
      icon: LucideIcons.gauge,
      recommendedCapacity: 6,
      activeSkillId: 'skill_4',
    ),
    TimeBlock(
      id: 'tb_evening',
      title: '晚间复盘与充电休息',
      timeRange: '20:00 - 22:00',
      icon: LucideIcons.moon,
      recommendedCapacity: 4,
      activeSkillId: 'skill_3',
    ),
    TimeBlock(
      id: 'tb_sleep',
      title: '夜间深度睡眠恢复',
      timeRange: '23:00 - 07:00',
      icon: LucideIcons.bedDouble,
      recommendedCapacity: 0,
      activeSkillId: 'skill_sleep',
    ),
  ];

  // 初始事件卡手牌 (包含普通事件与未来紧迫事件)
  final List<EventCard> _events = [
    EventCard(
      id: 'e1',
      title: '线上生产服务 Bug 紧急修复',
      description: '排查高并发链路异常并发布热修复补丁',
      suit: CardSuit.spades,
      points: 7,
      isUrgent: true,
      deadline: DateTime.now().add(const Duration(hours: 4)),
      requiredSkillId: 'skill_1',
      scheduledBlockId: 'tb_deepwork',
      isCompleted: false,
    ),
    EventCard(
      id: 'e2',
      title: '体能达标测试准备跑',
      description: '配速 5分30秒 匀速慢跑 5 公里',
      suit: CardSuit.hearts,
      points: 4,
      isUrgent: false,
      requiredSkillId: 'skill_2',
      scheduledBlockId: 'tb_morning',
      isCompleted: true,
    ),
    EventCard(
      id: 'e3',
      title: '季度财务与收支对账',
      description: '核实企业及个人账户进出账目',
      suit: CardSuit.diamonds,
      points: 5,
      isUrgent: true,
      deadline: DateTime.now().add(const Duration(days: 1)),
      requiredSkillId: 'skill_4',
      scheduledBlockId: 'tb_afternoon',
      isCompleted: false,
    ),
    EventCard(
      id: 'e4',
      title: '精读《思考，快与慢》第3章',
      description: '提炼双系统认知启发并撰写笔记',
      suit: CardSuit.clubs,
      points: 3,
      isUrgent: false,
      requiredSkillId: 'skill_3',
      isCompleted: false,
    ),
  ];

  // 事件打钩完成：将 EXP 注入该时间块装配的主打技能牌！
  void _toggleEvent(EventCard event) {
    setState(() {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        final newStatus = !_events[idx].isCompleted;
        _events[idx] = _events[idx].copyWith(isCompleted: newStatus);

        if (newStatus) {
          // 优先为该时间块装配的技能注入经验；若无则为事件绑定的技能注入
          String? targetSkillId;
          if (event.scheduledBlockId != null) {
            final block = _timeBlocks.firstWhere(
              (b) => b.id == event.scheduledBlockId,
              orElse: () => _timeBlocks[0],
            );
            targetSkillId = block.activeSkillId ?? event.requiredSkillId;
          } else {
            targetSkillId = event.requiredSkillId;
          }

          if (targetSkillId != null) {
            final skillIdx = _skills.indexWhere((s) => s.id == targetSkillId);
            if (skillIdx != -1) {
              final prevLevel = _skills[skillIdx].level;
              _skills[skillIdx].addExp(event.points * 12);
              final newLevel = _skills[skillIdx].level;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    newLevel > prevLevel
                        ? '🎉 攻克事件！技能【${_skills[skillIdx].name}】升至 LV.$newLevel！'
                        : '✨ 攻克【${event.title}】！技能【${_skills[skillIdx].name}】+${event.points * 12} EXP',
                  ),
                ),
              );
            }
          }
        }
      }
    });
  }

  void _assignEventToBlock(String blockId, EventCard event) {
    setState(() {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        _events[idx] = _events[idx].copyWith(scheduledBlockId: blockId);
      }
    });
  }

  void _removeEventFromBlock(EventCard event) {
    setState(() {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        _events[idx] = _events[idx].copyWith(scheduledBlockId: null);
      }
    });
  }

  void _equipSkillToBlock(String blockId, String skillId) {
    setState(() {
      final idx = _timeBlocks.indexWhere((b) => b.id == blockId);
      if (idx != -1) {
        _timeBlocks[idx] = _timeBlocks[idx].copyWith(activeSkillId: skillId);
      }
    });
    final skill = _skills.firstWhere((s) => s.id == skillId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('已为时间块装配主打技能: 【${skill.name}】'),
      ),
    );
  }

  void _addEvent(EventCard event) {
    setState(() {
      final idx = _events.indexWhere((e) => e.id == event.id);
      if (idx != -1) {
        _events[idx] = event;
      } else {
        _events.insert(0, event);
      }
    });
  }

  void _deleteEvent(EventCard event) {
    setState(() {
      _events.removeWhere((e) => e.id == event.id);
    });
  }

  void _addSkill(SkillCard skill) {
    setState(() {
      _skills.add(skill);
    });
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
                  ? '👑 突破瓶颈！【${skill.name}】提升至 LV.$newL！'
                  : '📖 研习专注！【${skill.name}】+25 EXP',
            ),
          ),
        );
      }
    });
  }

  // ===================== 【资金与资产背包操作 (Phase 2)】 =====================
  void _onAddInventoryItem(InventoryItem item) {
    setState(() {
      _inventoryItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已成功登记新物品: 【${item.name}】')),
    );
  }

  void _onUpdateInventoryItem(InventoryItem item) {
    setState(() {
      final idx = _inventoryItems.indexWhere((i) => i.id == item.id);
      if (idx != -1) {
        _inventoryItems[idx] = item;
      }
    });
  }

  void _onDeleteInventoryItem(String itemId) {
    setState(() {
      _inventoryItems.removeWhere((i) => i.id == itemId);
    });
  }

  void _onAddTransaction(TransactionRecord tx) {
    setState(() {
      _transactions.insert(0, tx);
      if (tx.type == TransactionType.income) {
        _cashBalance += tx.amount;
      } else {
        _cashBalance -= tx.amount;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已入账: ${tx.title} (¥${tx.amount.toStringAsFixed(2)})')),
    );
  }

  void _onBindAssetToSkill(String assetId, String? skillId) {
    setState(() {
      final itemIdx = _inventoryItems.indexWhere((i) => i.id == assetId);
      if (itemIdx != -1) {
        final oldSkillId = _inventoryItems[itemIdx].boundSkillId;
        _inventoryItems[itemIdx] = _inventoryItems[itemIdx].copyWith(
          boundSkillId: skillId,
          unbindSkill: skillId == null,
        );

        // 更新技能列表中的 equippedAssetIds
        if (oldSkillId != null) {
          final oldSkillIdx = _skills.indexWhere((s) => s.id == oldSkillId);
          if (oldSkillIdx != -1) {
            _skills[oldSkillIdx].equippedAssetIds.remove(assetId);
          }
        }
        if (skillId != null) {
          final newSkillIdx = _skills.indexWhere((s) => s.id == skillId);
          if (newSkillIdx != -1 && !_skills[newSkillIdx].equippedAssetIds.contains(assetId)) {
            _skills[newSkillIdx].equippedAssetIds.add(assetId);
          }
        }
      }
    });

    final asset = _inventoryItems.firstWhere((i) => i.id == assetId);
    final targetSkill = skillId != null ? _skills.firstWhere((s) => s.id == skillId) : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          targetSkill != null
              ? '已将【${asset.name}】装备到技能【${targetSkill.name}】！'
              : '已卸下【${asset.name}】',
        ),
      ),
    );
  }

  void _onUseConsumableInBlock(String blockId, InventoryItem item) {
    if (item.quantity <= 0) return;

    setState(() {
      // 1. 消耗品数量 -1
      final itemIdx = _inventoryItems.indexWhere((i) => i.id == item.id);
      if (itemIdx != -1) {
        _inventoryItems[itemIdx] = item.copyWith(quantity: item.quantity - 1);
      }

      // 2. 将消耗品打入时间块
      final blockIdx = _timeBlocks.indexWhere((b) => b.id == blockId);
      if (blockIdx != -1) {
        if (!_timeBlocks[blockIdx].usedConsumableIds.contains(item.id)) {
          _timeBlocks[blockIdx].usedConsumableIds.add(item.id);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ 在【${_timeBlocks.firstWhere((b) => b.id == blockId).title}】打出【${item.name}】！获得增益状态！'),
      ),
    );
  }

  // ----------------- 衣食住行之书回调 (Phase 3) -----------------
  void _toggleCodexChecklistItem(String entryId, int itemIndex) {
    setState(() {
      final idx = _codexEntries.indexWhere((e) => e.id == entryId);
      if (idx != -1) {
        final entry = _codexEntries[idx];
        final updatedChecked = List<bool>.from(entry.checklistChecked);
        if (itemIndex < updatedChecked.length) {
          updatedChecked[itemIndex] = !updatedChecked[itemIndex];
          _codexEntries[idx] = entry.copyWith(checklistChecked: updatedChecked);
        }
      }
    });
  }

  void _createEventFromCodex(CodexEntry entry, String taskTitle) {
    CardSuit suit;
    switch (entry.domain) {
      case CodexDomain.clothing:
        suit = CardSuit.diamonds;
        break;
      case CodexDomain.food:
        suit = CardSuit.hearts;
        break;
      case CodexDomain.housing:
        suit = CardSuit.clubs;
        break;
      case CodexDomain.travel:
        suit = CardSuit.spades;
        break;
    }

    final newEvent = EventCard(
      id: 'event_codex_${DateTime.now().millisecondsSinceEpoch}',
      title: '【${entry.domain.title}】$taskTitle',
      suit: suit,
      points: entry.level == RuleLevel.iron ? 8 : (entry.level == RuleLevel.sop ? 5 : 3),
      isUrgent: entry.level == RuleLevel.iron,
      requiredSkillId: entry.relatedSkillId,
    );
    setState(() {
      _events.insert(0, newEvent);
    });
  }

  void _addCodexEntry(CodexEntry newEntry) {
    setState(() {
      _codexEntries.insert(0, newEntry);
    });
  }

  void _deleteCodexEntry(String entryId) {
    setState(() {
      _codexEntries.removeWhere((e) => e.id == entryId);
    });
  }

  // 晚间备战明日 (Nightly Prep) 对话框
  void _openNightlyPrepDialog() {
    final urgentPending = _events.where((e) => e.isUrgent && !e.isCompleted).toList();
    final theme = ShadTheme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.sparkles, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Text('晚间备战明日 (Nightly Prep)'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '检查明日牌桌骨架，并优先排入危机事件：',
                style: theme.textTheme.muted.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (urgentPending.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.flame, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '检测到 ${urgentPending.length} 项紧迫事件！',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...urgentPending.map((u) => Text('• ${u.title} (${u.countdownString})',
                          style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                '明日作息骨架：',
                style: theme.textTheme.p.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              ..._timeBlocks.take(4).map((b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(b.icon, size: 14),
                        const SizedBox(width: 6),
                        Text('${b.title} (${b.timeRange})', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍后调整'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已确认明日牌桌骨架，就绪开局！')),
              );
            },
            child: const Text('锁定明日骨架'),
          ),
        ],
      ),
    );
  }

  // 睡眠纪律打卡对话框
  void _openSleepDisciplineDialog() {
    final sleepSkill = _skills.firstWhere((s) => s.isSleepSkill);
    int currentScore = sleepSkill.sleepDisciplineScore;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.moon, color: Colors.indigoAccent, size: 20),
            SizedBox(width: 8),
            Text('睡眠纪律打卡与评分'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('昨夜作息与睡眠质量自律复盘：'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('今日自律评分：', style: TextStyle(fontWeight: FontWeight.bold)),
                ShadBadge.secondary(
                  child: Text('$currentScore 分', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✅ 按时 23:00 前熄灯入睡\n'
              '✅ 达成 7.5 小时深度修复周期\n'
              '✅ 晨间自然唤醒，无疲惫宿醉感',
              style: TextStyle(fontSize: 12, height: 1.8),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.sparkles, size: 14, color: Colors.green),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '已激活次日 BUFF：全技能卡牌获得精力充沛加成！',
                      style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ShadButton(
            onPressed: () {
              setState(() {
                sleepSkill.addExp(40);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('睡眠纪律打卡成功！【睡眠技能】+40 EXP')),
              );
            },
            child: const Text('确认打卡 (+40 EXP)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    Widget body;
    switch (_currentTabIndex) {
      case 0:
        body = PokerTableScreen(
          timeBlocks: _timeBlocks,
          allEvents: _events,
          allSkills: _skills,
          inventoryItems: _inventoryItems,
          onToggleEvent: _toggleEvent,
          onAssignEventToBlock: _assignEventToBlock,
          onRemoveEventFromBlock: _removeEventFromBlock,
          onEquipSkillToBlock: _equipSkillToBlock,
          onUseConsumableInBlock: _onUseConsumableInBlock,
          onNightlyPrep: _openNightlyPrepDialog,
          onSleepCheckIn: _openSleepDisciplineDialog,
        );
        break;
      case 1:
        body = TaskDeckScreen(
          events: _events,
          allSkills: _skills,
          timeBlocks: _timeBlocks,
          onToggleEvent: _toggleEvent,
          onAddEvent: _addEvent,
          onDeleteEvent: _deleteEvent,
          onAssignToBlock: _assignEventToBlock,
        );
        break;
      case 2:
        body = SkillDeckScreen(
          skills: _skills,
          inventoryItems: _inventoryItems,
          onAddSkill: _addSkill,
          onTrainSkill: _trainSkill,
        );
        break;
      case 3:
        body = VaultInventoryScreen(
          inventoryItems: _inventoryItems,
          skillCards: _skills,
          transactions: _transactions,
          cashBalance: _cashBalance,
          onAddItem: _onAddInventoryItem,
          onUpdateItem: _onUpdateInventoryItem,
          onDeleteItem: _onDeleteInventoryItem,
          onAddTransaction: _onAddTransaction,
          onBindAssetToSkill: _onBindAssetToSkill,
        );
        break;
      case 4:
        body = CodexBookScreen(
          entries: _codexEntries,
          allSkills: _skills,
          allAssets: _inventoryItems.where((i) => i.type == InventoryType.asset).toList(),
          onToggleChecklistItem: _toggleCodexChecklistItem,
          onCreateEventFromCodex: _createEventFromCodex,
          onAddCodexEntry: _addCodexEntry,
          onDeleteCodexEntry: _deleteCodexEntry,
        );
        break;
      case 5:
      default:
        // 独立的 21点休闲小游戏
        body = const BlackjackGameScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(LucideIcons.spade, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'Life-Poker',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(width: 8),
            ShadBadge.secondary(
              child: const Text('shadcn/ui', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
        actions: [
          ShadIconButton.ghost(
            icon: const Icon(LucideIcons.moon, size: 18),
            onPressed: _openSleepDisciplineDialog,
          ),
          ShadIconButton.ghost(
            icon: Icon(
              widget.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
              size: 18,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutGrid),
            label: '牌桌时间块',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.listTodo),
            label: '事件卡库',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.sparkles),
            label: '技能卡组',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.coins),
            label: '金库资产',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.bookOpen),
            label: '衣食住行书',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.gamepad2),
            label: '21点小游戏',
          ),
        ],
      ),
    );
  }
}
