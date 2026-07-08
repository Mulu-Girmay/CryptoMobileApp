import '../model/alert.dart';
import '../model/coin.dart';
import 'alert_storage.dart';
import 'notification_service.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  List<PriceAlert> _alerts = [];
  bool _isChecking = false;

  Future<void> loadAlerts() async {
    _alerts = await AlertStorage.loadAlerts();
  }

  Future<void> saveAlerts() async {
    await AlertStorage.saveAlerts(_alerts);
  }

  List<PriceAlert> getAlerts() {
    return _alerts;
  }

  Future<void> addAlert(PriceAlert alert) async {
    _alerts.add(alert);
    await saveAlerts();
  }

  Future<void> removeAlert(String id) async {
    _alerts.removeWhere((alert) => alert.id == id);
    await saveAlerts();
  }

  Future<void> toggleAlert(String id) async {
    final index = _alerts.indexWhere((alert) => alert.id == id);
    if (index != -1) {
      _alerts[index] = PriceAlert(
        id: _alerts[index].id,
        coinId: _alerts[index].coinId,
        coinName: _alerts[index].coinName,
        coinSymbol: _alerts[index].coinSymbol,
        coinImage: _alerts[index].coinImage,
        targetPrice: _alerts[index].targetPrice,
        condition: _alerts[index].condition,
        isActive: !_alerts[index].isActive,
        createdAt: _alerts[index].createdAt,
        lastTriggeredAt: _alerts[index].lastTriggeredAt,
      );
      await saveAlerts();
    }
  }

  Future<void> checkAlerts(List<Coin> coins) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final activeAlerts = _alerts.where((alert) => alert.isActive).toList();

      for (final alert in activeAlerts) {
        final coin = coins.firstWhere(
          (c) => c.id == alert.coinId,
          orElse: () => Coin(
            id: '',
            name: alert.coinName,
            symbol: alert.coinSymbol,
            image: alert.coinImage,
            price: 0,
            change: 0,
            marketCap: 0,
            totalVolume: 0,
            high24h: 0,
            low24h: 0,
          ),
        );

        if (coin.id.isNotEmpty && alert.shouldTrigger(coin.price)) {
          // Check if already triggered recently (prevent spam)
          if (alert.lastTriggeredAt != null) {
            final timeSinceLastTrigger = DateTime.now().difference(
              alert.lastTriggeredAt!,
            );
            if (timeSinceLastTrigger.inMinutes < 30) continue;
          }

          // Send notification
          await NotificationService.showPriceAlert(
            title: '💰 Price Alert: ${alert.coinName}',
            body:
                '${alert.coinSymbol.toUpperCase()} is ${alert.conditionText} \$${alert.targetPrice.toStringAsFixed(2)} (Current: \$${coin.price.toStringAsFixed(2)})',
            payload: alert.coinId,
          );

          // Update last triggered time
          final index = _alerts.indexWhere((a) => a.id == alert.id);
          if (index != -1) {
            _alerts[index] = PriceAlert(
              id: _alerts[index].id,
              coinId: _alerts[index].coinId,
              coinName: _alerts[index].coinName,
              coinSymbol: _alerts[index].coinSymbol,
              coinImage: _alerts[index].coinImage,
              targetPrice: _alerts[index].targetPrice,
              condition: _alerts[index].condition,
              isActive: _alerts[index].isActive,
              createdAt: _alerts[index].createdAt,
              lastTriggeredAt: DateTime.now(),
            );
            await saveAlerts();
          }
        }
      }
    } catch (e) {
      print('Error checking alerts: $e');
    } finally {
      _isChecking = false;
    }
  }

  // Manual check with current coins
  Future<void> checkAlertsManually() async {
    try {
      final coins = await fetchCoins('usd');
      await checkAlerts(coins);
    } catch (e) {
      print('Error in manual alert check: $e');
    }
  }
}
