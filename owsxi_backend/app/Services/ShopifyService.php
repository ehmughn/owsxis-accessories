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
     * Extract exact category from Shopify product data.
     */
    public function extractCategory(array $p): string
    {
        // 1. Direct category taxonomy name (from GraphQL category { id name } or REST category payload)
        if (!empty($p['category'])) {
            if (is_array($p['category']) && !empty($p['category']['name'])) {
                return trim($p['category']['name']);
            } elseif (is_string($p['category']) && trim($p['category']) !== '') {
                return trim($p['category']);
            }
        }

        // 2. Direct product_category key
        if (!empty($p['product_category'])) {
            if (is_array($p['product_category']) && !empty($p['product_category']['name'])) {
                return trim($p['product_category']['name']);
            } elseif (is_string($p['product_category']) && trim($p['product_category']) !== '') {
                return trim($p['product_category']);
            }
        }

        // 3. Product type / productType explicitly set in Shopify store
        $productType = $p['product_type'] ?? ($p['productType'] ?? null);
        if (!empty($productType) && is_string($productType) && trim($productType) !== '') {
            return trim($productType);
        }

        // 4. Check collections
        if (!empty($p['collections'])) {
            $cols = $p['collections'];
            if (isset($cols['edges']) && is_array($cols['edges'])) {
                $cols = array_map(fn($edge) => $edge['node'] ?? [], $cols['edges']);
            }
            if (is_array($cols)) {
                foreach ($cols as $c) {
                    $title = is_array($c) ? ($c['title'] ?? '') : (string)$c;
                    $titleTrim = trim($title);
                    if ($titleTrim !== '' && !in_array(strtolower($titleTrim), ['featured products', 'new arrival', 'all', 'frontpage'])) {
                        return $titleTrim;
                    }
                }
            }
        }

        // 5. Check tags
        if (!empty($p['tags'])) {
            $tags = is_array($p['tags']) ? $p['tags'] : explode(',', $p['tags']);
            foreach ($tags as $t) {
                $tTrim = trim($t);
                if ($tTrim !== '' && !in_array(strtolower($tTrim), ['new arrival', 'featured', 'shopify'])) {
                    return $tTrim;
                }
            }
        }

        // 6. Infer category from product title if not yet identified
        $title = $p['title'] ?? '';
        if (!empty($title)) {
            $lowerTitle = strtolower($title);
            if (str_contains($lowerTitle, 'toploader')) return 'Toploaders';
            if (str_contains($lowerTitle, 'sticker')) return 'Stickers';
            if (str_contains($lowerTitle, 'keychain')) return 'Keychains';
            if (str_contains($lowerTitle, 'pin')) return 'Pins';
            if (str_contains($lowerTitle, 'charm')) return 'Charms';
            if (str_contains($lowerTitle, 'apparel') || str_contains($lowerTitle, 'shirt') || str_contains($lowerTitle, 'tee')) return 'Apparel';
        }

        // 7. Fallback to vendor if not generic store name
        if (!empty($p['vendor']) && strtolower(trim($p['vendor'])) !== 'owsxi') {
            return trim($p['vendor']);
        }

        return 'General';
    }

    /**
     * Fetch products from Shopify store using GraphQL, Admin REST API, or public endpoint fallback.
     */
    public function fetchProducts(?string $domain = null, int $limit = 50): array
    {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        // 1. Try Shopify Admin GraphQL API if token is available
        if ($token) {
            $graphqlUrl = "https://{$shopDomain}/admin/api/2024-04/graphql.json";
            $query = <<<'GRAPHQL'
query getProducts($first: Int!) {
  products(first: $first) {
    edges {
      node {
        id
        title
        description
        descriptionHtml
        productType
        vendor
        tags
        category {
          id
          name
        }
        collections(first: 10) {
          edges {
            node {
              id
              title
            }
          }
        }
        images(first: 10) {
          edges {
            node {
              url
              altText
            }
          }
        }
        variants(first: 50) {
          edges {
            node {
              id
              title
              price
              inventoryQuantity
            }
          }
        }
      }
    }
  }
}
GRAPHQL;

            try {
                $response = Http::timeout(12)
                    ->withoutVerifying()
                    ->withHeaders([
                        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                        'Content-Type' => 'application/json',
                        'X-Shopify-Access-Token' => $token,
                    ])->post($graphqlUrl, [
                        'query' => $query,
                        'variables' => ['first' => min($limit, 250)],
                    ]);

                if ($response->successful()) {
                    $edges = $response->json('data.products.edges') ?? [];
                    if (!empty($edges)) {
                        return array_map(function ($edge) use ($shopDomain) {
                            return $this->formatShopifyProductNode($edge['node'], $shopDomain);
                        }, $edges);
                    }
                } else {
                    Log::warning("Shopify Admin GraphQL API returned status {$response->status()} for {$shopDomain}");
                }
            } catch (\Exception $e) {
                Log::error("Shopify Admin GraphQL API request error: " . $e->getMessage());
            }

            // 2. Try REST Admin API fallback
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
                    Log::warning("Shopify Admin REST API returned status {$response->status()} for {$shopDomain}");
                }
            } catch (\Exception $e) {
                Log::error("Shopify Admin REST API request error: " . $e->getMessage());
            }
        }

        // 3. Fallback to public Storefront JSON endpoint
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

        // 1. Try Admin GraphQL API single product endpoint if token is available
        if ($token) {
            $graphqlUrl = "https://{$shopDomain}/admin/api/2024-04/graphql.json";
            $gid = str_starts_with($id, 'gid://') ? $id : "gid://shopify/Product/{$id}";

            $query = <<<'GRAPHQL'
query getProduct($id: ID!) {
  product(id: $id) {
    id
    title
    description
    descriptionHtml
    productType
    vendor
    tags
    category {
      id
      name
    }
    collections(first: 10) {
      edges {
        node {
          id
          title
        }
      }
    }
    images(first: 10) {
      edges {
        node {
          url
          altText
        }
      }
    }
    variants(first: 50) {
      edges {
        node {
          id
          title
          price
          inventoryQuantity
        }
      }
    }
  }
}
GRAPHQL;

            try {
                $response = Http::timeout(10)
                    ->withoutVerifying()
                    ->withHeaders([
                        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
                        'Content-Type' => 'application/json',
                        'X-Shopify-Access-Token' => $token,
                    ])->post($graphqlUrl, [
                        'query' => $query,
                        'variables' => ['id' => $gid],
                    ]);

                if ($response->successful()) {
                    $productNode = $response->json('data.product');
                    if ($productNode) {
                        return $this->formatShopifyProductNode($productNode, $shopDomain);
                    }
                }
            } catch (\Exception $e) {
                Log::error("Shopify Admin GraphQL API single product error: " . $e->getMessage());
            }
        }

        // 2. Try Admin REST API single product endpoint if token is available
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

        // 3. Fallback: fetch all products live and filter by shopify_id or title/handle match
        $allProducts = $this->fetchProducts($shopDomain);
        foreach ($allProducts as $product) {
            if (
                (isset($product['shopify_id']) && (string)$product['shopify_id'] === (string)$id) ||
                (isset($product['id']) && (string)$product['id'] === (string)$id)
            ) {
                return $product;
            }
        }

        return null;
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
        $category = $this->extractCategory($p);
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

    /**
     * Format GraphQL Shopify product node into standard application schema.
     */
    public function formatShopifyProductNode(array $node, string $shopDomain): array
    {
        $rawId = $node['id'] ?? '';
        $numericId = preg_replace('/[^0-9]/', '', $rawId);
        $shopifyId = !empty($numericId) ? $numericId : $rawId;

        // Extract price and stock from variants
        $variantEdges = $node['variants']['edges'] ?? [];
        $firstVariant = $variantEdges[0]['node'] ?? [];
        $price = isset($firstVariant['price']) ? (float)$firstVariant['price'] : 12.00;
        $stockQuantity = isset($firstVariant['inventoryQuantity']) ? max(1, (int)$firstVariant['inventoryQuantity']) : 25;

        // Images
        $imageEdges = $node['images']['edges'] ?? [];
        $imageUrl = !empty($imageEdges) ? ($imageEdges[0]['node']['url'] ?? '') : '';
        if (empty($imageUrl)) {
            $imageUrl = 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=500';
        }

        // Clean description
        $rawDesc = !empty($node['description']) ? $node['description'] : ($node['descriptionHtml'] ?? '');
        $description = strip_tags($rawDesc);
        $description = trim(preg_replace('/\s+/', ' ', $description));
        if (empty($description)) {
            $description = "Authentic product from {$shopDomain}.";
        }

        // Category & Tag
        $category = $this->extractCategory($node);

        $tags = $node['tags'] ?? [];
        $tag = !empty($tags) ? trim($tags[0]) : 'Featured';

        // Variant names
        $variantNames = array_map(function ($vEdge) {
            return $vEdge['node']['title'] ?? 'Standard';
        }, $variantEdges);
        if (empty($variantNames)) {
            $variantNames = ['Standard'];
        }

        return [
            'shopify_id' => (string)$shopifyId,
            'shop_domain' => $shopDomain,
            'title' => $node['title'] ?? 'Shopify Product',
            'description' => $description,
            'price' => $price,
            'category' => $category,
            'tag' => $tag,
            'image_url' => $imageUrl,
            'in_stock' => true,
            'stock_quantity' => $stockQuantity,
            'rating' => 4.9,
            'variants' => array_values(array_unique($variantNames)),
        ];
    }
}
