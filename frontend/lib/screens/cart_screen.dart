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
  bool _isProcessingPayment = false;
  String _selectedPaymentMethod = 'Cash';

  Future<void> _placeOrder(BuildContext context, int sessionId) async {
    setState(() => _isPlacingOrder = true);

    try {
      final response = await ApiService.post(
        '/sessions/$sessionId/orders',
        {'payment_method': _selectedPaymentMethod},
      );

      final order = response['data'];
      
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
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  void _showPaymentSelector(BuildContext context, int sessionId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Payment Method', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildPaymentOption('Cash', Icons.money, 'Pay at the counter', setModalState),
              _buildPaymentOption('Telebirr', Icons.phone_android, 'Instant mobile payment', setModalState),
              _buildPaymentOption('CBE Birr', Icons.account_balance_wallet, 'Bank transfer', setModalState),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    setState(() => _isProcessingPayment = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (mounted) {
                      setState(() => _isProcessingPayment = false);
                      _placeOrder(context, sessionId);
                    }
                  },
                  child: const Text('Confirm & Pay', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String subtitle, StateSetter setModalState) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Radio<String>(
        value: title,
        groupValue: _selectedPaymentMethod,
        activeColor: Colors.orange,
        onChanged: (val) {
          setState(() => _selectedPaymentMethod = val!);
          setModalState(() {});
        },
      ),
      onTap: () {
        setState(() => _selectedPaymentMethod = title);
        setModalState(() {});
      },
    );
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
      body: Stack(
        children: [
          cart.isLoading
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, -2))
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
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _isPlacingOrder || _isProcessingPayment || session.sessionId == null
                                      ? null
                                      : () => _showPaymentSelector(context, session.sessionId!),
                                  child: _isPlacingOrder || _isProcessingPayment
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text('Proceed to Checkout',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          if (_isProcessingPayment)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  margin: EdgeInsets.all(32),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.orange),
                        const SizedBox(height: 20),
                        const Text('Simulating Secure Payment...',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Connecting to Telebirr / CBE gateway',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
