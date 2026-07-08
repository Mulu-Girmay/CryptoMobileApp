import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _hasCheckedOnce = false;

  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream =>
      _connectivity.onConnectivityChanged.map((result) {
        final connected = result != ConnectivityResult.none;
        _isConnected = connected;
        return connected;
      });

  Future<bool> checkConnection() async {
    try {
      // Simple connectivity check
      final result = await _connectivity.checkConnectivity();
      final hasConnectivity = result != ConnectivityResult.none;

      if (!hasConnectivity) {
        _isConnected = false;
        return false;
      }

      // Try a simple DNS lookup
      try {
        final addresses = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 3));

        final hasInternet =
            addresses.isNotEmpty && addresses[0].rawAddress.isNotEmpty;

        _isConnected = hasInternet;
        _hasCheckedOnce = true;
        return hasInternet;
      } catch (_) {
        // If DNS fails, but we were previously connected, assume still connected
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

  // Ultra-simplified check for when you just need to know if there's connectivity
  Future<bool> quickCheck() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      return _isConnected;
    }
  }

  Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged.map((result) {
      final connected = result != ConnectivityResult.none;
      _isConnected = connected;
      return connected;
    });
  }
}
