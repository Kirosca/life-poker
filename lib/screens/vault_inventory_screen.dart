import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../models/inventory_item.dart';
import '../models/poker_card.dart';

class VaultInventoryScreen extends StatefulWidget {
  final List<InventoryItem> inventoryItems;
  final List<SkillCard> skillCards;
  final List<TransactionRecord> transactions;
  final double cashBalance;
  final Function(InventoryItem) onAddItem;
  final Function(InventoryItem) onUpdateItem;
  final Function(String itemId) onDeleteItem;
  final Function(TransactionRecord) onAddTransaction;
  final Function(String assetId, String? skillId) onBindAssetToSkill;

  const VaultInventoryScreen({
    super.key,
    required this.inventoryItems,
    required this.skillCards,
    required this.transactions,
    required this.cashBalance,
    required this.onAddItem,
    required this.onUpdateItem,
    required this.onDeleteItem,
    required this.onAddTransaction,
    required this.onBindAssetToSkill,
  });

  @override
  State<VaultInventoryScreen> createState() => _VaultInventoryScreenState();
}

class _VaultInventoryScreenState extends State<VaultInventoryScreen> {
  int _selectedTabIndex = 0; // 0: 资产装备, 1: 消耗品背包, 2: 财务明细

  double get _totalAssetValue {
    return widget.inventoryItems
        .where((item) => item.isAsset)
        .fold(0.0, (sum, item) => sum + item.value);
  }

  double get _totalConsumableValue {
    return widget.inventoryItems
        .where((item) => item.isConsumable)
        .fold(0.0, (sum, item) => sum + (item.value * item.quantity));
  }

  double get _netWorth => widget.cashBalance + _totalAssetValue + _totalConsumableValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Column(
          children: [
            _buildTreasuryHeader(),
            _buildTabSelector(),
            Expanded(
              child: _buildCurrentTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasuryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(25))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAB308).withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.coins, color: Color(0xFFFBBF24), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '金库与资产背包',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Life Deck Vault & Equipment',
                        style: TextStyle(fontSize: 11, color: Color(0xFFA1A1AA)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  ShadButton.outline(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.receipt, size: 14),
                    onPressed: _openAddTransactionModal,
                    child: const Text('记一笔'),
                  ),
                  const SizedBox(width: 8),
                  ShadButton(
                    size: ShadButtonSize.sm,
                    leading: const Icon(LucideIcons.plus, size: 14),
                    onPressed: _openAddItemModal,
                    child: const Text('添装备/耗材'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 资产概览小卡片
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: '流动资金 (Cash)',
                  amount: '¥${widget.cashBalance.toStringAsFixed(0)}',
                  icon: LucideIcons.wallet,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: '资产估值 (Assets)',
                  amount: '¥${_totalAssetValue.toStringAsFixed(0)}',
                  icon: LucideIcons.shieldCheck,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: '总净资产 (Net Worth)',
                  amount: '¥${_netWorth.toStringAsFixed(0)}',
                  icon: LucideIcons.gem,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF27272A).withAlpha(160),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Color(0xFFA1A1AA)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = [
      {'label': '🛡️ 固定装备 (${widget.inventoryItems.where((i) => i.isAsset).length})', 'index': 0},
      {'label': '🧪 消耗品 (${widget.inventoryItems.where((i) => i.isConsumable).length})', 'index': 1},
      {'label': '📜 账单流水 (${widget.transactions.length})', 'index': 2},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B).withAlpha(180),
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(20))),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTabIndex == tab['index'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => setState(() => _selectedTabIndex = tab['index'] as int),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white.withAlpha(20),
                  ),
                ),
                child: Text(
                  tab['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black : const Color(0xFFA1A1AA),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAssetsView();
      case 1:
        return _buildConsumablesView();
      case 2:
        return _buildTransactionsView();
      default:
        return const SizedBox.shrink();
    }
  }

  // 1. 固定资产装备视图
  Widget _buildAssetsView() {
    final assets = widget.inventoryItems.where((i) => i.isAsset).toList();

    if (assets.isEmpty) {
      return _buildEmptyState('暂无固定资产装备', '点击右上角「添装备/耗材」登记你的电脑、耳机或生产力装备');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: assets.length,
      itemBuilder: (context, index) {
        final asset = assets[index];
        final boundSkill = widget.skillCards.where((s) => s.id == asset.boundSkillId).firstOrNull;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ShadCard(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF3B82F6).withAlpha(70)),
                  ),
                  child: Icon(asset.icon, color: const Color(0xFF60A5FA), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            asset.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          ShadBadge.secondary(
                            child: Text(
                              '原值 ¥${asset.value.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asset.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () => widget.onDeleteItem(asset.id),
                  child: const Text('报废/移除', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // 增益效果
                if (asset.buffEffect != null && asset.buffEffect!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withAlpha(50)),
                    ),
                    child: Text(
                      asset.buffEffect!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF34D399), fontWeight: FontWeight.w500),
                    ),
                  ),

                // 装备状态与绑定技能
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A).withAlpha(140),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.link, size: 14, color: Color(0xFFA1A1AA)),
                          const SizedBox(width: 8),
                          Text(
                            boundSkill != null
                                ? '已装配到: [${boundSkill.suit.symbol} ${boundSkill.name}]'
                                : '未装备到技能牌 (闲置)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: boundSkill != null ? FontWeight.w600 : FontWeight.normal,
                              color: boundSkill != null ? const Color(0xFF60A5FA) : const Color(0xFF71717A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (boundSkill != null)
                            ShadButton.ghost(
                              size: ShadButtonSize.sm,
                              onPressed: () => widget.onBindAssetToSkill(asset.id, null),
                              child: const Text('卸下', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                            ),
                          ShadButton.outline(
                            size: ShadButtonSize.sm,
                            leading: const Icon(LucideIcons.arrowRightLeft, size: 12),
                            onPressed: () => _openBindSkillModal(asset),
                            child: Text(boundSkill != null ? '更换装配' : '装配给技能', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 2. 消耗品背包视图
  Widget _buildConsumablesView() {
    final consumables = widget.inventoryItems.where((i) => i.isConsumable).toList();

    if (consumables.isEmpty) {
      return _buildEmptyState('消耗品背包为空', '点击右上角「添装备/耗材」登记咖啡豆、补剂或草稿纸');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: consumables.length,
      itemBuilder: (context, index) {
        final item = consumables[index];
        final isLowStock = item.quantity <= 3;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ShadCard(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF59E0B).withAlpha(70)),
                  ),
                  child: Icon(item.icon, color: const Color(0xFFFBBF24), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          if (isLowStock)
                            const ShadBadge.destructive(
                              child: Text('库存告急', style: TextStyle(fontSize: 10)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '单价约 ¥${item.value.toStringAsFixed(1)} / ${item.unit}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF71717A)),
                ),
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () => widget.onDeleteItem(item.id),
                  child: const Text('移除', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (item.buffEffect != null && item.buffEffect!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withAlpha(50)),
                    ),
                    child: Text(
                      '效果: ${item.buffEffect!}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF34D399), fontWeight: FontWeight.w500),
                    ),
                  ),

                // 库存计步器与单价
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27272A).withAlpha(140),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('当前存量', style: TextStyle(fontSize: 11, color: Color(0xFFA1A1AA))),
                          const SizedBox(height: 2),
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLowStock ? const Color(0xFFEF4444) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // 扣减 1
                          IconButton(
                            icon: const Icon(LucideIcons.minus, size: 16),
                            color: Colors.white70,
                            onPressed: item.quantity > 0
                                ? () {
                                    widget.onUpdateItem(item.copyWith(quantity: item.quantity - 1));
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF18181B),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white.withAlpha(20)),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          // 增加 1
                          IconButton(
                            icon: const Icon(LucideIcons.plus, size: 16),
                            color: Colors.white70,
                            onPressed: () {
                              widget.onUpdateItem(item.copyWith(quantity: item.quantity + 1));
                            },
                          ),
                          const SizedBox(width: 8),
                          // 快捷在牌桌打出消耗 1 提示
                          ShadButton.secondary(
                            size: ShadButtonSize.sm,
                            onPressed: item.quantity > 0
                                ? () {
                                    widget.onUpdateItem(item.copyWith(quantity: item.quantity - 1));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('已打出使用 1 ${item.unit}「${item.name}」，已获得补给状态！'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                : null,
                            child: const Text('立刻使用', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 3. 财务账单流水视图
  Widget _buildTransactionsView() {
    if (widget.transactions.isEmpty) {
      return _buildEmptyState('暂无记账明细', '点击右上角「记一笔」记录你的主业收入或补给消费');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.transactions.length,
      itemBuilder: (context, index) {
        final tx = widget.transactions[index];
        final isIncome = tx.type == TransactionType.income;
        final isAsset = tx.type == TransactionType.assetPurchase;

        Color typeColor = const Color(0xFFEF4444);
        String prefix = '-';
        IconData icon = LucideIcons.arrowUpRight;

        if (isIncome) {
          typeColor = const Color(0xFF10B981);
          prefix = '+';
          icon = LucideIcons.arrowDownLeft;
        } else if (isAsset) {
          typeColor = const Color(0xFF3B82F6);
          prefix = '-';
          icon = LucideIcons.shoppingBag;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF18181B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: typeColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${tx.date.month}月${tx.date.day}日 · ${tx.category ?? "日常"}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFA1A1AA)),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$prefix¥${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.box, size: 48, color: Color(0xFF52525B)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF71717A)),
          ),
        ],
      ),
    );
  }

  // 模态框: 绑定资产到技能
  void _openBindSkillModal(InventoryItem asset) {
    showShadDialog(
      context: context,
      builder: (context) {
        return ShadDialog(
          title: Text('装配资产: ${asset.name}'),
          description: const Text('选择需要装配该固定资产的技能牌，赋予加成效果。'),
          actions: [
            ShadButton.outline(
              child: const Text('取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.skillCards.map((skill) {
              final isCurrentBound = asset.boundSkillId == skill.id;
              return ListTile(
                title: Text('${skill.suit.symbol} ${skill.name} (Lv.${skill.level})'),
                subtitle: Text(skill.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: isCurrentBound
                    ? const Icon(LucideIcons.check, color: Color(0xFF10B981))
                    : null,
                onTap: () {
                  widget.onBindAssetToSkill(asset.id, skill.id);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // 模态框: 记一笔流水
  void _openAddTransactionModal() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;
    String selectedCategory = '补给采购';

    showShadDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ShadDialog(
              title: const Text('记一笔资金流水'),
              description: const Text('记录你的收支流水，实时核算流动资金与净资产。'),
              actions: [
                ShadButton.outline(
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ShadButton(
                  child: const Text('确认入账'),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    if (title.isNotEmpty && amount > 0) {
                      final newTx = TransactionRecord(
                        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        amount: amount,
                        type: selectedType,
                        date: DateTime.now(),
                        category: selectedCategory,
                      );
                      widget.onAddTransaction(newTx);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('类型', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('日常支出'),
                        selected: selectedType == TransactionType.expense,
                        onSelected: (_) => setModalState(() => selectedType = TransactionType.expense),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('收入'),
                        selected: selectedType == TransactionType.income,
                        onSelected: (_) => setModalState(() => selectedType = TransactionType.income),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('购置资产'),
                        selected: selectedType == TransactionType.assetPurchase,
                        onSelected: (_) => setModalState(() => selectedType = TransactionType.assetPurchase),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('事项名称', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                  const SizedBox(height: 6),
                  ShadInput(
                    controller: titleController,
                    placeholder: const Text('如: 采购咖啡豆、项目里程碑到账'),
                  ),
                  const SizedBox(height: 12),
                  const Text('金额 (元)', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                  const SizedBox(height: 6),
                  ShadInput(
                    controller: amountController,
                    placeholder: const Text('0.00'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 模态框: 添置新资产或消耗品
  void _openAddItemModal() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final valueController = TextEditingController();
    final buffController = TextEditingController();
    final unitController = TextEditingController(text: '件');
    final qtyController = TextEditingController(text: '1');
    InventoryType itemType = InventoryType.asset;

    showShadDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ShadDialog(
              title: const Text('登记新装备 / 补给耗材'),
              description: const Text('录入到你的生活背包库中，可用于加成技能或在牌桌打出。'),
              actions: [
                ShadButton.outline(
                  child: const Text('取消'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ShadButton(
                  child: const Text('保存入库'),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();
                    final value = double.tryParse(valueController.text.trim()) ?? 0.0;
                    final qty = int.tryParse(qtyController.text.trim()) ?? 1;
                    final unit = unitController.text.trim().isEmpty ? '件' : unitController.text.trim();
                    final buff = buffController.text.trim();

                    if (name.isNotEmpty) {
                      final newItem = InventoryItem(
                        id: '${itemType.name}_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        description: desc,
                        type: itemType,
                        icon: itemType == InventoryType.asset ? LucideIcons.packageCheck : LucideIcons.flaskConical,
                        value: value,
                        quantity: itemType == InventoryType.asset ? 1 : qty,
                        unit: unit,
                        buffEffect: buff.isNotEmpty ? buff : null,
                      );
                      widget.onAddItem(newItem);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('物品分类', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('🛡️ 固定装备 (资产)'),
                          selected: itemType == InventoryType.asset,
                          onSelected: (_) => setModalState(() => itemType = InventoryType.asset),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('🧪 补给耗材 (消耗品)'),
                          selected: itemType == InventoryType.consumable,
                          onSelected: (_) => setModalState(() => itemType = InventoryType.consumable),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('物品名称', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: nameController,
                      placeholder: const Text('如: 4K显示器、有机洋甘菊茶'),
                    ),
                    const SizedBox(height: 12),
                    const Text('说明 / 规格', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: descController,
                      placeholder: const Text('如: 护眼高刷、高纯度'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(itemType == InventoryType.asset ? '原值/估值 (元)' : '单价 (元)', style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                              const SizedBox(height: 6),
                              ShadInput(
                                controller: valueController,
                                placeholder: const Text('0.00'),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (itemType == InventoryType.consumable) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('初始库存', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                                const SizedBox(height: 6),
                                ShadInput(
                                  controller: qtyController,
                                  placeholder: const Text('10'),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 65,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('单位', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                                const SizedBox(height: 6),
                                ShadInput(
                                  controller: unitController,
                                  placeholder: const Text('袋'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('增益加成词条 (Buff Effect)', style: TextStyle(fontSize: 12, color: Color(0xFFA1A1AA))),
                    const SizedBox(height: 6),
                    ShadInput(
                      controller: buffController,
                      placeholder: const Text('如: 提神 3 小时、专注度 +20%'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
