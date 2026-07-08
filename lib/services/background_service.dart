import 'dart:async';
import '../model/coin.dart';
import 'alert_service.dart';

class BackgroundAlertService {
  static Timer? _timer;
  static const int _checkInterval = 60; // Check every 60 seconds

  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: _checkInterval),
      (_) => checkAlerts(),
    );
    print('Background alert service started');
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    print('Background alert service stopped');
  }

  static Future<void> checkAlerts() async {
    try {
      final alertService = AlertService();
      await alertService.loadAlerts();

      final alerts = alertService.getAlerts();
      if (alerts.isEmpty) return;

      // Fetch current prices
      final coins = await fetchCoins('usd');

      // Check alerts
      await alertService.checkAlerts(coins);
    } catch (e) {
      print('Background alert check error: $e');
    }
  }
}
