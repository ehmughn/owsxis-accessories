<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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
     * Get all products live from Shopify proxy (databaseless).
     */
    public function index(Request $request): JsonResponse
    {
        $shopDomain = $request->query('shop') ?: $request->query('domain');
        $products = $this->shopifyService->fetchProducts($shopDomain);

        return response()->json([
            'status' => 'success',
            'source' => 'shopify_live',
            'shop_domain' => $this->shopifyService->formatDomain($shopDomain),
            'count' => count($products),
            'data' => $products,
        ]);
    }

    /**
     * Get single product details live from Shopify proxy.
     */
    public function show(string $id, Request $request): JsonResponse
    {
        $shopDomain = $request->query('shop') ?: $request->query('domain');
        $product = $this->shopifyService->fetchProductById($id, $shopDomain);

        if (!$product) {
            return response()->json([
                'status' => 'error',
                'message' => 'Product not found on Shopify',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'source' => 'shopify_live',
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
     * Stateless proxy refresh endpoint (backwards compatible with sync route).
     */
    public function syncShopify(Request $request): JsonResponse
    {
        $domain = $request->input('domain') ?: $request->query('domain');
        $fetched = $this->shopifyService->fetchProducts($domain);

        return response()->json([
            'status' => 'success',
            'message' => 'Refreshed ' . count($fetched) . ' live products from Shopify proxy',
            'shop_domain' => $this->shopifyService->formatDomain($domain),
            'count' => count($fetched),
            'data' => $fetched,
        ]);
    }
}
