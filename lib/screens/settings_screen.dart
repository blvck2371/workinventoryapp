import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import '../controllers/main_controller.dart';
import '../models/user_settings.dart' as models;
import '../services/pdf_service.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final MainController controller = Get.find<MainController>();
  final _formKey = GlobalKey<FormState>();
  final _hourlyRateController = TextEditingController();
  
  models.TimeOfDay _breakStart = models.TimeOfDay(hour: 12, minute: 0);
  models.TimeOfDay _breakEnd = models.TimeOfDay(hour: 13, minute: 0);
  models.TimeOfDay _overtimeStart = models.TimeOfDay(hour: 16, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final settings = controller.userSettings.value;
    if (settings != null) {
      _hourlyRateController.text = settings.hourlyRate.toString();
      _breakStart = settings.defaultBreakStart;
      _breakEnd = settings.defaultBreakEnd;
      _overtimeStart = settings.overtimeStart;
    }
  }

  @override
  void dispose() {
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salaire horaire
              _buildSection(
                'Salaire net par heure',
                _buildHourlyRateField(),
              ),
              
              const SizedBox(height: 24),
              
              // Pause par défaut
              _buildSection(
                'Pause habituelle',
                _buildBreakTimeFields(),
              ),
              
              const SizedBox(height: 24),
              
              // Heures supplémentaires
              _buildSection(
                'Début des heures supplémentaires',
                _buildOvertimeField(),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  child: const Text(
                    'Sauvegarder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Section export
              _buildExportSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildHourlyRateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextFormField(
        controller: _hourlyRateController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          hintText: 'Ex: 10.50',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixText: '€/h',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez saisir votre salaire horaire';
          }
          final rate = double.tryParse(value);
          if (rate == null || rate <= 0) {
            return 'Veuillez saisir un montant valide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBreakTimeFields() {
    return Row(
      children: [
        Expanded(
          child: _buildTimePickerField(
            'Début',
            _breakStart.format(),
            () => _showTimePicker(true),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'à',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimePickerField(
            'Fin',
            _breakEnd.format(),
            () => _showTimePicker(false),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField(String label, String time, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOvertimeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _showOvertimePicker(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Heure de début',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _overtimeStart.format(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export et données',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download, color: AppColors.primary),
                title: const Text('Exporter le rapport mensuel'),
                subtitle: const Text('Générer un PDF avec les détails'),
                onTap: () => _showExportDialog(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Supprimer toutes les données'),
                subtitle: const Text('Attention : action irréversible'),
                onTap: _showDeleteConfirmation,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTimePicker(bool isStart) {
    DatePicker.showTimePicker(
      context,
      currentTime: DateTime.now(),
      locale: LocaleType.fr,
      onConfirm: (time) {
        setState(() {
          if (isStart) {
            _breakStart = models.TimeOfDay(hour: time.hour, minute: time.minute);
          } else {
            _breakEnd = models.TimeOfDay(hour: time.hour, minute: time.minute);
          }
        });
      },
    );
  }

  void _showOvertimePicker() {
    DatePicker.showTimePicker(
      context,
      currentTime: DateTime.now(),
      locale: LocaleType.fr,
      onConfirm: (time) {
        setState(() {
          _overtimeStart = models.TimeOfDay(hour: time.hour, minute: time.minute);
        });
      },
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = models.UserSettings(
        hourlyRate: double.parse(_hourlyRateController.text),
        defaultBreakStart: _breakStart,
        defaultBreakEnd: _breakEnd,
        overtimeStart: _overtimeStart,
        isFirstTime: false,
      );

      await controller.saveSettings(settings);
      
      Get.snackbar(
        'Succès',
        'Paramètres sauvegardés',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
      
      Get.back();
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Attention',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cette action va supprimer définitivement :',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Tous vos paramètres de configuration\n'
              '• Toutes vos sessions de travail\n'
              '• Toutes vos données de salaire\n'
              '• Toute votre historique',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cette action est irréversible et ne peut pas être annulée.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Supprimer tout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _showExportDialog() {
    final currentDate = DateTime.now();
    final currentYear = currentDate.year;
    final currentMonth = currentDate.month;
    
    // Variables pour la période sélectionnée
    int selectedYear = currentYear;
    int selectedMonth = currentMonth;
    bool isAnnualReport = false; // false = mensuel, true = annuel
    
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.file_download,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Exporter le rapport',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choisissez le type de rapport et la période :',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Sélecteur de type de rapport
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Radio<bool>(
                          value: false,
                          groupValue: isAnnualReport,
                          onChanged: (value) {
                            setState(() {
                              isAnnualReport = false;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        title: const Text(
                          'Rapport mensuel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          'Détails des missions par mois',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Radio<bool>(
                          value: true,
                          groupValue: isAnnualReport,
                          onChanged: (value) {
                            setState(() {
                              isAnnualReport = true;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        title: const Text(
                          'Rapport annuel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: const Text(
                          'Vue d\'ensemble de l\'année complète',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Sélecteur de période
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: InkWell(
                    onTap: () => isAnnualReport 
                        ? _showYearPicker(context, selectedYear, (year) {
                            setState(() {
                              selectedYear = year;
                            });
                          })
                        : _showMonthYearPicker(context, selectedYear, selectedMonth, (year, month) {
                            setState(() {
                              selectedYear = year;
                              selectedMonth = month;
                            });
                          }),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAnnualReport ? 'Année sélectionnée :' : 'Période sélectionnée :',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            isAnnualReport 
                                ? selectedYear.toString()
                                : DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(selectedYear, selectedMonth)),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Informations sur les données disponibles
                FutureBuilder<List<dynamic>>(
                  future: Future.value(controller.getAllSessions()
                      .where((session) => isAnnualReport 
                          ? session.date.year == selectedYear
                          : session.date.year == selectedYear && session.date.month == selectedMonth)
                      .toList()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sessions = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sessions.isNotEmpty ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sessions.isNotEmpty ? AppColors.success : AppColors.error,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              sessions.isNotEmpty ? Icons.check_circle : Icons.info,
                              color: sessions.isNotEmpty ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sessions.isNotEmpty 
                                    ? '${sessions.length} mission(s) trouvée(s) pour ${isAnnualReport ? 'cette année' : 'cette période'}'
                                    : 'Aucune mission enregistrée pour ${isAnnualReport ? 'cette année' : 'cette période'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: sessions.isNotEmpty ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _generatePdfReport(selectedYear, selectedMonth, isAnnualReport);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Générer le rapport'),
              ),
            ],
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          );
        },
      ),
    );
  }
  
  void _showYearPicker(BuildContext context, int currentYear, Function(int) onChanged) {
    int selectedYear = currentYear;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Choisir l\'année',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedYear--;
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                      color: AppColors.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        selectedYear.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedYear++;
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Année sélectionnée',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              onChanged(selectedYear);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
  
  void _showMonthYearPicker(BuildContext context, int currentYear, int currentMonth, Function(int, int) onChanged) {
    int selectedYear = currentYear;
    int selectedMonth = currentMonth;
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Choisir la période',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sélecteur d'année
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Année :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedYear--;
                            });
                          },
                          icon: const Icon(Icons.chevron_left),
                          color: AppColors.primary,
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              selectedYear++;
                            });
                          },
                          icon: const Icon(Icons.chevron_right),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Sélecteur de mois
                const Text(
                  'Mois :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(12, (index) {
                    final month = index + 1;
                    final isSelected = month == selectedMonth;
                    final isCurrentMonth = month == DateTime.now().month && selectedYear == DateTime.now().year;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedMonth = month;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentMonth ? AppColors.success : AppColors.border,
                            width: isCurrentMonth ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          DateFormat('MMM', 'fr_FR').format(DateTime(selectedYear, month)),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              onChanged(selectedYear, selectedMonth);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<void> _generatePdfReport(int year, int month, bool isAnnualReport) async {
    try {
      // Afficher un indicateur de chargement
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Génération du rapport...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Veuillez patienter',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Récupérer les sessions selon le type de rapport
      final sessions = controller.getAllSessions()
          .where((session) => isAnnualReport 
              ? session.date.year == year
              : session.date.year == year && session.date.month == month)
          .toList();
      
      // Récupérer les paramètres utilisateur
      final settings = controller.userSettings.value;
      if (settings == null) {
        throw Exception('Paramètres utilisateur non configurés');
      }
      
      // Générer le PDF
      final String filePath = isAnnualReport
          ? await PdfService.generateAnnualReport(
              sessions,
              settings,
              year,
            )
          : await PdfService.generateMonthlyReport(
              sessions,
              settings,
              year,
              month,
            );
      
      // Fermer le dialogue de chargement
      Get.back();
      
      // Afficher un message de succès
      final String documentsPath = await PdfService.getDocumentsPath();
      final String folderName = documentsPath.contains('Download') 
          ? 'Téléchargements/WorkInventory' 
          : 'Documents de l\'application/WorkInventory';
      final String message = documentsPath.contains('Download')
          ? 'Le rapport PDF a été sauvegardé dans $folderName'
          : 'Le rapport PDF a été sauvegardé dans $folderName (dossier privé de l\'app)';
      
      Get.snackbar(
        '✅ Rapport généré',
        message,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 24,
        ),
      );
      
      // Afficher le chemin dans la console pour debug
      print('PDF généré: $filePath');
      print('Dossier des documents: $documentsPath');
      
    } catch (e) {
      // Fermer le dialogue de chargement
      Get.back();
      
      // Afficher un message d'erreur
      Get.snackbar(
        '❌ Erreur',
        'Une erreur est survenue lors de la génération du rapport',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(
          Icons.error,
          color: Colors.white,
          size: 24,
        ),
      );
    }
  }

  Future<void> _deleteAllData() async {
    try {
      // Afficher un indicateur de chargement
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Suppression en cours...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Veuillez patienter',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Supprimer toutes les données
      await controller.deleteAllData();
      
      // Fermer le dialogue de chargement
      Get.back();
      
      // Afficher un message de succès
      Get.snackbar(
        'Succès',
        'Toutes les données ont été supprimées',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Rediriger vers l'onboarding
      Get.offAllNamed('/onboarding');
      
    } catch (e) {
      // Fermer le dialogue de chargement
      Get.back();
      
      // Afficher un message d'erreur
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la suppression des données',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
} 