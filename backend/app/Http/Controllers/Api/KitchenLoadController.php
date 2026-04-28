<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class KitchenLoadController extends Controller
{
    /**
     * Requirement 7: AI Feature - Predicting preparation time / load.
     * 
     * Calculates the current kitchen load based on active orders.
     * Returns a 'load_factor' and 'extra_minutes' to add to menu prep times.
     */
    public function getLoadStatus()
    {
        $activeOrdersCount = Order::whereIn('status', ['received', 'cooking'])->count();
        
        $loadStatus = 'Normal';
        $extraMinutes = 0;
        
        if ($activeOrdersCount >= 10) {
            $loadStatus = 'High';
            $extraMinutes = 15;
        } elseif ($activeOrdersCount >= 5) {
            $loadStatus = 'Medium';
            $extraMinutes = 5;
        }

        return response()->json([
            'active_orders' => $activeOrdersCount,
            'load_status' => $loadStatus,
            'extra_minutes' => $extraMinutes,
            'message' => $extraMinutes > 0 
                ? "Kitchen is $loadStatus. Expect an additional $extraMinutes mins."
                : "Kitchen is operating at normal capacity."
        ]);
    }
}
