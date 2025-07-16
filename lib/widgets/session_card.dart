import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/work_session.dart';
import '../utils/colors.dart';

class SessionCard extends StatelessWidget {
  final WorkSession session;
  final VoidCallback? onTap;

  const SessionCard({
    Key? key,
    required this.session,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec date et salaire
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(session.dailySalary),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Horaires
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeInfo(
                        'Début',
                        session.startTime.format(),
                        Icons.play_arrow,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTimeInfo(
                        'Fin',
                        session.endTime.format(),
                        Icons.stop,
                        AppColors.error,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Pause (si applicable)
                if (session.breakStartTime != null && session.breakEndTime != null)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInfo(
                          'Pause',
                          '${session.breakStartTime!.format()} - ${session.breakEndTime!.format()}',
                          Icons.pause,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 12),
                
                // Lieu et description
                if (session.location.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            session.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                if (session.description.isNotEmpty)
                  Text(
                    session.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 12),
                
                // Résumé des heures
                Row(
                  children: [
                    _buildHourBadge(
                      'Total: ${session.formattedDuration}',
                      AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    if (session.normalHours > 0)
                      _buildHourBadge(
                        'Normales: ${session.normalHours.toStringAsFixed(1)}h',
                        AppColors.info,
                      ),
                    const SizedBox(width: 8),
                    if (session.overtimeHours > 0)
                      _buildHourBadge(
                        'Supp: ${session.overtimeHours.toStringAsFixed(1)}h',
                        AppColors.overtime,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
} 