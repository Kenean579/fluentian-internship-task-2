<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\SessionController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\CartController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/sessions/start', [SessionController::class, 'start']);
Route::get('/menu', [MenuController::class, 'index']);

Route::get('/sessions/{sessionId}/cart', [CartController::class, 'show']);
Route::post('/sessions/{sessionId}/cart', [CartController::class, 'add']);
Route::delete('/sessions/{sessionId}/cart/items/{cartItemId}', [CartController::class, 'remove']);
