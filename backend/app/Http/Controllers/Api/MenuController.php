<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class MenuController extends Controller
{
    public function index()
    {
        $menu = Category::with(['menuItems' => function ($query) {
            $query->where('available', true);
        }])
        ->orderBy('display_order')
        ->get();

        return response()->json([
            'message' => 'Menu fetched successfully',
            'data' => $menu,
        ], 200);
    }
}
