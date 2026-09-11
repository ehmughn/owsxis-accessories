<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('shopify_id')->nullable()->index();
            $table->string('shop_domain')->nullable()->index();
            $table->string('title');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2)->default(0.00);
            $table->string('category')->default('General');
            $table->string('tag')->nullable();
            $table->text('image_url')->nullable();
            $table->boolean('in_stock')->default(true);
            $table->integer('stock_quantity')->default(10);
            $table->double('rating', 3, 2)->default(4.8);
            $table->json('variants')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
