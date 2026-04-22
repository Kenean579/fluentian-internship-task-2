<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TableSession;
use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function start(Request $request)
    {
        $validated = $request->validate([
            'table_id' => 'required|string',
            'user_device_id' => 'required|string',
        ]);

        $session = TableSession::firstOrCreate(
            [
                'table_id' => $validated['table_id'],
                'user_device_id' => $validated['user_device_id'],
            ]
        );

        return response()->json([
            'message' => 'Session started successfully',
            'session' => $session,
        ], 200);
    }
}
