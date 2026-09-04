import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Status calculation
    final bool isBust = totalPoints > 21;
    final bool isBlackjack = totalPoints == 21;
    final bool isOptimal = totalPoints >= 16 && totalPoints <= 20;

    Color statusColor;
    String statusTitle;
    String statusDesc;
    IconData statusIcon;

    if (isBust) {
      statusColor = Colors.redAccent;
      statusTitle = 'Bust! 精力超载 ($totalPoints / 21)';
      statusDesc = '任务点数已超过21点上限，请减少或推迟部分任务避免耗竭！';
      statusIcon = Icons.warning_amber_rounded;
    } else if (isBlackjack) {
      statusColor = Colors.amber.shade700;
      statusTitle = 'Blackjack! 完美21点';
      statusDesc = '今日精力分配臻于极致！稳扎稳打完成这些目标吧！';
      statusIcon = Icons.military_tech_rounded;
    } else if (isOptimal) {
      statusColor = Colors.teal;
      statusTitle = 'In the Zone 绝佳状态 ($totalPoints / 21)';
      statusDesc = '已接近21点最佳饱和度，准备停牌(Stand)锁定今日目标。';
      statusIcon = Icons.bolt_rounded;
    } else {
      statusColor = Colors.blue;
      statusTitle = 'Safe 活力充足 ($totalPoints / 21)';
      statusDesc = '精力槽仍有余量，可点击"Hit"抽取微任务或继续添加！';
      statusIcon = Icons.battery_charging_full_rounded;
    }

    final double progress = (totalPoints / 21.0).clamp(0.0, 1.0);
    final double completionRatio = totalPoints > 0
        ? (completedPoints / totalPoints).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withValues(alpha: 0.12),
              colorScheme.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        statusDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已规划点数: $totalPoints 点 (上限21)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '完成进度: $completedPoints 点 (${(completionRatio * 100).toInt()}%)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Action Buttons (Hit & Stand)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBust ? null : onHit,
                    icon: const Icon(Icons.style_outlined, size: 18),
                    label: const Text('Hit (抽卡加任务)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onStand,
                    icon: const Icon(Icons.lock_clock_outlined, size: 18),
                    label: const Text('Stand (停牌锁定)'),
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
