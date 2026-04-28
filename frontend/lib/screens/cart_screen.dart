import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

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
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => OrderTrackingScreen(
        orderId: order['id'],
        orderNumber: order['order_number'],
        initialStatus: order['status'],
        totalAmount: double.parse(order['total_amount'].toString()),
      ),
    ),
  );
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
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.menuItemName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text('ETB ${item.unitPrice.toStringAsFixed(2)} each',
                                            style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 20),
                                              onPressed: item.quantity > 1 
                                                ? () => cart.updateItemQuantity(session.sessionId!, item.id, item.quantity - 1)
                                                : () => cart.removeItem(session.sessionId!, item.id),
                                            ),
                                            Text('${item.quantity}', 
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 20),
                                              onPressed: () => cart.updateItemQuantity(session.sessionId!, item.id, item.quantity + 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ETB ${item.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                      ),
                                    ],
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
                                'ETB ${cart.totalAmount.toStringAsFixed(2)}',
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
