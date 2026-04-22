<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TableSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'table_id',
        'user_device_id',
    ];

    public function cart()
    {
        return $this->hasOne(Cart::class, 'session_id');
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'session_id');
    }
}
