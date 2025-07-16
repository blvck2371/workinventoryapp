import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import '../models/work_session.dart';
import '../models/user_settings.dart';

class PdfService {
  static Future<String> generateAnnualReport(
    List<WorkSession> sessions,
    UserSettings settings,
    int year,
  ) async {
    // Créer un nouveau document PDF
    final PdfDocument document = PdfDocument();
    
    // Ajouter une page
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    
    // Définir les couleurs
    final PdfColor primaryColor = PdfColor(33, 150, 243);
    final PdfColor secondaryColor = PdfColor(158, 158, 158);
    final PdfColor successColor = PdfColor(76, 175, 80);
    final PdfColor warningColor = PdfColor(255, 152, 0);
    final PdfColor whiteColor = PdfColor(255, 255, 255);
    final PdfColor blackColor = PdfColor(0, 0, 0);
    
    // Définir les polices
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
    
    // Titre principal
    graphics.drawString(
      'Rapport annuel - $year',
      titleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 50, 500, 30),
    );
    
    // Informations générales
    final double totalHours = sessions.fold(0.0, (sum, session) => 
        sum + session.normalHours + session.overtimeHours);
    final double totalSalary = sessions.fold(0.0, (sum, session) => 
        sum + session.dailySalary);
    final double normalHours = sessions.fold(0.0, (sum, session) => 
        sum + session.normalHours);
    final double overtimeHours = sessions.fold(0.0, (sum, session) => 
        sum + session.overtimeHours);
    
    // Statistiques générales
    graphics.drawString(
      'Statistiques annuelles',
      subtitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 100, 500, 20),
    );
    
    // Tableau des statistiques
    final PdfGrid statsGrid = PdfGrid();
    statsGrid.columns.add(count: 4);
    statsGrid.headers.add(1);
    
    // En-têtes
    final PdfGridRow headerRow = statsGrid.headers[0];
    headerRow.cells[0].value = 'Missions';
    headerRow.cells[1].value = 'Heures totales';
    headerRow.cells[2].value = 'Heures normales';
    headerRow.cells[3].value = 'Heures supp.';
    
    // Style des en-têtes
    headerRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(primaryColor),
      textBrush: PdfSolidBrush(whiteColor),
      font: headerFont,
    );
    
    // Données
    final PdfGridRow dataRow = statsGrid.rows.add();
    dataRow.cells[0].value = '${sessions.length}';
    dataRow.cells[1].value = '${totalHours.toStringAsFixed(1)}h';
    dataRow.cells[2].value = '${normalHours.toStringAsFixed(1)}h';
    dataRow.cells[3].value = '${overtimeHours.toStringAsFixed(1)}h';
    
    // Style des données
    dataRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(whiteColor),
      textBrush: PdfSolidBrush(blackColor),
      font: bodyFont,
    );
    
    // Positionner le tableau
    statsGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 130, 500, 50),
    );
    
    // Informations salariales
    graphics.drawString(
      'Informations salariales',
      subtitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 200, 500, 20),
    );
    
    final PdfGrid salaryGrid = PdfGrid();
    salaryGrid.columns.add(count: 3);
    salaryGrid.headers.add(1);
    
    final PdfGridRow salaryHeaderRow = salaryGrid.headers[0];
    salaryHeaderRow.cells[0].value = 'Taux horaire';
    salaryHeaderRow.cells[1].value = 'Salaire total';
    salaryHeaderRow.cells[2].value = 'Moyenne/mission';
    
    salaryHeaderRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(successColor),
      textBrush: PdfSolidBrush(whiteColor),
      font: headerFont,
    );
    
    final PdfGridRow salaryDataRow = salaryGrid.rows.add();
    salaryDataRow.cells[0].value = '${settings.hourlyRate.toStringAsFixed(2)}€/h';
    salaryDataRow.cells[1].value = '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalSalary)}';
    salaryDataRow.cells[2].value = sessions.isNotEmpty 
        ? '${(totalSalary / sessions.length).toStringAsFixed(0)}€'
        : '0€';
    
    salaryDataRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(whiteColor),
      textBrush: PdfSolidBrush(blackColor),
      font: bodyFont,
    );
    
    salaryGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 230, 500, 50),
    );
    
    // Statistiques par mois
    graphics.drawString(
      'Répartition par mois',
      subtitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 300, 500, 20),
    );
    
    if (sessions.isNotEmpty) {
      final PdfGrid monthlyGrid = PdfGrid();
      monthlyGrid.columns.add(count: 4);
      monthlyGrid.headers.add(1);
      
      final PdfGridRow monthlyHeaderRow = monthlyGrid.headers[0];
      monthlyHeaderRow.cells[0].value = 'Mois';
      monthlyHeaderRow.cells[1].value = 'Missions';
      monthlyHeaderRow.cells[2].value = 'Heures';
      monthlyHeaderRow.cells[3].value = 'Salaire';
      
      monthlyHeaderRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(secondaryColor),
        textBrush: PdfSolidBrush(whiteColor),
        font: headerFont,
      );
      
      // Grouper les sessions par mois
      final Map<int, List<WorkSession>> sessionsByMonth = {};
      for (final session in sessions) {
        final month = session.date.month;
        sessionsByMonth.putIfAbsent(month, () => []).add(session);
      }
      
      // Trier par mois
      final sortedMonths = sessionsByMonth.keys.toList()..sort();
      
      for (final month in sortedMonths) {
        final monthSessions = sessionsByMonth[month]!;
        final monthHours = monthSessions.fold(0.0, (sum, session) => 
            sum + session.normalHours + session.overtimeHours);
        final monthSalary = monthSessions.fold(0.0, (sum, session) => 
            sum + session.dailySalary);
        
        final PdfGridRow monthRow = monthlyGrid.rows.add();
        monthRow.cells[0].value = DateFormat('MMMM', 'fr_FR').format(DateTime(year, month));
        monthRow.cells[1].value = '${monthSessions.length}';
        monthRow.cells[2].value = '${monthHours.toStringAsFixed(1)}h';
        monthRow.cells[3].value = '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(monthSalary)}';
        
        monthRow.style = PdfGridRowStyle(
          backgroundBrush: PdfSolidBrush(whiteColor),
          textBrush: PdfSolidBrush(blackColor),
          font: bodyFont,
        );
      }
      
      // Ajouter une ligne de total
      final PdfGridRow totalRow = monthlyGrid.rows.add();
      totalRow.cells[0].value = 'TOTAL';
      totalRow.cells[1].value = '${sessions.length}';
      totalRow.cells[2].value = '${totalHours.toStringAsFixed(1)}h';
      totalRow.cells[3].value = '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalSalary)}';
      
      totalRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(successColor),
        textBrush: PdfSolidBrush(whiteColor),
        font: PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      );
      
      monthlyGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(50, 330, 500, 300),
      );
    } else {
      graphics.drawString(
        'Aucune mission enregistrée pour cette année',
        bodyFont,
        brush: PdfSolidBrush(secondaryColor),
        bounds: Rect.fromLTWH(50, 330, 500, 20),
      );
    }
    
    // Pied de page
    final String generatedDate = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.now());
    graphics.drawString(
      'Rapport généré le $generatedDate',
      smallFont,
      brush: PdfSolidBrush(secondaryColor),
      bounds: Rect.fromLTWH(50, 750, 500, 20),
    );
    
    // Sauvegarder le document selon la plateforme
    final String filePath = await _savePdfDocument(document, year, 0, true);
    document.dispose();
    
    return filePath;
  }
  
  static Future<String> generateMonthlyReport(
    List<WorkSession> sessions,
    UserSettings settings,
    int year,
    int month,
  ) async {
    // Créer un nouveau document PDF
    final PdfDocument document = PdfDocument();
    
    // Ajouter une page
    final PdfPage page = document.pages.add();
    final PdfGraphics graphics = page.graphics;
    
    // Définir les couleurs
    final PdfColor primaryColor = PdfColor(33, 150, 243);
    final PdfColor secondaryColor = PdfColor(158, 158, 158);
    final PdfColor successColor = PdfColor(76, 175, 80);
    final PdfColor warningColor = PdfColor(255, 152, 0);
    final PdfColor whiteColor = PdfColor(255, 255, 255);
    final PdfColor blackColor = PdfColor(0, 0, 0);
    
    // Définir les polices
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 8);
    
    // Titre principal
    final String monthName = DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(year, month));
    graphics.drawString(
      'Rapport mensuel - $monthName',
      titleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 50, 500, 30),
    );
    
    // Informations générales
    final double totalHours = sessions.fold(0.0, (sum, session) => 
        sum + session.normalHours + session.overtimeHours);
    final double totalSalary = sessions.fold(0.0, (sum, session) => 
        sum + session.dailySalary);
    final double normalHours = sessions.fold(0.0, (sum, session) => 
        sum + session.normalHours);
    final double overtimeHours = sessions.fold(0.0, (sum, session) => 
        sum + session.overtimeHours);
    
    // Statistiques générales
    graphics.drawString(
      'Statistiques générales',
      subtitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 100, 500, 20),
    );
    
    // Tableau des statistiques
    final PdfGrid statsGrid = PdfGrid();
    statsGrid.columns.add(count: 4);
    statsGrid.headers.add(1);
    
    // En-têtes
    final PdfGridRow headerRow = statsGrid.headers[0];
    headerRow.cells[0].value = 'Missions';
    headerRow.cells[1].value = 'Heures totales';
    headerRow.cells[2].value = 'Heures normales';
    headerRow.cells[3].value = 'Heures supp.';
    
    // Style des en-têtes
    headerRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(primaryColor),
      textBrush: PdfSolidBrush(whiteColor),
      font: headerFont,
    );
    
    // Données
    final PdfGridRow dataRow = statsGrid.rows.add();
    dataRow.cells[0].value = '${sessions.length}';
    dataRow.cells[1].value = '${totalHours.toStringAsFixed(1)}h';
    dataRow.cells[2].value = '${normalHours.toStringAsFixed(1)}h';
    dataRow.cells[3].value = '${overtimeHours.toStringAsFixed(1)}h';
    
    // Style des données
    dataRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(whiteColor),
      textBrush: PdfSolidBrush(blackColor),
      font: bodyFont,
    );
    
    // Positionner le tableau
    statsGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 130, 500, 50),
    );
    
    // Informations salariales
    graphics.drawString(
      'Informations salariales',
      subtitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 200, 500, 20),
    );
    
    final PdfGrid salaryGrid = PdfGrid();
    salaryGrid.columns.add(count: 3);
    salaryGrid.headers.add(1);
    
    final PdfGridRow salaryHeaderRow = salaryGrid.headers[0];
    salaryHeaderRow.cells[0].value = 'Taux horaire';
    salaryHeaderRow.cells[1].value = 'Salaire total';
    salaryHeaderRow.cells[2].value = 'Moyenne/jour';
    
    salaryHeaderRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(successColor),
      textBrush: PdfSolidBrush(whiteColor),
      font: headerFont,
    );
    
    final PdfGridRow salaryDataRow = salaryGrid.rows.add();
    salaryDataRow.cells[0].value = '${settings.hourlyRate.toStringAsFixed(2)}€/h';
    salaryDataRow.cells[1].value = '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalSalary)}';
    salaryDataRow.cells[2].value = sessions.isNotEmpty 
        ? '${(totalSalary / sessions.length).toStringAsFixed(0)}€'
        : '0€';
    
    salaryDataRow.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(whiteColor),
      textBrush: PdfSolidBrush(blackColor),
      font: bodyFont,
    );
    
    salaryGrid.draw(
      page: page,
      bounds: Rect.fromLTWH(50, 230, 500, 50),
    );
    
    // Détail des missions
    graphics.drawString(
      'Détail des missions',
      subtitleFont,
      brush: PdfSolidBrush(primaryColor),
      bounds: Rect.fromLTWH(50, 300, 500, 20),
    );
    
    if (sessions.isNotEmpty) {
      final PdfGrid sessionsGrid = PdfGrid();
      sessionsGrid.columns.add(count: 6);
      sessionsGrid.headers.add(1);
      
      final PdfGridRow sessionsHeaderRow = sessionsGrid.headers[0];
      sessionsHeaderRow.cells[0].value = 'Date';
      sessionsHeaderRow.cells[1].value = 'Début';
      sessionsHeaderRow.cells[2].value = 'Fin';
      sessionsHeaderRow.cells[3].value = 'Durée';
      sessionsHeaderRow.cells[4].value = 'Lieu';
      sessionsHeaderRow.cells[5].value = 'Salaire';
      
      sessionsHeaderRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(secondaryColor),
        textBrush: PdfSolidBrush(whiteColor),
        font: headerFont,
      );
      
      // Trier les sessions par date
      sessions.sort((a, b) => a.date.compareTo(b.date));
      
      // Calculer les totaux
      double totalDuration = 0.0;
      double totalSalary = 0.0;
      
      for (final session in sessions) {
        final PdfGridRow sessionRow = sessionsGrid.rows.add();
        sessionRow.cells[0].value = DateFormat('dd/MM/yyyy', 'fr_FR').format(session.date);
        sessionRow.cells[1].value = session.startTime.format();
        sessionRow.cells[2].value = session.endTime.format();
        sessionRow.cells[3].value = '${(session.normalHours + session.overtimeHours).toStringAsFixed(1)}h';
        sessionRow.cells[4].value = session.location;
        sessionRow.cells[5].value = '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(session.dailySalary)}';
        
        sessionRow.style = PdfGridRowStyle(
          backgroundBrush: PdfSolidBrush(whiteColor),
          textBrush: PdfSolidBrush(blackColor),
          font: bodyFont,
        );
        
        // Accumuler les totaux
        totalDuration += session.normalHours + session.overtimeHours;
        totalSalary += session.dailySalary;
      }
      
      // Ajouter une ligne de total
      final PdfGridRow totalRow = sessionsGrid.rows.add();
      totalRow.cells[0].value = 'TOTAL';
      totalRow.cells[1].value = '';
      totalRow.cells[2].value = '';
      totalRow.cells[3].value = '${totalDuration.toStringAsFixed(1)}h';
      totalRow.cells[4].value = '';
      totalRow.cells[5].value = '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(totalSalary)}';
      
      // Style de la ligne de total
      totalRow.style = PdfGridRowStyle(
        backgroundBrush: PdfSolidBrush(successColor),
        textBrush: PdfSolidBrush(whiteColor),
        font: PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      );
      
      sessionsGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(50, 330, 500, 300),
      );
    } else {
      graphics.drawString(
        'Aucune mission enregistrée pour ce mois',
        bodyFont,
        brush: PdfSolidBrush(secondaryColor),
        bounds: Rect.fromLTWH(50, 330, 500, 20),
      );
    }
    
    // Pied de page
    final String generatedDate = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(DateTime.now());
    graphics.drawString(
      'Rapport généré le $generatedDate',
      smallFont,
      brush: PdfSolidBrush(secondaryColor),
      bounds: Rect.fromLTWH(50, 750, 500, 20),
    );
    
    // Sauvegarder le document selon la plateforme
    final String filePath = await _savePdfDocument(document, year, month, false);
    document.dispose();
    
    return filePath;
  }
  
  static Future<String> _savePdfDocument(
    PdfDocument document,
    int year,
    int month,
    bool isAnnualReport,
  ) async {
    // Pour l'instant, utiliser seulement la méthode de stockage mobile
    // La fonctionnalité web sera ajoutée plus tard
    return await _savePdfToStorage(document, year, month, isAnnualReport);
  }
  
  static Future<String> _savePdfToStorage(
    PdfDocument document,
    int year,
    int month,
    bool isAnnualReport,
  ) async {
    // Demander les permissions de stockage
    final PermissionStatus storageStatus = await Permission.storage.request();
    final PermissionStatus manageStorageStatus = await Permission.manageExternalStorage.request();
    
    // Essayer d'abord le dossier Downloads
    if (storageStatus.isGranted || manageStorageStatus.isGranted) {
      try {
        final Directory downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final Directory workInventoryDir = Directory('${downloadsDir.path}/WorkInventory');
          if (!await workInventoryDir.exists()) {
            await workInventoryDir.create(recursive: true);
          }
          
          final String fileName = isAnnualReport 
              ? 'rapport_annuel_${year}.pdf'
              : 'rapport_${year}_${month.toString().padLeft(2, '0')}.pdf';
          final String filePath = '${workInventoryDir.path}/$fileName';
          
          final File file = File(filePath);
          await file.writeAsBytes(await document.save());
          
          return filePath;
        }
      } catch (e) {
        print('Erreur lors de la sauvegarde dans Downloads: $e');
      }
    }
    
    // Fallback vers le dossier Documents de l'app (toujours accessible)
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory workInventoryDir = Directory('${appDocDir.path}/WorkInventory');
    if (!await workInventoryDir.exists()) {
      await workInventoryDir.create(recursive: true);
    }
    
    final String fileName = isAnnualReport 
        ? 'rapport_annuel_${year}.pdf'
        : 'rapport_${year}_${month.toString().padLeft(2, '0')}.pdf';
    final String filePath = '${workInventoryDir.path}/$fileName';
    
    final File file = File(filePath);
    await file.writeAsBytes(await document.save());
    
    return filePath;
  }
  
  static Future<void> sharePdf(String filePath) async {
    // Cette fonction peut être utilisée pour partager le PDF
    // via d'autres packages comme share_plus
    print('PDF généré: $filePath');
  }
  
  static Future<String> getDocumentsPath() async {
    // Demander les permissions
    final PermissionStatus storageStatus = await Permission.storage.request();
    final PermissionStatus manageStorageStatus = await Permission.manageExternalStorage.request();
    
    // Essayer d'abord le dossier Downloads si les permissions sont accordées
    if (storageStatus.isGranted || manageStorageStatus.isGranted) {
      try {
        final Directory downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final Directory workInventoryDir = Directory('${downloadsDir.path}/WorkInventory');
          if (!await workInventoryDir.exists()) {
            await workInventoryDir.create(recursive: true);
          }
          return workInventoryDir.path;
        }
      } catch (e) {
        print('Erreur lors de l\'accès à Downloads: $e');
      }
    }
    
    // Fallback vers le dossier Documents de l'app
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory workInventoryDir = Directory('${appDocDir.path}/WorkInventory');
    if (!await workInventoryDir.exists()) {
      await workInventoryDir.create(recursive: true);
    }
    
    return workInventoryDir.path;
  }
  
  static Future<List<FileSystemEntity>> getSavedReports() async {
    try {
      final String documentsPath = await getDocumentsPath();
      final Directory dir = Directory(documentsPath);
      
      if (!await dir.exists()) {
        return [];
      }
      
      final List<FileSystemEntity> files = await dir.list().toList();
      return files.where((file) => file.path.endsWith('.pdf')).toList();
    } catch (e) {
      print('Erreur lors de la récupération des rapports: $e');
      return [];
    }
  }
} 