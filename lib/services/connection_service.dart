import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream =>
      _connectivity.onConnectivityChanged.map((result) {
        final connected = result != ConnectivityResult.none;
        _isConnected = connected;
        return connected;
      });

  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = result != ConnectivityResult.none;

      // Double check with actual internet access
      if (_isConnected) {
        _isConnected = await _hasInternetAccess();
      }

      return _isConnected;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
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
