<?php

namespace App\Http\Controllers\Api;

use App\Events\OrderStatusUpdated;
use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class StaffController extends Controller
{
    public function pendingOrders()
    {
        $orders = Order::with('items.menuItem')
            ->whereIn('status', ['Received', 'Cooking', 'Ready'])
            ->orderBy('created_at', 'asc')
            ->get();

        return response()->json([
            'message' => 'Pending orders fetched',
            'data' => $orders,
        ]);
    }

    public function allOrders()
    {
        $orders = Order::with('items.menuItem')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'All orders fetched',
            'data' => $orders,
        ]);
    }

    public function updateStatus(Request $request, $orderId)
    {
        $validated = $request->validate([
            'status' => 'required|in:Received,Cooking,Ready,Delivered',
        ]);

        $order = Order::findOrFail($orderId);
        $order->update(['status' => $validated['status']]);

        broadcast(new OrderStatusUpdated($order))->toOthers();

        return response()->json([
            'message' => 'Order status updated to ' . $validated['status'],
            'data' => $order,
        ]);
    }
}
