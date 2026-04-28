import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserBehaviorProvider with ChangeNotifier {
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;

  List<dynamic> get mostOrdered => _profile?['most_ordered'] ?? [];
  List<dynamic> get recentlyOrdered => _profile?['recently_ordered'] ?? [];
  List<dynamic> get preferenceProfile => _profile?['preference_profile'] ?? [];

  Future<void> fetchProfile(int sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/sessions/$sessionId/behavior');
      _profile = response;
    } catch (e) {
      debugPrint('Error fetching behavior profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
