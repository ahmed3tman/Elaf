import 'package:flutter/material.dart';
import '../../data/models/prayer_times_model.dart';

class PrayerTimesWidget extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final String? nextPrayer;

  const PrayerTimesWidget({
    super.key,
    required this.prayerTimes,
    this.nextPrayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'مواقيت الصلاة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPrayerTimeRow(
            context,
            'الفجر',
            prayerTimes.fajr,
            isNext: nextPrayer == 'fajr',
          ),
          const SizedBox(height: 8),
          _buildPrayerTimeRow(
            context,
            'الظهر',
            prayerTimes.dhuhr,
            isNext: nextPrayer == 'dhuhr',
          ),
          const SizedBox(height: 8),
          _buildPrayerTimeRow(
            context,
            'العصر',
            prayerTimes.asr,
            isNext: nextPrayer == 'asr',
          ),
          const SizedBox(height: 8),
          _buildPrayerTimeRow(
            context,
            'المغرب',
            prayerTimes.maghrib,
            isNext: nextPrayer == 'maghrib',
          ),
          const SizedBox(height: 8),
          _buildPrayerTimeRow(
            context,
            'العشاء',
            prayerTimes.isha,
            isNext: nextPrayer == 'isha',
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(
    BuildContext context,
    String name,
    DateTime time, {
    bool isNext = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isNext
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isNext)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  color: isNext ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
          Text(
            _formatTime(time),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: 'GeneralFont',
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
              color: isNext ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }
}
