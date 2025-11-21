import 'package:flutter/material.dart';
import '../../data/models/daily_task_list_model.dart';
import '../../data/models/prayer_times_model.dart';

class HistoryDayCard extends StatelessWidget {
  final DailyTaskList day;
  final VoidCallback? onTap;

  const HistoryDayCard({super.key, required this.day, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(day.color);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Color Indicator Circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.completedCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Date and Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(day.date),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.completedCount} من ${day.totalCount} مهام',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusText(day.color),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Completion Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${((day.completedCount / day.totalCount) * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (day.isComplete)
                    Icon(Icons.check_circle, color: color, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(DayColor dayColor) {
    switch (dayColor) {
      case DayColor.green:
        return Colors.green;
      case DayColor.yellow:
        return Colors.orange;
      case DayColor.red:
        return Colors.red;
    }
  }

  String _getStatusText(DayColor dayColor) {
    switch (dayColor) {
      case DayColor.green:
        return 'ممتاز - جميع المهام مكتملة';
      case DayColor.yellow:
        return 'جيد - بعض المهام ناقصة';
      case DayColor.red:
        return 'يحتاج تحسين';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday، ${date.day} $month ${date.year}';
  }
}
