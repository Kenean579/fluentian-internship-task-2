<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\TableSession;
use Illuminate\Support\Facades\DB;

class UserBehaviorController extends Controller
{
    public function profile($sessionId)
    {
        $session = TableSession::findOrFail($sessionId);
        $deviceId = $session->user_device_id;

        // All session IDs belonging to this device
        $allSessionIds = TableSession::where('user_device_id', $deviceId)
            ->pluck('id');

        $allOrderIds = Order::whereIn('session_id', $allSessionIds)->pluck('id');

        // most ordered items (all-time for this device)
        $mostOrdered = OrderItem::whereIn('order_id', $allOrderIds)
            ->select(
                'menu_item_id',
                DB::raw('SUM(quantity) as total_quantity'),
                DB::raw('COUNT(DISTINCT order_id) as order_count')
            )
            ->with('menuItem:id,name,price,category_id')
            ->groupBy('menu_item_id')
            ->orderByDesc('total_quantity')
            ->limit(5)
            ->get()
            ->map(fn($item) => [
                'menu_item_id'   => $item->menu_item_id,
                'name'           => $item->menuItem?->name,
                'price'          => $item->menuItem?->price,
                'total_quantity' => $item->total_quantity,
                'order_count'    => $item->order_count,
            ]);

        // Recently ordered (current session only, last 5 distinct items)
        $currentSessionOrderIds = Order::where('session_id', $session->id)->pluck('id');

        $recentlyOrdered = OrderItem::whereIn('order_id', $currentSessionOrderIds)
            ->select('menu_item_id', DB::raw('MAX(created_at) as last_ordered'))
            ->with('menuItem:id,name,price')
            ->groupBy('menu_item_id')
            ->orderByDesc('last_ordered')
            ->limit(5)
            ->get()
            ->map(fn($item) => [
                'menu_item_id' => $item->menu_item_id,
                'name'         => $item->menuItem?->name,
                'price'        => $item->menuItem?->price,
                'last_ordered' => $item->last_ordered,
            ]);

        // ── 3. Preference profile (category breakdown) ─────────────────────
        $categoryBreakdown = OrderItem::whereIn('order_id', $allOrderIds)
            ->join('menu_items', 'order_items.menu_item_id', '=', 'menu_items.id')
            ->join('categories', 'menu_items.category_id', '=', 'categories.id')
            ->select(
                'categories.id as category_id',
                'categories.name as category_name',
                DB::raw('SUM(order_items.quantity) as total_items_ordered'),
                DB::raw('SUM(order_items.quantity * order_items.unit_price) as total_spend')
            )
            ->groupBy('categories.id', 'categories.name')
            ->orderByDesc('total_spend')
            ->get();

        $totalSpend = $categoryBreakdown->sum('total_spend');

        $preferenceProfile = $categoryBreakdown->map(fn($cat) => [
            'category_id'         => $cat->category_id,
            'category_name'       => $cat->category_name,
            'total_items_ordered' => $cat->total_items_ordered,
            'total_spend_etb'     => round($cat->total_spend, 2),
            'preference_pct'      => $totalSpend > 0
                ? round(($cat->total_spend / $totalSpend) * 100, 1)
                : 0,
        ]);

        return response()->json([
            'device_id'          => $deviceId,
            'session_id'         => $session->id,
            'most_ordered'       => $mostOrdered,
            'recently_ordered'   => $recentlyOrdered,
            'preference_profile' => $preferenceProfile,
            'total_orders'       => $allOrderIds->count(),
            'total_sessions'     => $allSessionIds->count(),
        ]);
    }
}
