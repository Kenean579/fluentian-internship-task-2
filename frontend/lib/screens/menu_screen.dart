import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/session_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/user_behavior_provider.dart';
import '../providers/kitchen_provider.dart';
import 'cart_screen.dart';
import 'staff_panel_screen.dart';
import 'order_history_screen.dart';


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
    Future.microtask(() {
      if (!mounted) return;
      final session = Provider.of<SessionProvider>(context, listen: false);
      Provider.of<MenuProvider>(context, listen: false).fetchMenu();
      if (session.sessionId != null) {
        Provider.of<RecommendationProvider>(context, listen: false)
            .fetchRecommendations(session.sessionId!);
        Provider.of<UserBehaviorProvider>(context, listen: false)
            .fetchProfile(session.sessionId!);
        Provider.of<KitchenProvider>(context, listen: false)
            .fetchLoadStatus();
      }
    });
  }

  void _showItemDetails(MenuItem item, SessionProvider session, CartProvider cart, KitchenProvider kitchen) {
    int quantity = 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'ETB ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  const Spacer(),
                  Icon(Icons.timer_outlined, size: 16, color: kitchen.extraMinutes > 0 ? Colors.red : Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${item.prepTime + kitchen.extraMinutes} min',
                    style: TextStyle(color: kitchen.extraMinutes > 0 ? Colors.red : Colors.grey),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                item.description.isNotEmpty ? item.description : 'Authentic Ethiopian dish prepared with fresh local ingredients.',
                style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: quantity > 1 ? () => setModalState(() => quantity--) : null,
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setModalState(() => quantity++),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: session.sessionId == null || !item.available
                      ? null
                      : () async {
                          final success = await cart.addItem(session.sessionId!, item.id, quantity);
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('$quantity x ${item.name} added to cart!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 1),
                            ));
                          }
                        },
                  child: Text(
                    item.available ? 'Add to Cart' : 'Currently Unavailable',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final session = Provider.of<SessionProvider>(context);
    final recs = Provider.of<RecommendationProvider>(context);
    final behavior = Provider.of<UserBehaviorProvider>(context);
    final kitchen = Provider.of<KitchenProvider>(context);

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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text('${cart.itemCount}',
                        style: const TextStyle(fontSize: 11, color: Colors.white)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            tooltip: 'Order History',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'staff') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StaffPanelScreen()));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'staff',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Staff Mode'),
                  ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kitchen.extraMinutes > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.red[50],
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'High Demand: +${kitchen.extraMinutes} mins predicted prep time.',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (recs.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (recs.recommendations.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        child: Text(
                          recs.sectionTitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 145,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: recs.recommendations.length,
                          itemBuilder: (ctx, index) {
                            final item = recs.recommendations[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    colors: [Colors.white, Colors.orange.withAlpha(13)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(13),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4)),
                                  ],
                                ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text(item.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ETB ${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.orange,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: session.sessionId == null
                                              ? null
                                              : () async {
                                                  await cart.addItem(
                                                      session.sessionId!,
                                                      item.id,
                                                      1);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          '${item.name} added!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                      duration: const Duration(
                                                          seconds: 1),
                                                    ));
                                                  }
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 16),
                                          ),
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
                      const Divider(height: 1),
                    ],

    
                    if (behavior.recentlyOrdered.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.history, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Recently Ordered',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: behavior.recentlyOrdered.length,
                          itemBuilder: (ctx, index) {
                            final item = behavior.recentlyOrdered[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(item['name']),
                                avatar: const Icon(Icons.restaurant, size: 14),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Re-order ${item['name']} from the menu below!'))
                                  );
                                },
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.orange),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (behavior.mostOrdered.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.star_border, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Your Favorites',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: behavior.mostOrdered.length,
                          itemBuilder: (ctx, index) {
                            final item = behavior.mostOrdered[index];
                            return Card(
                              margin: const EdgeInsets.only(right: 10),
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['name'], 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1, 
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    Text('Ordered ${item['total_quantity']} times', 
                                      style: const TextStyle(fontSize: 11, color: Colors.grey)
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

 
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: menuProvider.categories.length,
                        itemBuilder: (ctx, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategoryIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: Colors.orange.withAlpha(77),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4)
                                  )
                                ] : [],
                                border: Border.all(color: Colors.orange.withAlpha(77)),
                              ),
                              child: Center(
                                child: Text(
                                  menuProvider.categories[index].name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: menuProvider
                            .categories[_selectedCategoryIndex].items.length,
                        itemBuilder: (ctx, index) {
                          final item = menuProvider
                              .categories[_selectedCategoryIndex].items[index];
                          return InkWell(
                            onTap: () => _showItemDetails(item, session, cart, kitchen),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(10),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4))
                                  ]),
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.grey, fontSize: 13)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'ETB ${item.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(width: 12),
                                              Icon(Icons.timer_outlined,
                                                  size: 14,
                                                  color: kitchen.extraMinutes > 0 ? Colors.red : Colors.grey[600]),
                                              const SizedBox(width: 4),
                                              Text(
                                                  '${item.prepTime + kitchen.extraMinutes} min',
                                                  style: TextStyle(
                                                      color: kitchen.extraMinutes > 0 ? Colors.red : Colors.grey[600],
                                                      fontWeight: kitchen.extraMinutes > 0 ? FontWeight.bold : FontWeight.normal,
                                                      fontSize: 12)),
                                              if (kitchen.extraMinutes > 0)
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 4),
                                                  child: Text('(Predicted)', style: TextStyle(fontSize: 10, color: Colors.red)),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
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
