import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';

class SessionProvider with ChangeNotifier {
  String? _tableId;
  String? _userDeviceId;
  int? _sessionId;
  bool _isLoading = false;
  bool _sessionRestored = false;
  Map<String, dynamic>? _lastActiveOrder;

  String? get tableId => _tableId;
  int? get sessionId => _sessionId;
  bool get isLoading => _isLoading;
  bool get sessionRestored => _sessionRestored;
  bool get hasActiveSession => _sessionId != null;
  Map<String, dynamic>? get lastActiveOrder => _lastActiveOrder;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _userDeviceId = prefs.getString('user_device_id');
    final savedTableId = prefs.getString('last_table_id');

    if (_userDeviceId != null && savedTableId != null) {
      try {
        final response = await ApiService.post('/sessions/start', {
          'table_id': savedTableId,
          'user_device_id': _userDeviceId,
        });
        _tableId = savedTableId;
        _sessionId = response['session']['id'];

        // Check for active orders to resume tracking
        final ordersResponse = await ApiService.get('/sessions/$_sessionId/orders');
        final List orders = ordersResponse['data'];
        if (orders.isNotEmpty) {
          final mostRecent = orders.first;
          if (mostRecent['status'] != 'Delivered') {
            _lastActiveOrder = mostRecent;
          }
        }
      } catch (_) {
      }
    }

    _sessionRestored = true;
    notifyListeners();
  }

  Future<void> initializeDevice() async {
    final prefs = await SharedPreferences.getInstance();
    _userDeviceId = prefs.getString('user_device_id');
    if (_userDeviceId == null) {
      _userDeviceId = const Uuid().v4();
      await prefs.setString('user_device_id', _userDeviceId!);
    }
  }

  Future<bool> startSession(String scannedTableId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_userDeviceId == null) await initializeDevice();

      final response = await ApiService.post('/sessions/start', {
        'table_id': scannedTableId,
        'user_device_id': _userDeviceId,
      });

      _tableId = scannedTableId;
      _sessionId = response['session']['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_table_id', scannedTableId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
