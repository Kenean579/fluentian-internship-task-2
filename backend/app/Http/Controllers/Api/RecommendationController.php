<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\MenuItem;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\TableSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RecommendationController extends Controller
{
    /**
     * Get up to 3 personalized AI recommendations for a session.
     *
     * Algorithm:
     * 1. Look at the session's past orders and count item frequencies.
     * 2. Return the top items not already in the current cart.
     * 3. If no history, fall back to the most popular items globally.
     */
    public function recommend($sessionId)
    {
        $session = TableSession::findOrFail($sessionId);

        // Get IDs of items already in the cart (to exclude from recommendations)
        $cart = Cart::where('session_id', $session->id)->first();
        $cartItemIds = $cart
            ? $cart->items->pluck('menu_item_id')->toArray()
            : [];

        // Step 1: Get this session's past order history and count item frequency
        $sessionOrderIds = Order::where('session_id', $session->id)->pluck('id');

        $personalizedIds = [];

        if ($sessionOrderIds->isNotEmpty()) {
            // Collaborative filtering: rank by how often ordered in this session
            $personalizedIds = OrderItem::whereIn('order_id', $sessionOrderIds)
                ->whereNotIn('menu_item_id', $cartItemIds)
                ->select('menu_item_id', DB::raw('SUM(quantity) as total_ordered'))
                ->groupBy('menu_item_id')
                ->orderByDesc('total_ordered')
                ->limit(3)
                ->pluck('menu_item_id')
                ->toArray();
        }

        // Step 2: If we have personalized results, return them
        if (!empty($personalizedIds)) {
            $recommendations = MenuItem::whereIn('id', $personalizedIds)
                ->where('available', true)
                ->get();

            return response()->json([
                'message' => 'Personalized recommendations',
                'type'    => 'personalized',
                'data'    => $recommendations,
            ]);
        }

        // Step 3: Fallback — globally most popular items (across all sessions)
        $popularIds = OrderItem::whereNotIn('menu_item_id', $cartItemIds)
            ->select('menu_item_id', DB::raw('SUM(quantity) as total_ordered'))
            ->groupBy('menu_item_id')
            ->orderByDesc('total_ordered')
            ->limit(3)
            ->pluck('menu_item_id')
            ->toArray();

        if (!empty($popularIds)) {
            $recommendations = MenuItem::whereIn('id', $popularIds)
                ->where('available', true)
                ->get();

            return response()->json([
                'message' => 'Popular recommendations',
                'type'    => 'popular',
                'data'    => $recommendations,
            ]);
        }

        // Step 4: If no orders exist at all, return 3 random available items
        $recommendations = MenuItem::where('available', true)
            ->inRandomOrder()
            ->limit(3)
            ->get();

        return response()->json([
            'message' => 'Featured items',
            'type'    => 'featured',
            'data'    => $recommendations,
        ]);
    }
}
