<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'session_id',
        'status',
        'total_amount',
    ];

    public function session()
    {
        return $this->belongsTo(TableSession::class, 'session_id');
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
