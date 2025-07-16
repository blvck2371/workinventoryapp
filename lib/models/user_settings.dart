import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings {
  @HiveField(0)
  double hourlyRate;

  @HiveField(1)
  TimeOfDay defaultBreakStart;

  @HiveField(2)
  TimeOfDay defaultBreakEnd;

  @HiveField(3)
  TimeOfDay overtimeStart;

  @HiveField(4)
  bool isFirstTime;

  UserSettings({
    required this.hourlyRate,
    required this.defaultBreakStart,
    required this.defaultBreakEnd,
    required this.overtimeStart,
    this.isFirstTime = true,
  });

  UserSettings copyWith({
    double? hourlyRate,
    TimeOfDay? defaultBreakStart,
    TimeOfDay? defaultBreakEnd,
    TimeOfDay? overtimeStart,
    bool? isFirstTime,
  }) {
    return UserSettings(
      hourlyRate: hourlyRate ?? this.hourlyRate,
      defaultBreakStart: defaultBreakStart ?? this.defaultBreakStart,
      defaultBreakEnd: defaultBreakEnd ?? this.defaultBreakEnd,
      overtimeStart: overtimeStart ?? this.overtimeStart,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }
}

@HiveType(typeId: 1)
class TimeOfDay {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int toMinutes() {
    return hour * 60 + minute;
  }

  static TimeOfDay fromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
} 