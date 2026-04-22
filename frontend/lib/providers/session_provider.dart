import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/api_service.dart';

class SessionProvider with ChangeNotifier {
  String? _tableId;
  String? _userDeviceId;
  int? _sessionId;
  bool _isLoading = false;

  String? get tableId => _tableId;
  bool get isLoading => _isLoading;

  Future<void> initializeDevice() async {
    final prefs = await SharedPreferences.getInstance();
    _userDeviceId = prefs.getString('user_device_id');
    
    if (_userDeviceId == null) {
      // Generate a unique ID for this device if it doesn't exist
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
