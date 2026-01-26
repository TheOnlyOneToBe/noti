import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'presentation/router.dart';
import 'application/providers.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Locale
  await initializeDateFormatting('fr_FR', null);

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notifications after build to ensure ref is safe, 
    // though initState is usually fine for reading if not watching.
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _initNotifications();
    });
  }

  Future<void> _initNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.initialize();
    
    notificationService.onNotificationClick.listen((payload) {
      if (payload != null) {
        try {
          final data = jsonDecode(payload);
          if (data['type'] == 'epreuve_details' && data['epreuveId'] != null) {
             router.go('/epreuves/detail/${data['epreuveId']}');
          }
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    });

    // Check if app launched from notification
    notificationService.checkPendingNotification();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Noti Planif',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
