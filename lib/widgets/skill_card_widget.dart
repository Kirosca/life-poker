import 'package:flutter/material.dart';
import '../models/poker_card.dart';

class SkillCardWidget extends StatelessWidget {
  final SkillCard skill;
  final VoidCallback? onTrain;
  final VoidCallback? onTap;

  const SkillCardWidget({
    super.key,
    required this.skill,
    this.onTrain,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suit = skill.suit;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: suit.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                suit.color.withValues(alpha: 0.08),
                theme.colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Suit Symbol + Level Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        suit.symbol,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: suit.color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        suit.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: suit.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: suit.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LV.${skill.level}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: suit.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Skill Name
              Text(
                skill.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (skill.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  skill.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const Spacer(),

              // Exp Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '熟练度',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${skill.exp}/${skill.maxExp} EXP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: suit.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: skill.progress,
                      minHeight: 6,
                      backgroundColor: suit.color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(suit.color),
                    ),
                  ),
                ],
              ),

              if (onTrain != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: OutlinedButton.icon(
                    onPressed: onTrain,
                    icon: const Icon(Icons.fitness_center_rounded, size: 14),
                    label: const Text('专项研习 (+25 EXP)', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: suit.color,
                      side: BorderSide(color: suit.color.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
