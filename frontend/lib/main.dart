import 'package:flutter/material.dart';

void main() {
  runApp(const SmartRestaurantApp());
}

class SmartRestaurantApp extends StatelessWidget {
  const SmartRestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Restaurant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Smart Restaurant Ordering System'),
        ),
      ),
    );
  }
}
