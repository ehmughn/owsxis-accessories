<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Services\ShopifyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    protected ShopifyService $shopifyService;

    public function __construct(ShopifyService $shopifyService)
    {
        $this->shopifyService = $shopifyService;
    }

    /**
     * Get all products.
     * Can fetch from local DB or live from a Shopify store domain.
     */
    public function index(Request $request): JsonResponse
    {
        $shopDomain = $request->query('shop');
        $live = $request->boolean('live', false);

        if ($live || $shopDomain) {
            $products = $this->shopifyService->fetchProducts($shopDomain);
            return response()->json([
                'status' => 'success',
                'source' => 'shopify_live',
                'shop_domain' => $this->shopifyService->formatDomain($shopDomain),
                'count' => count($products),
                'data' => $products,
            ]);
        }

        // Fetch from local database
        $products = Product::all();

        if ($products->isEmpty()) {
            return response()->json([
                'status' => 'error',
                'message' => 'No products found in database.',
                'count' => 0,
                'data' => [],
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'source' => 'database',
            'count' => $products->count(),
            'data' => $products,
        ]);
    }

    /**
     * Get single product details.
     */
    public function show(string $id): JsonResponse
    {
        $product = Product::where('id', $id)
            ->orWhere('shopify_id', $id)
            ->first();

        if (!$product) {
            return response()->json([
                'status' => 'error',
                'message' => 'Product not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $product,
        ]);
    }

    /**
     * Fetch products directly from a specific Shopify website.
     */
    public function fetchShopify(Request $request): JsonResponse
    {
        $request->validate([
            'domain' => 'nullable|string',
        ]);

        $domain = $request->input('domain') ?: $request->query('domain');
        $products = $this->shopifyService->fetchProducts($domain);

        return response()->json([
            'status' => 'success',
            'source' => 'shopify_live',
            'shop_domain' => $this->shopifyService->formatDomain($domain),
            'count' => count($products),
            'data' => $products,
        ]);
    }

    /**
     * Sync products from a Shopify store into the local database.
     */
    public function syncShopify(Request $request): JsonResponse
    {
        $domain = $request->input('domain') ?: env('SHOPIFY_STORE_DOMAIN', 'owsxi.myshopify.com');
        $fetched = $this->shopifyService->fetchProducts($domain);

        $synced = [];
        foreach ($fetched as $item) {
            $product = Product::updateOrCreate(
                ['shopify_id' => $item['shopify_id']],
                $item
            );
            $synced[] = $product;
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Synced ' . count($synced) . ' products from Shopify',
            'shop_domain' => $this->shopifyService->formatDomain($domain),
            'count' => count($synced),
            'data' => $synced,
        ]);
    }
}
