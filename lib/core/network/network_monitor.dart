import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class NetworkMonitor {
  final _controller = StreamController<bool>.broadcast();
  Timer? _pollTimer;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  NetworkMonitor() {
    _init();
  }

  void _init() {
    // Check immediately
    _checkInternet();
    // Start continuous polling
    _startPolling();
  }

  Future<void> _checkInternet() async {
    bool hasConnection = await _probeInternet();
    // Only emit if status changed
    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      debugPrint(
        'Network Status Changed: ${hasConnection ? "Online" : "Offline"}',
      );
      _controller.add(hasConnection);
    }
  }

  Future<bool> _probeInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkInternet();
    });
  }

  void dispose() {
    _pollTimer?.cancel();
    _controller.close();
  }
}
