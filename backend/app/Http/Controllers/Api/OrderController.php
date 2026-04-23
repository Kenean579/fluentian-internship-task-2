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
    public function index($sessionId)
    {
        $session = TableSession::find($sessionId);

        if (!$session) {
            return response()->json(['message' => 'Session not found'], 404);
        }

        $orders = Order::with('items.menuItem')
            ->where('session_id', $session->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($orders);
    }

    public function store($sessionId)
    {
        $session = TableSession::find($sessionId);

        if (!$session) {
            return response()->json(['message' => 'Session not found'], 404);
        }

        if (!$session->is_active) {
            return response()->json(['message' => 'Session is not active'], 400);
        }

        $cart = Cart::with('items.menuItem')->where('session_id', $session->id)->first();

        if (!$cart || $cart->items->isEmpty()) {
            return response()->json(['message' => 'Cart is empty'], 400);
        }

        $totalAmount = $cart->items->sum(function ($item) {
            return $item->quantity * $item->menuItem->price;
        });

        $order = Order::create([
            'order_number' => 'ORD-' . strtoupper(Str::random(6)),
            'session_id' => $session->id,
            'status' => 'Received',
            'total_amount' => $totalAmount,
        ]);

        foreach ($cart->items as $cartItem) {
            OrderItem::create([
                'order_id' => $order->id,
                'menu_item_id' => $cartItem->menu_item_id,
                'quantity' => $cartItem->quantity,
                'unit_price' => $cartItem->menuItem->price,
            ]);
        }

        // Clear the cart
        $cart->items()->delete();

        return response()->json($order->load('items.menuItem'), 201);
    }
}
