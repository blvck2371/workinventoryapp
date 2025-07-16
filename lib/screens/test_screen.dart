import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../utils/colors.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Test'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'État de l\'application',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // État du chargement
            Obx(() => Card(
              child: ListTile(
                leading: Icon(
                  controller.isLoading.value ? Icons.hourglass_empty : Icons.check_circle,
                  color: controller.isLoading.value ? AppColors.warning : AppColors.success,
                ),
                title: Text('Chargement'),
                subtitle: Text(controller.isLoading.value ? 'En cours...' : 'Terminé'),
              ),
            )),
            
            const SizedBox(height: 10),
            
            // État des paramètres
            Obx(() => Card(
              child: ListTile(
                leading: Icon(
                  controller.userSettings.value != null ? Icons.settings : Icons.settings_input_component,
                  color: controller.userSettings.value != null ? AppColors.success : AppColors.warning,
                ),
                title: Text('Paramètres'),
                subtitle: Text(controller.userSettings.value != null 
                  ? 'Configurés (${controller.userSettings.value!.hourlyRate}€/h)'
                  : 'Non configurés'),
              ),
            )),
            
            const SizedBox(height: 10),
            
            // État de la première utilisation
            Obx(() => Card(
              child: ListTile(
                leading: Icon(
                  controller.isFirstTime ? Icons.first_page : Icons.done_all,
                  color: controller.isFirstTime ? AppColors.warning : AppColors.success,
                ),
                title: Text('Première utilisation'),
                subtitle: Text(controller.isFirstTime ? 'Oui' : 'Non'),
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Boutons de test
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.updateUI(),
                    child: const Text('Actualiser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/onboarding'),
                    child: const Text('Onboarding'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/home'),
                    child: const Text('Dashboard'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed('/settings'),
                    child: const Text('Paramètres'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 