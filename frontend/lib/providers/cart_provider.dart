import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartItem {
  final int id;
  final String menuItemName;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.id,
    required this.menuItemName,
    required this.unitPrice,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      menuItemName: json['menu_item']['name'],
      unitPrice: double.parse(json['unit_price'].toString()),
      quantity: json['quantity'],
    );
  }

  double get total => unitPrice * quantity;
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCart(int sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/sessions/$sessionId/cart');
      final cartData = response['data'];
      _items = (cartData['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load cart. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addItem(int sessionId, int menuItemId, int quantity) async {
    try {
      final response = await ApiService.post(
        '/sessions/$sessionId/cart',
        {'menu_item_id': menuItemId, 'quantity': quantity},
      );
      final cartData = response['data'];
      _items = (cartData['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeItem(int sessionId, int cartItemId) async {
    try {
      final response = await ApiService.delete(
        '/sessions/$sessionId/cart/items/$cartItemId',
      );
      final cartData = response['data'];
      _items = (cartData['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}
