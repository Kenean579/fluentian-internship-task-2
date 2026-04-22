<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MenuItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'name',
        'description',
        'price',
        'prep_time',
        'available',
        'image_url',
    ];

    // Explicitly cast attributes
    protected $casts = [
        'price' => 'decimal:2',
        'available' => 'boolean',
        'prep_time' => 'integer',
    ];

    // A menu item belongs to a category
    public function category()
    {
        return $this->belongsTo(Category::class);
    }
}
