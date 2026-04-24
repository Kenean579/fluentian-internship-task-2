import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecommendedItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final int prepTime;

  RecommendedItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.prepTime,
  });

  factory RecommendedItem.fromJson(Map<String, dynamic> json) {
    return RecommendedItem(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      prepTime: json['prep_time'],
    );
  }
}

class RecommendationProvider with ChangeNotifier {
  List<RecommendedItem> _recommendations = [];
  String _type = 'featured'; // 'personalized', 'popular', or 'featured'
  bool _isLoading = false;

  List<RecommendedItem> get recommendations => _recommendations;
  String get type => _type;
  bool get isLoading => _isLoading;

  String get sectionTitle {
    switch (_type) {
      case 'personalized': return '🎯 Recommended For You';
      case 'popular':      return '🔥 Most Popular Right Now';
      default:             return '⭐ Featured Items';
    }
  }

  Future<void> fetchRecommendations(int sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await ApiService.get('/sessions/$sessionId/recommendations');
      _type = response['type'] ?? 'featured';
      _recommendations = (response['data'] as List)
          .map((item) => RecommendedItem.fromJson(item))
          .toList();
    } catch (e) {
      _recommendations = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
