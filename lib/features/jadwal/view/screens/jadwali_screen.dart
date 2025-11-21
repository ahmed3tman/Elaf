import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';
import '../../cubit/jadwal_cubit.dart';
import '../../cubit/jadwal_state.dart';
import '../../data/models/prayer_times_model.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/prayer_times_widget.dart';
import '../widgets/day_color_indicator.dart';
import 'history_screen.dart';

class JadwaliScreen extends StatefulWidget {
  const JadwaliScreen({super.key});

  @override
  State<JadwaliScreen> createState() => _JadwaliScreenState();
}

class _JadwaliScreenState extends State<JadwaliScreen> {
  late final JadwalCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = JadwalCubit();
    _cubit.initialize();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: GradientScaffold(
        appBar: AppBar(
          title: const Text('جدولي'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'السجل',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (routeContext) => BlocProvider.value(
                      value: _cubit,
                      child: const HistoryScreen(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<JadwalCubit, JadwalState>(
          builder: (context, state) {
            if (state.status == JadwalStatus.loading ||
                state.status == JadwalStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == JadwalStatus.failure) {
              return Center(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error ?? 'خطأ غير معروف',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _cubit.initialize(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state.currentDay == null) {
              return const Center(child: Text('لا توجد بيانات'));
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: CustomScrollView(
                slivers: [
                  // Header with date and progress
                  SliverToBoxAdapter(child: _buildHeader(context, state)),

                  // Tasks List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: state.currentDay!.tasks
                            .map(
                              (task) => TaskItemWidget(
                                task: task,
                                onToggle: () => _cubit.toggleTask(task.id),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  // Save Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _cubit.saveCurrentDayToHistory();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم اضافة انجاز اليوم الي السجل'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ الإنجاز في السجل'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Prayer Times Widget
                  if (state.todayPrayerTimes != null)
                    SliverToBoxAdapter(
                      child: PrayerTimesWidget(
                        prayerTimes: state.todayPrayerTimes!,
                        nextPrayer: state.nextPrayer,
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, JadwalState state) {
    final theme = Theme.of(context);
    final currentDay = state.currentDay!;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اليوم',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(currentDay.date),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              DayColorIndicator(
                color: currentDay.color,
                completedCount: currentDay.completedCount,
                totalCount: currentDay.totalCount,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التقدم',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: currentDay.completedCount / currentDay.totalCount,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                    0.3,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(currentDay.color),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

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

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday، ${date.day} $month';
  }

  Color _getProgressColor(color) {
    switch (color) {
      case DayColor.green:
        return Colors.green;
      case DayColor.yellow:
        return Colors.orange;
      case DayColor.red:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
