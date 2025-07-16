import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/main_controller.dart';
import '../models/work_session.dart';
import '../utils/colors.dart';
import '../widgets/session_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistiques globales
          _buildGlobalStats(controller),
          
          // Liste des sessions
          Expanded(
            child: Obx(() {
              final sessions = controller.getAllSessions();
              
              if (sessions.isEmpty) {
                return _buildEmptyState();
              }
              
              // Trier les sessions par date (plus récentes en premier)
              sessions.sort((a, b) => b.date.compareTo(a.date));
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SessionCard(
                      session: session,
                      onTap: () => Get.toNamed('/session-details', arguments: session),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalStats(MainController controller) {
    final sessions = controller.getAllSessions();
    final totalHours = sessions.fold(0.0, (sum, session) => 
        sum + session.normalHours + session.overtimeHours);
    final totalSalary = sessions.fold(0.0, (sum, session) => 
        sum + session.dailySalary);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary),
              const SizedBox(width: 12),
              const Text(
                'Résumé global',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total missions',
                  '${sessions.length}',
                  Icons.work,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Heures totales',
                  '${totalHours.toStringAsFixed(1)}h',
                  Icons.access_time,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Salaire total',
                  '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalSalary)}',
                  Icons.euro,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Moyenne/jour',
                  sessions.isNotEmpty 
                      ? '${(totalSalary / sessions.length).toStringAsFixed(0)}€'
                      : '0€',
                  Icons.trending_up,
                  AppColors.overtime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune mission enregistrée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par ajouter votre première mission',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/add-session'),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une mission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Filtrer l\'historique'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Fonctionnalité de filtrage à implémenter'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
} 