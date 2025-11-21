enum TaskType {
  fajr('الفجر'),
  dhuhr('الظهر'),
  asr('العصر'),
  maghrib('المغرب'),
  isha('العشاء'),
  wird('الورد اليومي');

  final String nameAr;
  const TaskType(this.nameAr);
}

class DailyTask {
  final String id;
  final TaskType type;
  final bool isCompleted;
  final bool isLocked;
  final DateTime? unlockTime;

  const DailyTask({
    required this.id,
    required this.type,
    this.isCompleted = false,
    this.isLocked = true,
    this.unlockTime,
  });

  String get nameAr => type.nameAr;

  bool get isPrayer => type != TaskType.wird;

  DailyTask copyWith({
    String? id,
    TaskType? type,
    bool? isCompleted,
    bool? isLocked,
    DateTime? unlockTime,
  }) {
    return DailyTask(
      id: id ?? this.id,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      unlockTime: unlockTime ?? this.unlockTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'unlockTime': unlockTime?.toIso8601String(),
    };
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'] as String,
      type: TaskType.values.firstWhere((e) => e.name == map['type']),
      isCompleted: map['isCompleted'] as bool? ?? false,
      isLocked: map['isLocked'] as bool? ?? true,
      unlockTime: map['unlockTime'] != null
          ? DateTime.parse(map['unlockTime'] as String)
          : null,
    );
  }
}
