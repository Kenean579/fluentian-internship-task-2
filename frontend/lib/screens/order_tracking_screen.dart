import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  final String orderNumber;
  final String initialStatus;
  final double totalAmount;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.initialStatus,
    required this.totalAmount,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late String _currentStatus;
  PusherChannelsFlutter? _pusher;
  String _estimatedWait(String status) {
    switch (status) {
      case 'Received': return 'Est. wait: ~20 min';
      case 'Cooking':  return 'Est. wait: ~10 min';
      case 'Ready':    return 'Ready for pickup!';
      case 'Delivered': return 'Delivered ✓';
      default: return '';
    }
  }

  final List<String> _statusPipeline = [
    'Received',
    'Cooking',
    'Ready',
    'Delivered',
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Received':  return Colors.blue;
      case 'Cooking':   return Colors.orange;
      case 'Ready':     return Colors.green;
      case 'Delivered': return Colors.grey;
      default:          return Colors.black;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Received':  return Icons.receipt_long;
      case 'Cooking':   return Icons.outdoor_grill;
      case 'Ready':     return Icons.check_circle;
      case 'Delivered': return Icons.delivery_dining;
      default:          return Icons.help_outline;
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'Received':  return 'Your order has been received by the kitchen!';
      case 'Cooking':   return 'The chef is cooking your order now 🍳';
      case 'Ready':     return 'Your order is ready! A waiter will bring it shortly 🎉';
      case 'Delivered': return 'Enjoy your meal! Bon appétit 😊';
      default:          return '';
    }
  }
  

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    _connectToPusher();
  }

  Future<void> _connectToPusher() async {
    try {
      _pusher = PusherChannelsFlutter.getInstance();

      await _pusher!.init(
        // Replace with your actual Pusher key and cluster
        apiKey: 'your_pusher_app_key_here',
        cluster: 'your_pusher_cluster_here',
      );

      await _pusher!.subscribe(
        channelName: 'orders.${widget.orderId}',
        onEvent: (event) {
          if (event.eventName == 'status.updated') {
            final data = jsonDecode(event.data);
            if (mounted) {
              setState(() {
                _currentStatus = data['status'];
              });
            }
          }
        },
      );

      await _pusher!.connect();
    } catch (e) {
      debugPrint('Pusher connection error: $e');
    }
  }

  @override
  void dispose() {
    _pusher?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statusPipeline.indexOf(_currentStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Order Tracking',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  const Text('Order Number',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    widget.orderNumber,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                _statusIcon(_currentStatus),
                key: ValueKey(_currentStatus),
                size: 80,
                color: _statusColor(_currentStatus),
              ),
            ),

            const SizedBox(height: 12),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _currentStatus,
                key: ValueKey(_currentStatus),
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _statusColor(_currentStatus)),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _statusMessage(_currentStatus),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            
            const SizedBox(height: 8),
            Text(
              _estimatedWait(_currentStatus),
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: List.generate(_statusPipeline.length, (index) {
                final isCompleted = index <= currentIndex;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted
                                  ? _statusColor(_statusPipeline[index])
                                  : Colors.grey[300],
                            ),
                            child: Icon(
                              isCompleted
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusPipeline[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isCompleted
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCompleted
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (index < _statusPipeline.length - 1)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 3,
                            color: index < currentIndex
                                ? Colors.orange
                                : Colors.grey[300],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Live updates active',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
