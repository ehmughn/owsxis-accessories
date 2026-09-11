<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ShopifyService
{
    /**
     * Normalize host domain string into a standard shopify domain name.
     */
    public function formatDomain(?string $domain): string
    {
        $domain = $domain ?: config('services.shopify.domain', env('SHOPIFY_STORE_DOMAIN', 'owsxi.myshopify.com'));
        $domain = trim($domain);

        // Strip http:// or https:// if present
        $domain = preg_replace('#^https?://#i', '', $domain);
        // Strip path if present
        $domain = explode('/', $domain)[0];

        return $domain;
    }

    /**
     * Obtain access token using Client Credentials OAuth or return configured token.
     */
    public function getAccessToken(?string $domain = null): ?string
    {
        $token = env('SHOPIFY_ACCESS_TOKEN');
        if ($token) {
            return $token;
        }

        $clientId = env('SHOPIFY_CLIENT_ID');
        $clientSecret = env('SHOPIFY_CLIENT_SECRET');

        if (!$clientId || !$clientSecret) {
            return null;
        }

        $shopDomain = $this->formatDomain($domain);
        $url = "https://{$shopDomain}/admin/oauth/access_token";

        try {
            $response = Http::timeout(10)
                ->withoutVerifying()
                ->asForm()
                ->post($url, [
                    'grant_type' => 'client_credentials',
                    'client_id' => $clientId,
                    'client_secret' => $clientSecret,
                ]);

            if ($response->successful()) {
                return $response->json('access_token');
            }
        } catch (\Exception $e) {
            Log::error("Error obtaining Shopify access token: " . $e->getMessage());
        }

        return null;
    }

    /**
     * Fetch products from Shopify store using Admin REST API or public endpoint fallback.
     */
    public function fetchProducts(?string $domain = null, int $limit = 50): array
    {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        // 1. Try Shopify Admin API if token is available
        if ($token) {
            $adminUrl = "https://{$shopDomain}/admin/api/2024-04/products.json?limit={$limit}";
            try {
                $response = Http::timeout(12)
                    ->withoutVerifying()
                    ->withHeaders([
                        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                        'Accept' => 'application/json',
                        'X-Shopify-Access-Token' => $token,
                    ])->get($adminUrl);

                if ($response->successful()) {
                    $data = $response->json();
                    $rawProducts = $data['products'] ?? [];
                    if (!empty($rawProducts)) {
                        return array_map(function ($p) use ($shopDomain) {
                            return $this->formatShopifyProduct($p, $shopDomain);
                        }, $rawProducts);
                    }
                } else {
                    Log::warning("Shopify Admin API returned status {$response->status()} for {$shopDomain}");
                }
            } catch (\Exception $e) {
                Log::error("Shopify Admin API request error: " . $e->getMessage());
            }
        }

        // 2. Fallback to public Storefront JSON endpoint
        $publicUrl = "https://{$shopDomain}/products.json?limit={$limit}";
        try {
            $request = Http::timeout(12)
                ->withoutVerifying()
                ->withHeaders([
                    'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                    'Accept' => 'application/json',
                ]);

            if ($token) {
                $request = $request->withHeaders(['X-Shopify-Access-Token' => $token]);
            }

            $response = $request->get($publicUrl);

            if ($response->successful()) {
                $data = $response->json();
                $rawProducts = $data['products'] ?? [];

                return array_map(function ($p) use ($shopDomain) {
                    return $this->formatShopifyProduct($p, $shopDomain);
                }, $rawProducts);
            }
        } catch (\Exception $e) {
            Log::error("Error fetching public Shopify products: " . $e->getMessage());
        }

        return [];
    }

    /**
     * Fetch a single product by ID live from Shopify.
     */
    public function fetchProductById(string $id, ?string $domain = null): ?array
    {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        // 1. Try Admin API single product endpoint if token is available
        if ($token && is_numeric($id)) {
            $adminUrl = "https://{$shopDomain}/admin/api/2024-04/products/{$id}.json";
            try {
                $response = Http::timeout(10)
                    ->withoutVerifying()
                    ->withHeaders([
                        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                        'Accept' => 'application/json',
                        'X-Shopify-Access-Token' => $token,
                    ])->get($adminUrl);

                if ($response->successful()) {
                    $data = $response->json();
                    if (!empty($data['product'])) {
                        return $this->formatShopifyProduct($data['product'], $shopDomain);
                    }
                }
            } catch (\Exception $e) {
                Log::error("Shopify Admin API single product request error: " . $e->getMessage());
            }
        }

        // 2. Fallback: fetch all products live and filter by shopify_id or title/handle match
        $allProducts = $this->fetchProducts($shopDomain);
        foreach ($allProducts as $product) {
            if (
                (isset($product['shopify_id']) && (string)$product['shopify_id'] === (string)$id) ||
                (isset($product['id']) && (string)$product['id'] === (string)$id)
            ) {
                return $product;
            }
        }

        return !empty($allProducts) ? $allProducts[0] : null;
    }

    /**
     * Format raw Shopify JSON product into standard application schema.
     */
    public function formatShopifyProduct(array $p, string $shopDomain): array
    {
        // Extract price from first variant or default
        $variants = $p['variants'] ?? [];
        $firstVariant = $variants[0] ?? [];
        $price = isset($firstVariant['price']) ? (float) $firstVariant['price'] : 12.00;

        // Image URL
        $images = $p['images'] ?? [];
        $imageUrl = !empty($images) ? $images[0]['src'] : 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=500';

        // Clean HTML description
        $description = strip_tags($p['body_html'] ?? '');
        $description = trim(preg_replace('/\s+/', ' ', $description));
        if (empty($description)) {
            $description = "Authentic product from {$shopDomain}.";
        }

        // Category & Tag
        $category = !empty($p['product_type']) ? $p['product_type'] : (!empty($p['vendor']) ? $p['vendor'] : 'Collectibles');
        $tags = !empty($p['tags']) ? (is_array($p['tags']) ? $p['tags'] : explode(',', $p['tags'])) : ['Shopify'];
        $tag = !empty($tags) ? trim($tags[0]) : 'Featured';

        // Variant names
        $variantNames = array_map(function ($v) {
            return $v['title'] ?? 'Standard';
        }, $variants);
        if (empty($variantNames)) {
            $variantNames = ['Standard'];
        }

        return [
            'shopify_id' => (string) ($p['id'] ?? uniqid()),
            'shop_domain' => $shopDomain,
            'title' => $p['title'] ?? 'Shopify Product',
            'description' => $description,
            'price' => $price,
            'category' => $category,
            'tag' => $tag,
            'image_url' => $imageUrl,
            'in_stock' => true,
            'stock_quantity' => isset($firstVariant['inventory_quantity']) ? max(1, (int)$firstVariant['inventory_quantity']) : 25,
            'rating' => 4.9,
            'variants' => array_values(array_unique($variantNames)),
        ];
    }
}
