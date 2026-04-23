<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SessionController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\StaffController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Smart Restaurant API Routes
Route::post('/sessions/start', [SessionController::class, 'start']);
Route::get('/menu', [MenuController::class, 'index']);

// Cart routes
Route::get('/sessions/{sessionId}/cart', [CartController::class, 'show']);
Route::post('/sessions/{sessionId}/cart', [CartController::class, 'add']);
Route::delete('/sessions/{sessionId}/cart/items/{cartItemId}', [CartController::class, 'remove']);

// Customer order routes
Route::post('/sessions/{sessionId}/orders', [OrderController::class, 'place']);
Route::get('/orders/{orderId}', [OrderController::class, 'show']);
Route::get('/sessions/{sessionId}/orders', [OrderController::class, 'sessionOrders']);

// Staff panel routes
Route::get('/staff/orders/pending', [StaffController::class, 'pendingOrders']);
Route::get('/staff/orders/all', [StaffController::class, 'allOrders']);
Route::patch('/staff/orders/{orderId}/status', [StaffController::class, 'updateStatus']);
