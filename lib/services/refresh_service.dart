import 'dart:async';

import 'package:flutter/foundation.dart';

class RefreshService {
  static final RefreshService _instance = RefreshService._internal();
  factory RefreshService() => _instance;
  RefreshService._internal();

  Timer? _timer;
  bool _isRunning = false;
  int _intervalSeconds = 30; // Default 30 seconds
  List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void startAutoRefresh({int intervalSeconds = 30}) {
    if (_isRunning) return;

    _intervalSeconds = intervalSeconds;
    _isRunning = true;

    _timer = Timer.periodic(Duration(seconds: _intervalSeconds), (timer) {
      notifyListeners();
    });

    print('Auto-refresh started (interval: ${_intervalSeconds}s)');
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    print('Auto-refresh stopped');
  }

  bool get isRunning => _isRunning;

  int get intervalSeconds => _intervalSeconds;

  void setInterval(int seconds) {
    if (_intervalSeconds == seconds) return;

    _intervalSeconds = seconds;
    if (_isRunning) {
      // Restart with new interval
      stopAutoRefresh();
      startAutoRefresh(intervalSeconds: seconds);
    }
  }
}
