import 'package:crypto/screens/home.dart';
import 'package:crypto/services/currency_service.dart';
import 'package:crypto/services/refresh_service.dart';
import 'package:crypto/services/theme_notifier.dart';
import 'package:crypto/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize essential services only
  await CurrencyService().initialize();

  // Start auto-refresh for coin data
  RefreshService().startAutoRefresh(intervalSeconds: 30);

  // Initialize theme
  final themeNotifier = ThemeNotifier();
  await themeNotifier.setThemeMode(ThemeMode.dark); // Default to Dark Mode

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Crypto App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
