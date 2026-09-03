import 'package:flutter/material.dart';
import '../services/refresh_service.dart';

class RefreshSettingsScreen extends StatefulWidget {
  const RefreshSettingsScreen({super.key});

  @override
  State<RefreshSettingsScreen> createState() => _RefreshSettingsScreenState();
}

class _RefreshSettingsScreenState extends State<RefreshSettingsScreen> {
  final RefreshService _refreshService = RefreshService();
  bool _isAutoRefreshEnabled = false;
  int _selectedInterval = 30;

  final List<int> _intervalOptions = [10, 15, 30, 60, 120, 300];

  @override
  void initState() {
    super.initState();
    _isAutoRefreshEnabled = _refreshService.isRunning;
    _selectedInterval = _refreshService.intervalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text('Refresh Settings'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Auto-refresh toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isAutoRefreshEnabled
                            ? Icons.refresh
                            : Icons.not_interested,
                        color: _isAutoRefreshEnabled
                            ? Colors.green
                            : Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Auto-Refresh',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isAutoRefreshEnabled
                                ? 'Prices update automatically'
                                : 'Manual refresh only',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAutoRefreshEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isAutoRefreshEnabled = value;
                          if (value) {
                            _refreshService.startAutoRefresh(
                              intervalSeconds: _selectedInterval,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Auto-refresh enabled (${_selectedInterval}s)',
                                ),
                                backgroundColor: const Color(0xFF22C55E),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            _refreshService.stopAutoRefresh();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Auto-refresh disabled'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      },
                      activeThumbColor: const Color(0xFF22C55E),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interval selection
          if (_isAutoRefreshEnabled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Refresh Interval',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'How often to refresh prices',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _intervalOptions.map((interval) {
                      final isSelected = _selectedInterval == interval;
                      final label = interval >= 60
                          ? '${interval ~/ 60}m'
                          : '${interval}s';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedInterval = interval;
                            if (_isAutoRefreshEnabled) {
                              _refreshService.setInterval(interval);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Interval set to $label'),
                                  backgroundColor: const Color(0xFF22C55E),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF22C55E).withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF22C55E)
                                  : Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF22C55E)
                                  : Colors.white54,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Manual refresh info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1220),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white38, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manual Refresh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Pull down on the coin list to refresh manually',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_downward,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Trigger manual refresh
                    _refreshService.notifyListeners();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Refreshing prices...'),
                        backgroundColor: Color(0xFF22C55E),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Refresh Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
