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
      _connectivity.onConnectivityChanged.map((results) {
        // connectivity_plus 5.0.0+ returns a List<ConnectivityResult>
        final connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
        _isConnected = connected;
        return connected;
      });

  Future<bool> checkConnection() async {
    try {
      // Simple connectivity check
      final results = await _connectivity.checkConnectivity();
      // ignore: unnecessary_type_check
      final hasConnectivity = results is List 
          ? (results.isNotEmpty && !results.contains(ConnectivityResult.none))
          // ignore: unnecessary_null_comparison
          : (results != null && results != ConnectivityResult.none);

      if (!hasConnectivity) {
        _isConnected = false;
        return false;
      }

      // Try a simple DNS lookup to verify actual internet access
      try {
        final addresses = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));

        final hasInternet = addresses.isNotEmpty && addresses[0].rawAddress.isNotEmpty;

        _isConnected = hasInternet;
        _hasCheckedOnce = true;
        return hasInternet;
      } catch (_) {
        // If DNS fails, but we were previously connected, assume still connected for a better UX
        // or if it's the first check, we might want to return false if it's a hard fail.
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
      if (results is List) {
        return results.isNotEmpty && !results.contains(ConnectivityResult.none);
      }
      return results != ConnectivityResult.none;
    } catch (_) {
      return _isConnected;
    }
  }

  Stream<bool> get connectionStatusStream {
    return _connectivity.onConnectivityChanged.map((results) {
      final connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      _isConnected = connected;
      return connected;
    });
  }
}
