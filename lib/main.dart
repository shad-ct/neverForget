import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/reminder_provider.dart';
import 'services/data_seeder.dart';
import 'services/isar_service.dart';
import 'services/notification_service.dart';
import 'services/permission_helper.dart';
import 'theme/app_theme.dart';

/// Application entry point.
///
/// Initializes Isar database, notification service, and timezone data
/// before launching the UI. Wraps the app in [MultiProvider] for state
/// management.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive status bar — let the mesh gradient bleed behind it
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize core services
  final isarService = await IsarService.init();
  await NotificationService.init();

  // Seed database from data.json on first launch
  await DataSeeder.seedFromJson();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(isarService),
        ),
      ],
      child: const NeverForgetApp(),
    ),
  );
}

/// Root widget — Dark-mode only MaterialApp.
class NeverForgetApp extends StatefulWidget {
  const NeverForgetApp({super.key});

  @override
  State<NeverForgetApp> createState() => _NeverForgetAppState();
}

class _NeverForgetAppState extends State<NeverForgetApp> {
  @override
  void initState() {
    super.initState();
    // Request permissions after first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionHelper.requestAllPermissions(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeverForget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
