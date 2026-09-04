import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BlackjackMeter extends StatelessWidget {
  final int totalPoints;
  final int completedPoints;
  final VoidCallback onHit;
  final VoidCallback onStand;

  const BlackjackMeter({
    super.key,
    required this.totalPoints,
    required this.completedPoints,
    required this.onHit,
    required this.onStand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    // Status calculation
    final bool isBust = totalPoints > 21;
    final bool isBlackjack = totalPoints == 21;
    final bool isOptimal = totalPoints >= 16 && totalPoints <= 20;

    String statusTitle;
    String statusDesc;
    IconData statusIcon;
    Color statusColor;

    if (isBust) {
      statusColor = Colors.redAccent;
      statusTitle = 'Bust! 精力超载 ($totalPoints / 21)';
      statusDesc = '任务点数已超过21点上限，请移出部分任务避免耗竭！';
      statusIcon = LucideIcons.shieldAlert;
    } else if (isBlackjack) {
      statusColor = const Color(0xFFF59E0B); // Amber
      statusTitle = 'Blackjack! 完美21点';
      statusDesc = '今日精力分配臻于极致，全力冲刺吧！';
      statusIcon = LucideIcons.flame;
    } else if (isOptimal) {
      statusColor = const Color(0xFF10B981); // Emerald
      statusTitle = 'In the Zone 黄金专注 ($totalPoints / 21)';
      statusDesc = '已处于最佳饱和度，准备停牌(Stand)锁定今日目标。';
      statusIcon = LucideIcons.zap;
    } else {
      statusColor = const Color(0xFF3B82F6); // Blue
      statusTitle = 'Safe 活力充足 ($totalPoints / 21)';
      statusDesc = '精力槽仍有余量，可点击"Hit"抽取微任务或打下手牌！';
      statusIcon = LucideIcons.shield;
    }

    final double progress = (totalPoints / 21.0).clamp(0.0, 1.0);
    final double completionRatio = totalPoints > 0
        ? (completedPoints / totalPoints).clamp(0.0, 1.0)
        : 0.0;

    return ShadCard(
      padding: const EdgeInsets.all(16),
      title: Row(
        children: [
          Icon(statusIcon, size: 20, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusTitle,
              style: theme.textTheme.p.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          ShadBadge.outline(
            child: Text('$totalPoints / 21 PTS'),
          ),
        ],
      ),
      description: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          statusDesc,
          style: theme.textTheme.muted.copyWith(fontSize: 12),
        ),
      ),
      footer: Row(
        children: [
          Expanded(
            child: ShadButton.outline(
              leading: const Icon(LucideIcons.sparkles, size: 16),
              onPressed: isBust ? null : onHit,
              child: const Text('Hit (抽卡加任务)'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ShadButton.secondary(
              leading: const Icon(LucideIcons.lock, size: 16),
              onPressed: onStand,
              child: const Text('Stand (停牌锁定)'),
            ),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            ShadProgress(
              value: progress,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已规划点数: $totalPoints 点 (上限21)',
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
                Text(
                  '完成进度: $completedPoints 点 (${(completionRatio * 100).toInt()}%)',
                  style: theme.textTheme.muted.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
