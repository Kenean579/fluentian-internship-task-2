import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load the menu when the screen opens
    Future.microtask(() =>
        Provider.of<MenuProvider>(context, listen: false).fetchMenu());
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final session = Provider.of<SessionProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Table ${session.tableId ?? ''} - Menu',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(menuProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: () => menuProvider.fetchMenu(),
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Category filter tabs
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: menuProvider.categories.length,
                        itemBuilder: (ctx, index) {
                          final isSelected =
                              _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategoryIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Center(
                                child: Text(
                                  menuProvider
                                      .categories[index].name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Menu items list for the selected category
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: menuProvider
                            .categories[_selectedCategoryIndex]
                            .items
                            .length,
                        itemBuilder: (ctx, index) {
                          final item = menuProvider
                              .categories[_selectedCategoryIndex]
                              .items[index];
                          return Card(
                            margin:
                                const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(item.description,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${item.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  color: Colors.orange,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(Icons.timer_outlined,
                                                size: 14,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${item.prepTime} min',
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    onPressed: session.sessionId == null
                                        ? null
                                        : () async {
                                            final success =
                                                await cart.addItem(
                                              session.sessionId!,
                                              item.id,
                                              1,
                                            );
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    '${item.name} added to cart!'),
                                                backgroundColor:
                                                    Colors.green,
                                                duration: const Duration(
                                                    seconds: 1),
                                              ));
                                            }
                                          },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
