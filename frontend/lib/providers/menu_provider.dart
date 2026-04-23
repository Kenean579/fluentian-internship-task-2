import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MenuItem {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final int prepTime;
  final bool available;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.prepTime,
    required this.available,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      prepTime: json['prep_time'],
      available: json['available'] == true || json['available'] == 1,
    );
  }
}

class MenuCategory {
  final int id;
  final String name;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.name,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'],
      name: json['name'],
      items: (json['menu_items'] as List)
          .map((item) => MenuItem.fromJson(item))
          .toList(),
    );
  }
}

class MenuProvider with ChangeNotifier {
  List<MenuCategory> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MenuCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMenu() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/menu');
      _categories = (response['data'] as List)
          .map((cat) => MenuCategory.fromJson(cat))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load menu. Please check your connection.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
