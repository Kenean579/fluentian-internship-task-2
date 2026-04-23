<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\TableSession;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function place(Request $request, $sessionId)
    {
        $session = TableSession::findOrFail($sessionId);

        $cart = Cart::where('session_id', $session->id)
            ->with('items.menuItem')
            ->first();

        if (!$cart || $cart->items->isEmpty()) {
            return response()->json([
                'message' => 'Cart is empty. Please add items before placing an order.',
            ], 422);
        }

        $totalAmount = $cart->items->sum(function ($item) {
            return $item->unit_price * $item->quantity;
        });

        $orderNumber = 'ORD-' . strtoupper(Str::random(6));

        $order = Order::create([
            'order_number' => $orderNumber,
            'session_id' => $session->id,
            'status' => 'Received',
            'total_amount' => $totalAmount,
        ]);

        // Copy each cart item into the order as an order item
        foreach ($cart->items as $cartItem) {
            OrderItem::create([
                'order_id' => $order->id,
                'menu_item_id' => $cartItem->menu_item_id,
                'quantity' => $cartItem->quantity,
                'unit_price' => $cartItem->unit_price,
            ]);
        }

        $cart->items()->delete();
        $order->load('items.menuItem');

        return response()->json([
            'message' => 'Order placed successfully!',
            'data' => $order,
        ], 201);
    }

    public function show($orderId)
    {
        $order = Order::with('items.menuItem')->findOrFail($orderId);

        return response()->json([
            'message' => 'Order fetched successfully',
            'data' => $order,
        ]);
    }

    public function sessionOrders($sessionId)
    {
        $session = TableSession::findOrFail($sessionId);

        $orders = Order::with('items.menuItem')
            ->where('session_id', $session->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'Session orders fetched successfully',
            'data' => $orders,
        ]);
    }
}
