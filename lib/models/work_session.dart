import 'package:hive/hive.dart';
import 'user_settings.dart';

part 'work_session.g.dart';

@HiveType(typeId: 2)
class WorkSession {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  TimeOfDay startTime;

  @HiveField(3)
  TimeOfDay? breakStartTime;

  @HiveField(4)
  TimeOfDay? breakEndTime;

  @HiveField(5)
  TimeOfDay endTime;

  @HiveField(6)
  String location;

  @HiveField(7)
  String description;

  @HiveField(8)
  double hourlyRate;

  @HiveField(9)
  TimeOfDay overtimeStart;

  WorkSession({
    required this.id,
    required this.date,
    required this.startTime,
    this.breakStartTime,
    this.breakEndTime,
    required this.endTime,
    required this.location,
    required this.description,
    required this.hourlyRate,
    required this.overtimeStart,
  });

  // Calcul des heures normales (avant les heures supplémentaires)
  double get normalHours {
    final startMinutes = startTime.toMinutes();
    final endMinutes = endTime.toMinutes();
    final overtimeStartMinutes = overtimeStart.toMinutes();
    
    // Si la session se termine avant les heures supplémentaires
    if (endMinutes <= overtimeStartMinutes) {
      return _calculateTotalHours();
    }
    
    // Calcul des heures normales jusqu'à overtimeStart
    double normalHours = (overtimeStartMinutes - startMinutes) / 60.0;
    
    // Soustraire le temps de pause s'il y en a eu
    if (breakStartTime != null && breakEndTime != null) {
      final breakStartMinutes = breakStartTime!.toMinutes();
      final breakEndMinutes = breakEndTime!.toMinutes();
      
      // Si la pause est dans la période normale
      if (breakStartMinutes < overtimeStartMinutes) {
        final pauseEndInNormal = breakEndMinutes < overtimeStartMinutes 
            ? breakEndMinutes 
            : overtimeStartMinutes;
        normalHours -= (pauseEndInNormal - breakStartMinutes) / 60.0;
      }
    }
    
    return normalHours > 0 ? normalHours : 0;
  }

  // Calcul des heures supplémentaires
  double get overtimeHours {
    final startMinutes = startTime.toMinutes();
    final endMinutes = endTime.toMinutes();
    final overtimeStartMinutes = overtimeStart.toMinutes();
    
    // Si la session se termine avant les heures supplémentaires
    if (endMinutes <= overtimeStartMinutes) {
      return 0;
    }
    
    // Calcul des heures supplémentaires
    double overtimeHours = (endMinutes - overtimeStartMinutes) / 60.0;
    
    // Soustraire le temps de pause s'il y en a eu
    if (breakStartTime != null && breakEndTime != null) {
      final breakStartMinutes = breakStartTime!.toMinutes();
      final breakEndMinutes = breakEndTime!.toMinutes();
      
      // Si la pause est dans la période des heures supplémentaires
      if (breakEndMinutes > overtimeStartMinutes) {
        final pauseStartInOvertime = breakStartMinutes > overtimeStartMinutes 
            ? breakStartMinutes 
            : overtimeStartMinutes;
        overtimeHours -= (breakEndMinutes - pauseStartInOvertime) / 60.0;
      }
    }
    
    return overtimeHours > 0 ? overtimeHours : 0;
  }

  // Calcul du total des heures travaillées
  double _calculateTotalHours() {
    final startMinutes = startTime.toMinutes();
    final endMinutes = endTime.toMinutes();
    double totalMinutes = (endMinutes - startMinutes).toDouble();
    
    // Soustraire le temps de pause s'il y en a eu
    if (breakStartTime != null && breakEndTime != null) {
      final breakStartMinutes = breakStartTime!.toMinutes();
      final breakEndMinutes = breakEndTime!.toMinutes();
      totalMinutes -= (breakEndMinutes - breakStartMinutes).toDouble();
    }
    
    return totalMinutes / 60.0;
  }

  // Calcul du salaire journalier
  double get dailySalary {
    return (normalHours * hourlyRate) + (overtimeHours * hourlyRate * 1.25); // 25% de majoration pour les heures supplémentaires
  }

  // Format de la date pour l'affichage
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Durée totale formatée
  String get formattedDuration {
    final totalHours = normalHours + overtimeHours;
    final hours = totalHours.floor();
    final minutes = ((totalHours - hours) * 60).round();
    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  WorkSession copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? breakStartTime,
    TimeOfDay? breakEndTime,
    TimeOfDay? endTime,
    String? location,
    String? description,
    double? hourlyRate,
    TimeOfDay? overtimeStart,
  }) {
    return WorkSession(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      overtimeStart: overtimeStart ?? this.overtimeStart,
    );
  }
} 