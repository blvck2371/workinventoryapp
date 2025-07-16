import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/user_settings.dart';
import '../models/work_session.dart';

class HiveService {
  static const String _settingsBoxName = 'settings';
  static const String _sessionsBoxName = 'sessions';
  
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Sur le web, utiliser le stockage local du navigateur
      await Hive.initFlutter();
    } else {
      // Sur mobile/desktop, utiliser le dossier de l'application
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    }
    
    // Enregistrer les adaptateurs
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    Hive.registerAdapter(WorkSessionAdapter());
    
    // Ouvrir les boîtes
    await Hive.openBox<UserSettings>(_settingsBoxName);
    await Hive.openBox<WorkSession>(_sessionsBoxName);
  }

  // Gestion des paramètres utilisateur
  static Box<UserSettings> get settingsBox => 
      Hive.box<UserSettings>(_settingsBoxName);
  
  static Box<WorkSession> get sessionsBox => 
      Hive.box<WorkSession>(_sessionsBoxName);

  // Méthodes pour les paramètres
  static UserSettings? getSettings() {
    return settingsBox.get('user_settings');
  }

  static Future<void> saveSettings(UserSettings settings) async {
    await settingsBox.put('user_settings', settings);
  }

  // Méthodes pour les sessions de travail
  static List<WorkSession> getAllSessions() {
    return sessionsBox.values.toList();
  }

  static List<WorkSession> getSessionsByMonth(int year, int month) {
    return sessionsBox.values
        .where((session) => 
            session.date.year == year && session.date.month == month)
        .toList();
  }

  static Future<void> saveSession(WorkSession session) async {
    await sessionsBox.put(session.id, session);
  }

  static Future<void> deleteSession(String id) async {
    await sessionsBox.delete(id);
  }

  static WorkSession? getSession(String id) {
    return sessionsBox.get(id);
  }

  // Calculs pour le dashboard
  static double getTotalHoursForMonth(int year, int month) {
    final sessions = getSessionsByMonth(year, month);
    return sessions.fold(0.0, (sum, session) => 
        sum + session.normalHours + session.overtimeHours);
  }

  static double getTotalSalaryForMonth(int year, int month) {
    final sessions = getSessionsByMonth(year, month);
    return sessions.fold(0.0, (sum, session) => sum + session.dailySalary);
  }

  static double getNormalHoursForMonth(int year, int month) {
    final sessions = getSessionsByMonth(year, month);
    return sessions.fold(0.0, (sum, session) => sum + session.normalHours);
  }

  static double getOvertimeHoursForMonth(int year, int month) {
    final sessions = getSessionsByMonth(year, month);
    return sessions.fold(0.0, (sum, session) => sum + session.overtimeHours);
  }

  // Suppression de toutes les données
  static Future<void> deleteAllData() async {
    await settingsBox.clear();
    await sessionsBox.clear();
  }

  // Fermeture de la base de données
  static Future<void> close() async {
    await settingsBox.close();
    await sessionsBox.close();
  }
} 