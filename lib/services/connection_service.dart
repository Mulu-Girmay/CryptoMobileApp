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
      // If the list contains anything other than 'none', we have a hardware connection
      return results.any((result) => result != ConnectivityResult.none);
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
      final hasHardwareConnection = _isResultConnected(results);

      // If the hardware itself says disconnected, trust it.
      if (!hasHardwareConnection) {
        _isConnected = false;
        return false;
      }

      // If we have a hardware connection, try a very quick verification.
      // We check multiple hosts to avoid false negatives.
      try {
        final hasInternet = await Future.any([
          _verifyHost('google.com'),
          _verifyHost('cloudflare.com'),
          _verifyHost('apple.com'),
        ]).timeout(const Duration(seconds: 3));

        _isConnected = hasInternet;
        _hasCheckedOnce = true;
        return hasInternet;
      } catch (_) {
        // FALLBACK: If DNS fails but hardware says we are connected,
        // we'll be optimistic and return TRUE to allow the actual API call to try.
        // This fixes issues where DNS lookups are blocked but the API isn't.
        if (!_hasCheckedOnce) {
          _hasCheckedOnce = true;
          _isConnected = true;
          return true;
        }
        return _isConnected;
      }
    } catch (e) {
      // On error, default to whatever our last known state was
      return _isConnected;
    }
  }

  Future<bool> _verifyHost(String host) async {
    try {
      final addresses = await InternetAddress.lookup(host);
      return addresses.isNotEmpty && addresses[0].rawAddress.isNotEmpty;
    } catch (_) {
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
