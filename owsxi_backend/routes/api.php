<?php

use App\Http\Controllers\Api\ProductController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application.
|
*/

Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{id}', [ProductController::class, 'show']);

Route::match(['get', 'post'], '/shopify/fetch', [ProductController::class, 'fetchShopify']);
Route::match(['get', 'post'], '/shopify/sync', [ProductController::class, 'syncShopify']);
