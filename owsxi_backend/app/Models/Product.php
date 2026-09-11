<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'shopify_id',
        'shop_domain',
        'title',
        'description',
        'price',
        'category',
        'tag',
        'image_url',
        'in_stock',
        'stock_quantity',
        'rating',
        'variants',
    ];

    protected $casts = [
        'price' => 'float',
        'in_stock' => 'boolean',
        'stock_quantity' => 'integer',
        'rating' => 'float',
        'variants' => 'array',
    ];
}
