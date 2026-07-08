import 'package:flutter/material.dart';
import '../model/alert.dart';
import '../model/coin.dart';
import '../services/alert_service.dart';
import '../services/notification_service.dart';
import '../utils/formatter.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final AlertService _alertService = AlertService();
  List<PriceAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    await _alertService.loadAlerts();
    setState(() {
      _alerts = _alertService.getAlerts();
      _isLoading = false;
    });
  }

  Future<void> _addAlert() async {
    // First, show coin selection
    final selectedCoin = await _showCoinSelectionDialog();
    if (selectedCoin == null) return;

    // Then, show price and condition selection
    final alertData = await _showAlertSetupDialog(selectedCoin);
    if (alertData == null) return;

    final newAlert = PriceAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coinId: selectedCoin.id,
      coinName: selectedCoin.name,
      coinSymbol: selectedCoin.symbol,
      coinImage: selectedCoin.image,
      targetPrice: alertData['price'],
      condition: alertData['condition'],
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _alertService.addAlert(newAlert);
    setState(() {
      _alerts = _alertService.getAlerts();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert added successfully!'),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  Future<Coin?> _showCoinSelectionDialog() async {
    final coins = await fetchCoins('usd');

    return showDialog<Coin>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: const Text('Select Coin', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: coins.length,
            itemBuilder: (context, index) {
              final coin = coins[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coin.image,
                    width: 30,
                    height: 30,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image, size: 30),
                  ),
                ),
                title: Text(
                  coin.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  Formatter.formatPrice(coin.price),
                  style: const TextStyle(color: Colors.white54),
                ),
                onTap: () => Navigator.pop(context, coin),
                tileColor: Colors.transparent,
                hoverColor: Colors.white.withOpacity(0.05),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showAlertSetupDialog(Coin coin) async {
    final priceController = TextEditingController(
      text: coin.price.toStringAsFixed(2),
    );
    AlertCondition? selectedCondition = AlertCondition.above;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B1220),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                coin.image,
                width: 30,
                height: 30,
                errorBuilder: (c, e, s) => const Icon(Icons.image, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Set Alert: ${coin.name}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Condition dropdown
                DropdownButtonFormField<AlertCondition>(
                  value: selectedCondition,
                  dropdownColor: const Color(0xFF0B1220),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Condition',
                    labelStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF22C55E)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AlertCondition.above,
                      child: Text(
                        'Price goes above',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DropdownMenuItem(
                      value: AlertCondition.below,
                      child: Text(
                        'Price goes below',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCondition = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Price input
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Target Price',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF22C55E)),
                    ),
                    hintText: '\$${coin.price.toStringAsFixed(2)}',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixText: '\$',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid price'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, {
                'price': price,
                'condition': selectedCondition ?? AlertCondition.above,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: const Text(
              'Set Alert',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Price Alerts'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadAlerts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)),
            )
          : Column(
              children: [
                // Info banner
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Color(0xFF22C55E),
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price Alerts',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Get notified when coins reach your target price',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_alerts.length}',
                          style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Add Alert Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: _addAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_alert, color: Colors.black),
                    label: const Text(
                      'Create New Alert',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Alerts List
                Expanded(
                  child: _alerts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off,
                                size: 80,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No alerts set',
                                style: TextStyle(color: Colors.white54),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create your first price alert',
                                style: TextStyle(color: Colors.white38),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _alerts.length,
                          itemBuilder: (context, index) {
                            final alert = _alerts[index];
                            return _buildAlertCard(alert);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildAlertCard(PriceAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isActive
              ? Colors.white.withOpacity(0.05)
              : Colors.red.withOpacity(0.3),
        ),
        gradient: alert.isActive
            ? null
            : LinearGradient(
                colors: [Colors.red.withOpacity(0.05), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Row(
        children: [
          // Coin Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              alert.coinImage,
              width: 40,
              height: 40,
              errorBuilder: (c, e, s) => const Icon(Icons.image, size: 40),
            ),
          ),
          const SizedBox(width: 12),

          // Alert Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      alert.coinName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: alert.conditionColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            alert.conditionIcon,
                            size: 12,
                            color: alert.conditionColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alert.conditionDisplayText,
                            style: TextStyle(
                              color: alert.conditionColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${alert.targetPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (alert.lastTriggeredAt != null)
                  Text(
                    'Last triggered: ${_formatTime(alert.lastTriggeredAt!)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
              ],
            ),
          ),

          // Status and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: alert.isActive
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: alert.isActive ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      await _alertService.toggleAlert(alert.id);
                      setState(() {
                        _alerts = _alertService.getAlerts();
                      });
                    },
                    icon: Icon(
                      alert.isActive ? Icons.pause : Icons.play_arrow,
                      size: 18,
                      color: alert.isActive ? Colors.orange : Colors.green,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF0B1220),
                          title: const Text(
                            'Delete Alert',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            'Delete alert for ${alert.coinName}?',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _alertService.removeAlert(alert.id);
                        setState(() {
                          _alerts = _alertService.getAlerts();
                        });
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
