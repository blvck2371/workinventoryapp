import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/main_controller.dart';
import '../utils/colors.dart';
import '../widgets/simple_month_selector.dart';
import '../widgets/session_card.dart';
import '../widgets/stats_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late MainController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MainController>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les données quand on revient sur l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Contenu principal
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadCurrentMonthSessions();
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sélecteur de mois
                      SimpleMonthSelector(
                        onMonthChanged: (year, month) {
                          controller.changeMonth(year, month);
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Statistiques
                      GetBuilder<MainController>(
                        builder: (controller) => _buildStatsSection(controller),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sessions du mois
                      _buildSessionsSection(controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-session'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle mission'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Suivi de vos heures de travail',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: const Icon(Icons.settings, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(MainController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Résumé du mois',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Heures totales',
                value: '${controller.totalHoursThisMonth.toStringAsFixed(1)}h',
                icon: Icons.access_time,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Salaire estimé',
                value: '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(controller.totalSalaryThisMonth)}',
                icon: Icons.euro,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Heures normales',
                value: '${controller.normalHoursThisMonth.toStringAsFixed(1)}h',
                icon: Icons.schedule,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Heures supp.',
                value: '${controller.overtimeHoursThisMonth.toStringAsFixed(1)}h',
                icon: Icons.timer,
                color: AppColors.overtime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionsSection(MainController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Missions du mois',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => Get.toNamed('/history'),
              icon: const Icon(Icons.history, size: 16),
              label: const Text('Historique'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final sessions = controller.currentMonthSessions;
          
          if (sessions.isEmpty) {
            return _buildEmptyState();
          }
          
          return Column(
            children: sessions.map((session) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SessionCard(
                  session: session,
                  onTap: () => Get.toNamed('/session-details', arguments: session),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.work_outline,
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
        ],
      ),
    );
  }
} 