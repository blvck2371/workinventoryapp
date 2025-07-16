import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/main_controller.dart';
import 'models/work_session.dart';
import 'services/hive_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_session_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/session_details_screen.dart';
import 'screens/edit_session_screen.dart';
import 'screens/history_screen.dart';
import 'screens/test_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les données de localisation françaises
  await initializeDateFormatting('fr_FR', null);
  
  // Initialiser Hive
  await HiveService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Work Inventory',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      initialBinding: BindingsBuilder(() {
        Get.put<MainController>(MainController());
      }),
      getPages: [
        GetPage(
          name: '/',
          page: () => const AppWrapper(),
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => const DashboardScreen(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardScreen(),
        ),
        GetPage(
          name: '/add-session',
          page: () => const AddSessionScreen(),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
        ),
        GetPage(
          name: '/session-details',
          page: () {
            final session = Get.arguments as WorkSession;
            return SessionDetailsScreen(session: session);
          },
        ),
        GetPage(
          name: '/edit-session',
          page: () {
            final session = Get.arguments as WorkSession;
            return EditSessionScreen(session: session);
          },
        ),
        GetPage(
          name: '/history',
          page: () => const HistoryScreen(),
        ),
        GetPage(
          name: '/test',
          page: () => const TestScreen(),
        ),
      ],
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        // Afficher l'écran de chargement seulement si on charge ET qu'on n'a pas encore de paramètres
        if (controller.isLoading.value && controller.userSettings.value == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16),
            Text(
                    'Chargement...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
            ),
          ],
        ),
      ),
          );
        }

        // Si c'est la première utilisation ou qu'il n'y a pas de paramètres sauvegardés
        if (controller.isFirstTime) {
          return const OnboardingScreen();
        }

        // Sinon, afficher le dashboard
        return const DashboardScreen();
      },
    );
  }
}
