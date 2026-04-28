import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  Color _statusColor(String status) {
    switch (status) {
      case 'Received':  return Colors.blue;
      case 'Cooking':   return Colors.orange;
      case 'Ready':     return Colors.green;
      case 'Delivered': return Colors.grey;
      default:          return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    if (session.sessionId == null) return;

    try {
      final response =
          await ApiService.get('/sessions/${session.sessionId}/orders');
      setState(() {
        _orders = response['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Order History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders yet.\nStart ordering from the menu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders.length,
                  itemBuilder: (ctx, index) {
                    final order = _orders[index];
                    final status = order['status'] as String;
                    final items = order['items'] as List<dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order['order_number'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(status),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(status,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              items
                                  .map((i) =>
                                      '${i['menu_item']['name']} ×${i['quantity']}')
                                  .join(', '),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ETB ${double.parse(order['total_amount'].toString()).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        trailing: status != 'Delivered'
                            ? const Icon(Icons.chevron_right)
                            : null,
                        onTap: status != 'Delivered'
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderTrackingScreen(
                                      orderId: order['id'],
                                      orderNumber: order['order_number'],
                                      initialStatus: status,
                                      totalAmount: double.parse(
                                          order['total_amount'].toString()),
                                    ),
                                  ),
                                )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
