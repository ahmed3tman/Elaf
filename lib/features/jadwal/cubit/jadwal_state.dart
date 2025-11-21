import '../data/models/daily_task_list_model.dart';
import '../data/models/prayer_times_model.dart';

enum JadwalStatus { initial, loading, success, failure }

class JadwalState {
  final JadwalStatus status;
  final DailyTaskList? currentDay;
  final List<DailyTaskList> history;
  final PrayerTimes? todayPrayerTimes;
  final String? error;
  final String? nextPrayer;

  const JadwalState({
    this.status = JadwalStatus.initial,
    this.currentDay,
    this.history = const [],
    this.todayPrayerTimes,
    this.error,
    this.nextPrayer,
  });

  JadwalState copyWith({
    JadwalStatus? status,
    DailyTaskList? currentDay,
    List<DailyTaskList>? history,
    PrayerTimes? todayPrayerTimes,
    String? error,
    String? nextPrayer,
  }) {
    return JadwalState(
      status: status ?? this.status,
      currentDay: currentDay ?? this.currentDay,
      history: history ?? this.history,
      todayPrayerTimes: todayPrayerTimes ?? this.todayPrayerTimes,
      error: error ?? this.error,
      nextPrayer: nextPrayer ?? this.nextPrayer,
    );
  }
}
