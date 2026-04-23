import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPlacingOrder = false;

  Future<void> _placeOrder(BuildContext context, int sessionId) async {
    setState(() => _isPlacingOrder = true);

    try {
      final response = await ApiService.post(
        '/sessions/$sessionId/orders',
        {},
      );

      final order = response['data'];
      // Clear the local cart state
      if (context.mounted) {
        Provider.of<CartProvider>(context, listen: false).clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed! Your number: ${order['order_number']}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isPlacingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final session = Provider.of<SessionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.items.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty.\nGo back and add some items!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, index) {
                          final item = cart.items[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(item.menuItemName,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Qty: ${item.quantity}  ×  \$${item.unitPrice.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\$${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () => cart.removeItem(
                                        session.sessionId!, item.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, -2))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '\$${cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isPlacingOrder
                                  ? null
                                  : () =>
                                      _placeOrder(context, session.sessionId!),
                              child: _isPlacingOrder
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Place Order',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
