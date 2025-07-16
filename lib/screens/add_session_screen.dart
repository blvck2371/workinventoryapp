import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import '../controllers/main_controller.dart';
import '../models/work_session.dart';
import '../models/user_settings.dart' as models;
import '../utils/colors.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({Key? key}) : super(key: key);

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final MainController controller = Get.find<MainController>();
  final _formKey = GlobalKey<FormState>();
  
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  models.TimeOfDay _startTime = models.TimeOfDay(hour: 9, minute: 0);
  models.TimeOfDay? _breakStartTime;
  models.TimeOfDay? _breakEndTime;
  models.TimeOfDay _endTime = models.TimeOfDay(hour: 17, minute: 0);
  
  bool _hasBreak = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultSettings();
  }

  void _loadDefaultSettings() {
    final settings = controller.userSettings.value;
    if (settings != null) {
      _breakStartTime = settings.defaultBreakStart;
      _breakEndTime = settings.defaultBreakEnd;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvelle mission'),
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
              // Date
              _buildSection(
                'Date',
                _buildDateField(),
              ),
              
              const SizedBox(height: 24),
              
              // Horaires
              _buildSection(
                'Horaires',
                _buildTimeFields(),
              ),
              
              const SizedBox(height: 24),
              
              // Pause
              _buildSection(
                'Pause',
                _buildBreakFields(),
              ),
              
              const SizedBox(height: 24),
              
              // Lieu
              _buildSection(
                'Lieu',
                _buildLocationField(),
              ),
              
              const SizedBox(height: 24),
              
              // Description
              _buildSection(
                'Description (optionnel)',
                _buildDescriptionField(),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveSession,
                  child: const Text(
                    'Enregistrer la mission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
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

  Widget _buildDateField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: _showDatePicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate),
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

  Widget _buildTimeFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                'Début',
                _startTime.format(),
                () => _showTimePicker(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeField(
                'Fin',
                _endTime.format(),
                () => _showTimePicker(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, String time, VoidCallback onTap) {
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

  Widget _buildBreakFields() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _hasBreak,
              onChanged: (value) {
                setState(() {
                  _hasBreak = value ?? false;
                  if (!_hasBreak) {
                    _breakStartTime = null;
                    _breakEndTime = null;
                  } else {
                    _loadDefaultSettings();
                  }
                });
              },
              activeColor: AppColors.primary,
            ),
            const Text(
              'J\'ai pris une pause',
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (_hasBreak) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  'Début pause',
                  _breakStartTime?.format() ?? '--:--',
                  () => _showBreakTimePicker(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  'Fin pause',
                  _breakEndTime?.format() ?? '--:--',
                  () => _showBreakTimePicker(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        hintText: 'Ex: Bureau principal, Site client...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez saisir le lieu de la mission';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: const InputDecoration(
        hintText: 'Description de la mission...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('fr', 'FR'),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }

  void _showTimePicker(bool isStart) {
    DatePicker.showTimePicker(
      context,
      currentTime: DateTime.now(),
      locale: LocaleType.fr,
      onConfirm: (time) {
        setState(() {
          if (isStart) {
            _startTime = models.TimeOfDay(hour: time.hour, minute: time.minute);
          } else {
            _endTime = models.TimeOfDay(hour: time.hour, minute: time.minute);
          }
        });
      },
    );
  }

  void _showBreakTimePicker(bool isStart) {
    DatePicker.showTimePicker(
      context,
      currentTime: DateTime.now(),
      locale: LocaleType.fr,
      onConfirm: (time) {
        setState(() {
          if (isStart) {
            _breakStartTime = models.TimeOfDay(hour: time.hour, minute: time.minute);
          } else {
            _breakEndTime = models.TimeOfDay(hour: time.hour, minute: time.minute);
          }
        });
      },
    );
  }

  Future<void> _saveSession() async {
    if (_formKey.currentState!.validate()) {
      // Validation des heures
      final startMinutes = _startTime.toMinutes();
      final endMinutes = _endTime.toMinutes();
      
      if (endMinutes <= startMinutes) {
        Get.snackbar(
          'Erreur',
          'L\'heure de fin doit être après l\'heure de début',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      // Validation de la pause si elle est cochée
      if (_hasBreak && (_breakStartTime == null || _breakEndTime == null)) {
        Get.snackbar(
          'Erreur',
          'Veuillez saisir les heures de début et fin de pause',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      // Utiliser les paramètres existants ou des paramètres par défaut
      final settings = controller.userSettings.value ?? models.UserSettings(
        hourlyRate: 10.0,
        defaultBreakStart: models.TimeOfDay(hour: 12, minute: 0),
        defaultBreakEnd: models.TimeOfDay(hour: 13, minute: 0),
        overtimeStart: models.TimeOfDay(hour: 16, minute: 0),
        isFirstTime: true,
      );

      final session = WorkSession(
        id: controller.generateId(),
        date: _selectedDate,
        startTime: _startTime,
        breakStartTime: _hasBreak ? _breakStartTime : null,
        breakEndTime: _hasBreak ? _breakEndTime : null,
        endTime: _endTime,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        hourlyRate: settings.hourlyRate,
        overtimeStart: settings.overtimeStart,
      );

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
                      'Enregistrement...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );

        await controller.addSession(session);
        
        // Fermer le dialogue de chargement
        Get.back();
        
        // Forcer la mise à jour de l'interface
        controller.updateUI();
        
        // Attendre un peu avant de revenir au dashboard
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Rediriger vers le dashboard (home) et remplacer l'écran actuel
        Get.offAllNamed('/home');
        
        // Afficher un message de succès après la redirection
        await Future.delayed(const Duration(milliseconds: 200));
        Get.snackbar(
          '✅ Enregistrement effectué avec succès',
          'Votre mission a été sauvegardée et ajoutée au tableau de bord',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 24,
          ),
        );
      } catch (e) {
        // Fermer le dialogue de chargement
        Get.back();
        
        Get.snackbar(
          '❌ Erreur',
          'Une erreur est survenue lors de l\'enregistrement',
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
  }
} 