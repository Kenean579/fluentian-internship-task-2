import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/session_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/user_behavior_provider.dart';
import 'providers/kitchen_provider.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/order_tracking_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => UserBehaviorProvider()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()),
      ],
      child: const SmartRestaurantApp(),
    ),
  );
}

class SmartRestaurantApp extends StatelessWidget {
  const SmartRestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Restaurant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AppStartup(),
    );
  }
}


class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    await session.restoreSession();
    
    if (session.hasActiveSession && mounted) {
      // Restore cart data from server
      Provider.of<CartProvider>(context, listen: false).fetchCart(session.sessionId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);

    if (!session.sessionRestored) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session.hasActiveSession) {
      if (session.lastActiveOrder != null) {
        final order = session.lastActiveOrder!;
        return OrderTrackingScreen(
          orderId: order['id'],
          orderNumber: order['order_number'],
          initialStatus: order['status'],
          totalAmount: double.parse(order['total_amount'].toString()),
        );
      }
      return const MenuScreen();
    }

    return const QRScannerScreen();
  }
}
