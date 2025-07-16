import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../controllers/main_controller.dart';
import '../models/work_session.dart';
import '../models/user_settings.dart' as app_models;
import '../utils/colors.dart';

class EditSessionScreen extends StatefulWidget {
  final WorkSession session;

  const EditSessionScreen({Key? key, required this.session}) : super(key: key);

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  final MainController controller = Get.find<MainController>();
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDate;
  late app_models.TimeOfDay _startTime;
  late app_models.TimeOfDay _endTime;
  app_models.TimeOfDay? _breakStartTime;
  app_models.TimeOfDay? _breakEndTime;
  bool _hasBreak = false;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
  }

  void _loadSessionData() {
    final session = widget.session;
    
    _selectedDate = session.date;
    _startTime = session.startTime;
    _endTime = session.endTime;
    _locationController.text = session.location;
    _descriptionController.text = session.description;
    
    // Charger les données de pause si elles existent
    if (session.breakStartTime != null && session.breakEndTime != null) {
      _hasBreak = true;
      _breakStartTime = session.breakStartTime;
      _breakEndTime = session.breakEndTime;
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
        title: const Text('Modifier la mission'),
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
              _buildDateField(),
              
              const SizedBox(height: 24),
              
              // Horaires
              _buildTimeFields(),
              
              const SizedBox(height: 24),
              
              // Pause
              _buildBreakFields(),
              
              const SizedBox(height: 24),
              
              // Lieu
              _buildLocationField(),
              
              const SizedBox(height: 24),
              
              // Description
              _buildDescriptionField(),
              
              const SizedBox(height: 32),
              
              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _updateSession,
                  child: const Text(
                    'Modifier la mission',
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date de la mission',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horaires',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
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
            const Text(
              'à',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
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

  void _loadDefaultSettings() {
    final settings = controller.userSettings.value;
    if (settings != null) {
      setState(() {
        _breakStartTime = settings.defaultBreakStart;
        _breakEndTime = settings.defaultBreakEnd;
      });
    }
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lieu de la mission',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
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
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Description de la mission...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
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
            _startTime = app_models.TimeOfDay(hour: time.hour, minute: time.minute);
          } else {
            _endTime = app_models.TimeOfDay(hour: time.hour, minute: time.minute);
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
            _breakStartTime = app_models.TimeOfDay(hour: time.hour, minute: time.minute);
          } else {
            _breakEndTime = app_models.TimeOfDay(hour: time.hour, minute: time.minute);
          }
        });
      },
    );
  }

  Future<void> _updateSession() async {
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
      final settings = controller.userSettings.value ?? app_models.UserSettings(
        hourlyRate: 10.0,
        defaultBreakStart: app_models.TimeOfDay(hour: 12, minute: 0),
        defaultBreakEnd: app_models.TimeOfDay(hour: 13, minute: 0),
        overtimeStart: app_models.TimeOfDay(hour: 16, minute: 0),
        isFirstTime: true,
      );

      final updatedSession = WorkSession(
        id: widget.session.id, // Garder le même ID
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
                      'Modification...',
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

        await controller.updateSession(updatedSession);
        
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
          '✅ Modification effectuée avec succès',
          'Votre mission a été modifiée et ajoutée au tableau de bord',
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
          'Une erreur est survenue lors de la modification',
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