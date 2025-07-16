import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/user_settings.dart';
import '../models/work_session.dart';
import '../services/hive_service.dart';

class MainController extends GetxController {
  final _uuid = Uuid();
  
  // Variables observables
  var userSettings = Rxn<UserSettings>();
  var currentMonthSessions = <WorkSession>[].obs;
  var isLoading = false.obs;
  
  // Variables pour le mois actuel
  var currentYear = DateTime.now().year;
  var currentMonth = DateTime.now().month;

  @override
  void onInit() {
    super.onInit();
    // Charger les données de manière asynchrone pour éviter de bloquer l'UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
      loadCurrentMonthSessions();
    });
  }

  // Charger les paramètres utilisateur
  Future<void> _loadSettings() async {
    isLoading.value = true;
    try {
      final settings = HiveService.getSettings();
      if (settings != null) {
        userSettings.value = settings;
      } else {
        // Paramètres par défaut
        userSettings.value = UserSettings(
          hourlyRate: 10.0,
          defaultBreakStart: TimeOfDay(hour: 12, minute: 0),
          defaultBreakEnd: TimeOfDay(hour: 13, minute: 0),
          overtimeStart: TimeOfDay(hour: 16, minute: 0),
          isFirstTime: true,
        );
        // Ne pas sauvegarder automatiquement les paramètres par défaut
        // L'utilisateur doit les configurer via l'onboarding
      }
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
      // En cas d'erreur, créer des paramètres par défaut
      userSettings.value = UserSettings(
        hourlyRate: 10.0,
        defaultBreakStart: TimeOfDay(hour: 12, minute: 0),
        defaultBreakEnd: TimeOfDay(hour: 13, minute: 0),
        overtimeStart: TimeOfDay(hour: 16, minute: 0),
        isFirstTime: true,
      );
    } finally {
      isLoading.value = false;
      update(); // Forcer la mise à jour de l'interface
    }
  }

  // Charger les sessions du mois actuel
  Future<void> loadCurrentMonthSessions() async {
    try {
      final sessions = HiveService.getSessionsByMonth(currentYear, currentMonth);
      currentMonthSessions.value = sessions;
      // Forcer la mise à jour de l'interface après le chargement
      update();
    } catch (e) {
      print('Erreur lors du chargement des sessions: $e');
    }
  }

  // Sauvegarder les paramètres
  Future<void> saveSettings(UserSettings settings) async {
    try {
      await HiveService.saveSettings(settings);
      userSettings.value = settings;
      // Recharger les sessions pour mettre à jour les calculs
      await loadCurrentMonthSessions();
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  // Ajouter une nouvelle session
  Future<void> addSession(WorkSession session) async {
    try {
      await HiveService.saveSession(session);
      await loadCurrentMonthSessions();
      // Forcer la mise à jour de l'interface
      update();
    } catch (e) {
      print('Erreur lors de l\'ajout de la session: $e');
      rethrow; // Propager l'erreur pour la gestion dans l'UI
    }
  }

  // Supprimer une session
  Future<void> deleteSession(String id) async {
    try {
      await HiveService.deleteSession(id);
      await loadCurrentMonthSessions();
    } catch (e) {
      print('Erreur lors de la suppression de la session: $e');
    }
  }

  // Mettre à jour une session
  Future<void> updateSession(WorkSession session) async {
    try {
      await HiveService.saveSession(session);
      await loadCurrentMonthSessions();
    } catch (e) {
      print('Erreur lors de la mise à jour de la session: $e');
    }
  }

  // Générer un ID unique
  String generateId() {
    return _uuid.v4();
  }

  // Calculs pour le dashboard
  double get totalHoursThisMonth {
    return HiveService.getTotalHoursForMonth(currentYear, currentMonth);
  }

  double get totalSalaryThisMonth {
    return HiveService.getTotalSalaryForMonth(currentYear, currentMonth);
  }

  double get normalHoursThisMonth {
    return HiveService.getNormalHoursForMonth(currentYear, currentMonth);
  }

  double get overtimeHoursThisMonth {
    return HiveService.getOvertimeHoursForMonth(currentYear, currentMonth);
  }

  // Changer de mois
  void changeMonth(int year, int month) {
    currentYear = year;
    currentMonth = month;
    loadCurrentMonthSessions();
  }

  // Obtenir toutes les sessions (pour l'historique)
  List<WorkSession> getAllSessions() {
    return HiveService.getAllSessions();
  }

  // Vérifier si c'est la première utilisation
  bool get isFirstTime {
    return userSettings.value?.isFirstTime ?? true;
  }

  // Marquer comme configuré
  Future<void> markAsConfigured() async {
    if (userSettings.value != null) {
      final updatedSettings = userSettings.value!.copyWith(isFirstTime: false);
      await saveSettings(updatedSettings);
      update(); // Forcer la mise à jour de l'interface
    }
  }

  // Supprimer toutes les données
  Future<void> deleteAllData() async {
    try {
      isLoading.value = true;
      await HiveService.deleteAllData();
      
      // Réinitialiser les paramètres utilisateur
      userSettings.value = UserSettings(
        hourlyRate: 10.0,
        defaultBreakStart: TimeOfDay(hour: 12, minute: 0),
        defaultBreakEnd: TimeOfDay(hour: 13, minute: 0),
        overtimeStart: TimeOfDay(hour: 16, minute: 0),
        isFirstTime: true,
      );
      
      // Vider la liste des sessions
      currentMonthSessions.clear();
      
      // Recharger les données
      await _loadSettings();
      await loadCurrentMonthSessions();
      
    } catch (e) {
      print('Erreur lors de la suppression des données: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Recharger toutes les données
  Future<void> refreshAllData() async {
    await _loadSettings();
    await loadCurrentMonthSessions();
    update();
  }

  // Forcer la mise à jour de l'interface
  void updateUI() {
    update();
  }
} 