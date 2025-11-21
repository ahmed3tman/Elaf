import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';
import '../../cubit/jadwal_cubit.dart';
import '../../cubit/jadwal_state.dart';
import '../widgets/history_day_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load history when screen opens
    context.read<JadwalCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: const Text('السجل'), centerTitle: true),
      body: BlocBuilder<JadwalCubit, JadwalState>(
        builder: (context, state) {
          if (state.status == JadwalStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد سجل بعد',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بإكمال مهامك اليومية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // Header with stats
                _buildStatsHeader(context, state),

                // History List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: state.history.length,
                    itemBuilder: (context, index) {
                      final day = state.history[index];
                      return HistoryDayCard(
                        day: day,
                        onTap: () {
                          // Optional: Show day details dialog
                          _showDayDetails(context, day);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, JadwalState state) {
    final theme = Theme.of(context);
    final totalDays = state.history.length;
    final completeDays = state.history.where((day) => day.isComplete).length;
    final completionRate = totalDays > 0
        ? (completeDays / totalDays * 100).toStringAsFixed(0)
        : '0';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.primaryContainer.withOpacity(0.1),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'إجمالي الأيام',
            totalDays.toString(),
            Icons.calendar_today,
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          _buildStatItem(
            context,
            'أيام مكتملة',
            completeDays.toString(),
            Icons.check_circle,
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          _buildStatItem(
            context,
            'نسبة الإنجاز',
            '$completionRate%',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _showDayDetails(BuildContext context, day) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تفاصيل ${_formatDate(day.date)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...day.tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted ? Icons.check_circle : Icons.cancel,
                        color: task.isCompleted ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(task.nameAr),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
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

    final month = months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }
}
