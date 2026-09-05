import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum InventoryType {
  asset,       // 固定资产 / 装备 (永久拥有，绑定技能提供加成)
  consumable,  // 消耗品 / 耗材 (有库存数量，在时间块中打出消耗)
}

enum TransactionType {
  income,       // 收入
  expense,      // 日常支出
  assetPurchase,// 购置资产/耗材
}

class InventoryItem {
  final String id;
  final String name;
  final String description;
  final InventoryType type;
  final IconData icon;
  final double value;          // 资产原值 / 消耗品单价
  final int quantity;          // 消耗品当前库存数量 (资产固定为 1)
  final String unit;           // 数量单位 (如: "台", "本", "杯", "袋", "盒")
  final String? boundSkillId;  // 绑定的技能卡 ID (仅资产可用)
  final String? buffEffect;    // 加成/提神效果描述 (如: "+15% 专注度", "提神4小时")

  const InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.value,
    this.quantity = 1,
    this.unit = '件',
    this.boundSkillId,
    this.buffEffect,
  });

  bool get isAsset => type == InventoryType.asset;
  bool get isConsumable => type == InventoryType.consumable;

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    InventoryType? type,
    IconData? icon,
    double? value,
    int? quantity,
    String? unit,
    String? boundSkillId,
    String? buffEffect,
    bool unbindSkill = false,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      value: value ?? this.value,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      boundSkillId: unbindSkill ? null : (boundSkillId ?? this.boundSkillId),
      buffEffect: buffEffect ?? this.buffEffect,
    );
  }
}

class TransactionRecord {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? category;
  final String? note;

  const TransactionRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
    this.note,
  });
}

// 预设默认资产与消耗品数据
class DefaultInventoryData {
  static List<InventoryItem> getInitialItems() {
    return [
      const InventoryItem(
        id: 'asset_1',
        name: 'MacBook Pro M3 Max',
        description: '核心生产力开发机，搭载本地大型编译与模型环境',
        type: InventoryType.asset,
        icon: LucideIcons.laptop,
        value: 19999.0,
        quantity: 1,
        unit: '台',
        boundSkillId: 'skill_1', // 默认装备给 Flutter 架构实战
        buffEffect: '🚀 架构与编译速度提升 +35%',
      ),
      const InventoryItem(
        id: 'asset_2',
        name: 'Sony WH-1000XM5 降噪耳机',
        description: '全包覆头戴式主动降噪，快速隔绝嘈杂进入心流',
        type: InventoryType.asset,
        icon: LucideIcons.headphones,
        value: 2299.0,
        quantity: 1,
        unit: '副',
        boundSkillId: 'skill_2', // 默认装备给 算法深度心流
        buffEffect: '🎧 心流抗干扰度 +40%',
      ),
      const InventoryItem(
        id: 'asset_3',
        name: 'Herman Miller 人体工学椅',
        description: '高支撑力护脊工位核心装备，支撑长时间高强度编码',
        type: InventoryType.asset,
        icon: LucideIcons.armchair,
        value: 8500.0,
        quantity: 1,
        unit: '张',
        boundSkillId: 'skill_1',
        buffEffect: '🧘 疲劳积累减缓 30%',
      ),
      const InventoryItem(
        id: 'cons_1',
        name: '精品深烘双倍浓缩咖啡',
        description: '高品质意式拼配，晨间或午后破除困倦必备',
        type: InventoryType.consumable,
        icon: LucideIcons.coffee,
        value: 18.0,
        quantity: 12,
        unit: '杯',
        buffEffect: '⚡ 瞬间唤醒精力 +25%',
      ),
      const InventoryItem(
        id: 'cons_2',
        name: '高纯度复合维生素补剂',
        description: 'B族+泛酸+锌综合补充，维持高负荷脑力神经稳定',
        type: InventoryType.consumable,
        icon: LucideIcons.pill,
        value: 3.5,
        quantity: 30,
        unit: '粒',
        buffEffect: '🛡️ 持续神经续航 +2h',
      ),
      const InventoryItem(
        id: 'cons_3',
        name: '有机洋甘菊晚安茶',
        description: '无咖啡因草本舒缓茶饮，促进入睡与深睡眠比例',
        type: InventoryType.consumable,
        icon: LucideIcons.cupSoda,
        value: 8.0,
        quantity: 15,
        unit: '袋',
        buffEffect: '🌙 助眠放松，睡眠评分 +1星',
      ),
    ];
  }

  static List<TransactionRecord> getInitialTransactions() {
    return [
      TransactionRecord(
        id: 'tx_1',
        title: '项目交付里程碑奖金',
        amount: 35000.0,
        type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: '主业收入',
      ),
      TransactionRecord(
        id: 'tx_2',
        title: '购置精品咖啡豆与滤纸',
        amount: 216.0,
        type: TransactionType.expense,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: '补给消耗',
      ),
      TransactionRecord(
        id: 'tx_3',
        title: '添置护眼智能显示器挂灯',
        amount: 899.0,
        type: TransactionType.assetPurchase,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: '工位资产',
      ),
    ];
  }
}
