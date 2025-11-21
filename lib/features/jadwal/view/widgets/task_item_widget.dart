import 'package:flutter/material.dart';
import '../../data/models/daily_task_model.dart';

class TaskItemWidget extends StatelessWidget {
  final DailyTask task;
  final VoidCallback onToggle;

  const TaskItemWidget({super.key, required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = task.isLocked;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.isCompleted
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.dividerColor.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Checkbox or Lock Icon
                _buildLeadingIcon(theme, isDisabled),
                const SizedBox(width: 16),

                // Task Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.nameAr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isDisabled
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.4,
                                )
                              : null,
                        ),
                      ),
                      if (task.isPrayer && task.unlockTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _formatTime(task.unlockTime!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Status Indicator
                if (task.isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ThemeData theme, bool isDisabled) {
    if (isDisabled) {
      return Icon(
        Icons.lock,
        color: theme.iconTheme.color?.withOpacity(0.3),
        size: 28,
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: task.isCompleted
              ? theme.colorScheme.primary
              : theme.dividerColor.withOpacity(0.5),
          width: 2,
        ),
        color: task.isCompleted
            ? theme.colorScheme.primary
            : Colors.transparent,
      ),
      child: task.isCompleted
          ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 18)
          : null,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }
}
