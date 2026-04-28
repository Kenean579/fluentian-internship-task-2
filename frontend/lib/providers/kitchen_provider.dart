import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KitchenProvider with ChangeNotifier {
  int _activeOrders = 0;
  String _loadStatus = 'Normal';
  int _extraMinutes = 0;
  bool _isLoading = false;

  int get activeOrders => _activeOrders;
  String get loadStatus => _loadStatus;
  int get extraMinutes => _extraMinutes;
  bool get isLoading => _isLoading;

  Future<void> fetchLoadStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/kitchen/load');
      _activeOrders = response['active_orders'] ?? 0;
      _loadStatus = response['load_status'] ?? 'Normal';
      _extraMinutes = response['extra_minutes'] ?? 0;
    } catch (e) {
      print('Error fetching kitchen load: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
