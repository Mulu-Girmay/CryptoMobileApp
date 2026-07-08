import 'package:crypto/screens/home.dart';
import 'package:crypto/services/background_service.dart';
import 'package:crypto/services/currency_service.dart';
import 'package:crypto/services/notification_service.dart';
import 'package:crypto/services/refresh_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await NotificationService.init();
  await CurrencyService().initialize();

  // Start auto-refresh (default: 30 seconds)
  RefreshService().startAutoRefresh(intervalSeconds: 30);

  BackgroundAlertService.start();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
