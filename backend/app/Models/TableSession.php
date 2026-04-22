<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TableSession extends Model
{
    use HasFactory;

    /**
     * The fields that can be mass-assigned (safe for create/update).
     */
    protected $fillable = [
        'table_id',
        'user_device_id',
    ];

    /**
     * A session has one cart (created when the customer first adds an item).
     */
    public function cart()
    {
        return $this->hasOne(Cart::class, 'session_id');
    }

    /**
     * A session can have many orders placed over its lifetime.
     */
    public function orders()
    {
        return $this->hasMany(Order::class, 'session_id');
    }
}
