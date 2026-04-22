<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\MenuItem;
use App\Models\TableSession;
use Illuminate\Http\Request;

class CartController extends Controller
{

    public function show($sessionId)
    {
        $session = TableSession::findOrFail($sessionId);

        $cart = Cart::firstOrCreate(['session_id' => $session->id]);
        $cart->load('items.menuItem');

        return response()->json([
            'message' => 'Cart fetched successfully',
            'data' => $cart,
        ]);
    }

    public function add(Request $request, $sessionId)
    {
        $validated = $request->validate([
            'menu_item_id' => 'required|exists:menu_items,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $session = TableSession::findOrFail($sessionId);

        $cart = Cart::firstOrCreate(['session_id' => $session->id]);

        $menuItem = MenuItem::findOrFail($validated['menu_item_id']);

        $cartItem = CartItem::where('cart_id', $cart->id)
            ->where('menu_item_id', $menuItem->id)
            ->first();

        if ($cartItem) {
            $cartItem->increment('quantity', $validated['quantity']);
        } else {
            CartItem::create([
                'cart_id' => $cart->id,
                'menu_item_id' => $menuItem->id,
                'quantity' => $validated['quantity'],
                'unit_price' => $menuItem->price, // Price snapshot
            ]);
        }

        $cart->load('items.menuItem');

        return response()->json([
            'message' => 'Item added to cart',
            'data' => $cart,
        ]);
    }

    public function remove($sessionId, $cartItemId)
    {
        $session = TableSession::findOrFail($sessionId);
        $cart = Cart::where('session_id', $session->id)->firstOrFail();

        $cartItem = CartItem::where('id', $cartItemId)
            ->where('cart_id', $cart->id)
            ->firstOrFail();

        $cartItem->delete();

        $cart->load('items.menuItem');

        return response()->json([
            'message' => 'Item removed from cart',
            'data' => $cart,
        ]);
    }
}
