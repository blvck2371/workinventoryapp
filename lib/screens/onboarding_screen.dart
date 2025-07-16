import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../controllers/main_controller.dart';
import '../models/user_settings.dart';
import '../utils/colors.dart';
import '../models/user_settings.dart' as models;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final MainController controller = Get.find<MainController>();
  
  final _formKey = GlobalKey<FormState>();
  final _hourlyRateController = TextEditingController(text: '10.0');
  
  models.TimeOfDay _breakStart = models.TimeOfDay(hour: 12, minute: 0);
  models.TimeOfDay _breakEnd = models.TimeOfDay(hour: 13, minute: 0);
  models.TimeOfDay _overtimeStart = models.TimeOfDay(hour: 16, minute: 0);

  @override
  void dispose() {
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Titre
                Text(
                  'Configuration initiale',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Configurez vos paramètres de travail pour commencer',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
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
                
                const Spacer(),
                
                // Bouton de validation
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Commencer',
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
      final settings = UserSettings(
        hourlyRate: double.parse(_hourlyRateController.text),
        defaultBreakStart: _breakStart,
        defaultBreakEnd: _breakEnd,
        overtimeStart: _overtimeStart,
        isFirstTime: false,
      );

      await controller.saveSettings(settings);
      await controller.markAsConfigured();
      
      Get.offAllNamed('/home');
    }
  }
} 