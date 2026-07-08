import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _hasCheckedOnce = false;

  bool get isConnected => _isConnected;

  // Helper to safely evaluate connectivity regardless of plugin version
  bool _isResultConnected(dynamic results) {
    if (results is List) {
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    }
    return results != ConnectivityResult.none;
  }

  Stream<bool> get connectionStream =>
      _connectivity.onConnectivityChanged.map((results) {
        final connected = _isResultConnected(results);
        _isConnected = connected;
        return connected;
      });

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnectivity = _isResultConnected(results);

      if (!hasConnectivity) {
        _isConnected = false;
        return false;
      }

      try {
        final addresses = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));

        final hasInternet =
            addresses.isNotEmpty && addresses[0].rawAddress.isNotEmpty;

        _isConnected = hasInternet;
        _hasCheckedOnce = true;
        return hasInternet;
      } catch (_) {
        if (_hasCheckedOnce && _isConnected) {
          return true;
        }
        _isConnected = false;
        return false;
      }
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> quickCheck() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isResultConnected(results);
    } catch (_) {
      return _isConnected;
    }
  }

  Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged.map((results) {
      final connected = _isResultConnected(results);
      _isConnected = connected;
      return connected;
    });
  }
}
