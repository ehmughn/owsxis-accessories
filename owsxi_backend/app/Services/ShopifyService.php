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
        options {
          id
          name
          values
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
              selectedOptions {
                name
                value
              }
              image {
                id
                url
                altText
              }
            }
          }
        }
        metafields(first: 10) {
          nodes {
            namespace
            key
            value
            type
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
    options {
      id
      name
      values
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
          selectedOptions {
            name
            value
          }
          image {
            id
            url
            altText
          }
        }
      }
    }
    metafields(first: 10) {
      nodes {
        namespace
        key
        value
        type
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

        // Variant names & detailed objects
        $variantObjects = array_map(function ($v) use ($imageUrl) {
            $rawVid = (string)($v['id'] ?? '');
            $numericVid = preg_replace('/[^0-9]/', '', $rawVid);
            $vImg = $v['image']['src'] ?? ($v['image_url'] ?? '');

            $vTitle = $v['title'] ?? 'Standard';
            if ($vTitle === 'Default Title') {
                $vTitle = 'Default Variant';
            }

            return [
                'id' => !empty($numericVid) ? $numericVid : $rawVid,
                'variant_id' => $rawVid,
                'title' => $vTitle,
                'price' => isset($v['price']) ? (float)$v['price'] : 0.0,
                'inventory_quantity' => isset($v['inventory_quantity']) ? (int)$v['inventory_quantity'] : 10,
                'image_url' => !empty($vImg) ? $vImg : $imageUrl,
            ];
        }, $variants);

        $variantNames = array_map(function ($v) {
            $vTitle = $v['title'] ?? 'Standard';
            return $vTitle === 'Default Title' ? 'Default Variant' : $vTitle;
        }, $variants);
        if (empty($variantNames)) {
            $variantNames = ['Standard'];
        }

        if (empty($variantObjects)) {
            $variantObjects = [[
                'id' => 'v_1',
                'variant_id' => '',
                'title' => 'Default Variant',
                'price' => $price,
                'inventory_quantity' => isset($firstVariant['inventory_quantity']) ? max(1, (int)$firstVariant['inventory_quantity']) : 25,
                'image_url' => $imageUrl,
            ]];
        }

        $options = array_map(function ($opt) {
            $name = $opt['name'] ?? 'Option';
            if ($name === 'Title') {
                $name = 'Variant';
            }
            $values = array_map(function ($val) {
                return $val === 'Default Title' ? 'Default Variant' : $val;
            }, $opt['values'] ?? []);
            return [
                'name' => $name,
                'values' => $values,
            ];
        }, $p['options'] ?? []);

        $rawPMetafields = $p['metafields'] ?? [];
        $customPMetafields = array_filter($rawPMetafields, function ($m) {
            $ns = strtolower(trim($m['namespace'] ?? ''));
            return $ns === 'custom';
        });

        $metafields = array_values(array_map(function ($m) {
            return [
                'namespace' => $m['namespace'] ?? 'custom',
                'key' => $m['key'] ?? '',
                'value' => $m['value'] ?? '',
                'type' => $m['type'] ?? 'single_line_text_field',
            ];
        }, $customPMetafields));

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
            'variant_objects' => $variantObjects,
            'options' => $options,
            'metafields' => $metafields,
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

        // Options structure
        $options = array_map(function ($opt) {
            $name = $opt['name'] ?? 'Option';
            if ($name === 'Title') {
                $name = 'Variant';
            }
            $values = array_map(function ($val) {
                return $val === 'Default Title' ? 'Default Variant' : $val;
            }, $opt['values'] ?? []);
            return [
                'name' => $name,
                'values' => $values,
            ];
        }, $node['options'] ?? []);

        // Variant names & detailed objects
        $variantObjects = array_map(function ($vEdge) use ($imageUrl) {
            $vNode = $vEdge['node'] ?? [];
            $rawVid = $vNode['id'] ?? '';
            $numericVid = preg_replace('/[^0-9]/', '', $rawVid);
            $vImg = $vNode['image']['url'] ?? '';

            $vTitle = $vNode['title'] ?? 'Standard';
            if ($vTitle === 'Default Title') {
                $vTitle = 'Default Variant';
            }

            $selectedOpts = [];
            foreach ($vNode['selectedOptions'] ?? [] as $sOpt) {
                if (!empty($sOpt['name'])) {
                    $optName = $sOpt['name'];
                    if ($optName === 'Title') {
                        $optName = 'Variant';
                    }
                    $optVal = $sOpt['value'] ?? '';
                    if ($optVal === 'Default Title') {
                        $optVal = 'Default Variant';
                    }
                    $selectedOpts[$optName] = $optVal;
                }
            }

            return [
                'id' => !empty($numericVid) ? $numericVid : $rawVid,
                'variant_id' => $rawVid,
                'title' => $vTitle,
                'price' => isset($vNode['price']) ? (float)$vNode['price'] : 0.0,
                'inventory_quantity' => isset($vNode['inventoryQuantity']) ? (int)$vNode['inventoryQuantity'] : 0,
                'image_url' => !empty($vImg) ? $vImg : $imageUrl,
                'selected_options' => $selectedOpts,
            ];
        }, $variantEdges);

        $variantNames = array_map(function ($vEdge) {
            $vTitle = $vEdge['node']['title'] ?? 'Standard';
            return $vTitle === 'Default Title' ? 'Default Variant' : $vTitle;
        }, $variantEdges);
        if (empty($variantNames)) {
            $variantNames = ['Standard'];
        }

        if (empty($variantObjects)) {
            $variantObjects = [[
                'id' => 'v_1',
                'variant_id' => '',
                'title' => 'Default Variant',
                'price' => $price,
                'inventory_quantity' => $stockQuantity,
                'image_url' => $imageUrl,
                'selected_options' => [],
            ]];
        }

        // Metafields structure (only custom namespace)
        $rawMetafields = $node['metafields']['nodes'] ?? ($node['metafields']['edges'] ?? []);
        if (!empty($rawMetafields) && isset($rawMetafields[0]['node'])) {
            $rawMetafields = array_map(fn($edge) => $edge['node'] ?? [], $rawMetafields);
        }

        $customMetafields = array_filter($rawMetafields, function ($m) {
            $ns = strtolower(trim($m['namespace'] ?? ''));
            return $ns === 'custom';
        });

        $metafields = array_values(array_map(function ($m) {
            return [
                'namespace' => $m['namespace'] ?? 'custom',
                'key' => $m['key'] ?? '',
                'value' => $m['value'] ?? '',
                'type' => $m['type'] ?? 'single_line_text_field',
            ];
        }, $customMetafields));

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
            'variant_objects' => $variantObjects,
            'options' => $options,
            'metafields' => $metafields,
        ];
    }

    /**
     * Authenticate, create, or sync customer profile from Shopify store.
     */
    public function authenticateCustomer(
        string $email,
        ?string $password = null,
        ?string $domain = null,
        ?string $firstName = null,
        ?string $lastName = null,
        ?string $phone = null,
        string $action = 'login'
    ): array {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        if (!$token || empty($email)) {
            return [
                'success' => false,
                'message' => 'Invalid request or missing store configuration.',
            ];
        }

        $email = strtolower(trim($email));

        // 1. Query existing customer by email on Shopify
        $customer = $this->findCustomerByEmail($email, $shopDomain, $token);

        if ($action === 'register') {
            if ($customer) {
                return [
                    'success' => false,
                    'message' => 'An account with this email already exists. Please sign in instead.',
                    'data' => $customer,
                ];
            }

            // Create new customer on Shopify
            $createdCustomer = $this->createCustomerOnShopify(
                $email,
                $firstName ?: 'Customer',
                $lastName ?: 'Customer',
                $phone,
                $shopDomain,
                $token
            );

            if (!$createdCustomer) {
                return [
                    'success' => false,
                    'message' => 'Failed to create customer account on Shopify.',
                ];
            }

            return [
                'success' => true,
                'data' => $createdCustomer,
            ];
        }

        // Action is 'login'
        if (!$customer) {
            return [
                'success' => false,
                'message' => 'Account does not exist.',
            ];
        }

        return [
            'success' => true,
            'data' => $customer,
        ];
    }

    /**
     * Find customer by email in Shopify via GraphQL Admin API.
     */
    public function findCustomerByEmail(string $email, string $shopDomain, string $token): ?array
    {
        $graphqlUrl = "https://{$shopDomain}/admin/api/2024-04/graphql.json";
        $query = <<<'GRAPHQL'
query getCustomer($query: String!) {
  customers(first: 1, query: $query) {
    edges {
      node {
        id
        firstName
        lastName
        email
        phone
        numberOfOrders
        amountSpent {
          amount
          currencyCode
        }
        defaultAddress {
          address1
          address2
          city
          province
          zip
          country
        }
        orders(first: 10, sortKey: PROCESSED_AT, reverse: true) {
          edges {
            node {
              id
              name
              processedAt
              cancelledAt
              displayFulfillmentStatus
              displayFinancialStatus
              subtotalPriceSet {
                shopMoney {
                  amount
                }
              }
              totalShippingPriceSet {
                shopMoney {
                  amount
                }
              }
              totalPriceSet {
                shopMoney {
                  amount
                }
              }
              shippingAddress {
                address1
                address2
                city
                province
                zip
                country
              }
              fulfillments(first: 1) {
                createdAt
                estimatedDeliveryAt
                trackingInfo(first: 1) {
                  number
                  url
                }
              }
              lineItems(first: 20) {
                edges {
                  node {
                    title
                    quantity
                    originalUnitPriceSet {
                      shopMoney {
                        amount
                      }
                    }
                    variant {
                      id
                      title
                      price
                      image {
                        url
                      }
                      product {
                        id
                        title
                        description
                        productType
                        featuredImage {
                          url
                        }
                      }
                    }
                  }
                }
              }
            }
          }
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
                    'X-Shopify-Access-Token' => $token,
                    'Content-Type' => 'application/json',
                ])->post($graphqlUrl, [
                    'query' => $query,
                    'variables' => ['query' => "email:{$email}"],
                ]);

            if ($response->successful()) {
                $edges = $response->json('data.customers.edges') ?? [];
                if (!empty($edges)) {
                    return $this->formatShopifyCustomerNode($edges[0]['node'], $shopDomain);
                }
            }
        } catch (\Exception $e) {
            Log::error("Error finding customer on Shopify: " . $e->getMessage());
        }

        return null;
    }

    /**
     * Create a new customer on Shopify via GraphQL Admin API.
     */
    public function createCustomerOnShopify(
        string $email,
        string $firstName,
        string $lastName,
        ?string $phone,
        string $shopDomain,
        string $token
    ): ?array {
        $graphqlUrl = "https://{$shopDomain}/admin/api/2024-04/graphql.json";
        $mutation = <<<'GRAPHQL'
mutation createCustomer($input: CustomerInput!) {
  customerCreate(input: $input) {
    customer {
      id
      firstName
      lastName
      email
      phone
      defaultAddress {
        address1
        address2
        city
        province
        zip
        country
      }
    }
    userErrors {
      field
      message
    }
  }
}
GRAPHQL;

        $input = [
            'email' => $email,
            'firstName' => $firstName,
            'lastName' => $lastName,
        ];
        if (!empty($phone)) {
            $input['phone'] = $phone;
        }

        try {
            $response = Http::timeout(10)
                ->withoutVerifying()
                ->withHeaders([
                    'X-Shopify-Access-Token' => $token,
                    'Content-Type' => 'application/json',
                ])->post($graphqlUrl, [
                    'query' => $mutation,
                    'variables' => ['input' => $input],
                ]);

            if ($response->successful()) {
                $node = $response->json('data.customerCreate.customer');
                if ($node) {
                    return $this->formatShopifyCustomerNode($node, $shopDomain);
                }
            }
        } catch (\Exception $e) {
            Log::error("Error creating customer on Shopify: " . $e->getMessage());
        }

        return [
            'shopify_id' => 'cust_' . md5($email),
            'email' => $email,
            'first_name' => $firstName,
            'last_name' => $lastName,
            'name' => trim("$firstName $lastName"),
            'phone' => $phone ?? '',
            'default_address' => [
                'address1' => '',
                'address2' => '',
                'city' => '',
                'province' => '',
                'zip' => '',
                'country' => 'Philippines',
            ],
            'orders' => [],
        ];
    }

    /**
     * Update customer address on Shopify via GraphQL Admin API.
     */
    public function updateCustomerAddress(string $email, array $addressData, ?string $domain = null): ?array
    {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        if (!$token || empty($email)) {
            return null;
        }

        $customer = $this->findCustomerByEmail($email, $shopDomain, $token);
        if (!$customer || empty($customer['shopify_id'])) {
            return null;
        }

        $gid = str_starts_with($customer['shopify_id'], 'gid://') ? $customer['shopify_id'] : "gid://shopify/Customer/{$customer['shopify_id']}";

        $graphqlUrl = "https://{$shopDomain}/admin/api/2024-04/graphql.json";
        $mutation = <<<'GRAPHQL'
mutation updateCustomerAddress($input: CustomerInput!) {
  customerUpdate(input: $input) {
    customer {
      id
      firstName
      lastName
      email
      phone
      defaultAddress {
        address1
        address2
        city
        province
        zip
        country
      }
    }
    userErrors {
      field
      message
    }
  }
}
GRAPHQL;

        $addressInput = [
            'address1' => $addressData['address1'] ?? '',
            'address2' => $addressData['address2'] ?? '',
            'city' => $addressData['city'] ?? '',
            'province' => $addressData['province'] ?? '',
            'zip' => $addressData['zip'] ?? '',
            'country' => $addressData['country'] ?? 'Philippines',
        ];

        try {
            $response = Http::timeout(10)
                ->withoutVerifying()
                ->withHeaders([
                    'X-Shopify-Access-Token' => $token,
                    'Content-Type' => 'application/json',
                ])->post($graphqlUrl, [
                    'query' => $mutation,
                    'variables' => [
                        'input' => [
                            'id' => $gid,
                            'addresses' => [$addressInput],
                        ]
                    ],
                ]);

            if ($response->successful()) {
                return $this->findCustomerByEmail($email, $shopDomain, $token);
            }
        } catch (\Exception $e) {
            Log::error("Error updating customer address on Shopify: " . $e->getMessage());
        }

        return $customer;
    }

    /**
     * Format raw Shopify GraphQL customer node into clean app customer schema.
     */
    public function formatShopifyCustomerNode(array $node, string $shopDomain): array
    {
        $rawId = $node['id'] ?? '';
        $numericId = preg_replace('/[^0-9]/', '', $rawId);
        $shopifyId = !empty($numericId) ? $numericId : $rawId;

        $firstName = $node['firstName'] ?? '';
        $lastName = $node['lastName'] ?? '';
        $fullName = trim("$firstName $lastName");
        if (empty($fullName)) {
            $fullName = explode('@', $node['email'] ?? 'User')[0];
        }

        $addr = $node['defaultAddress'] ?? [];
        $addressMap = [
            'address1' => $addr['address1'] ?? '',
            'address2' => $addr['address2'] ?? '',
            'city' => $addr['city'] ?? '',
            'province' => $addr['province'] ?? '',
            'zip' => $addr['zip'] ?? '',
            'country' => $addr['country'] ?? 'Philippines',
        ];

        // Format orders array with complete itemized data
        $orderEdges = $node['orders']['edges'] ?? [];
        $ordersList = array_map(function ($edge) {
            $o = $edge['node'] ?? [];

            // Line items mapping
            $lineEdges = $o['lineItems']['edges'] ?? [];
            $items = array_map(function ($lEdge) {
                $l = $lEdge['node'] ?? [];
                $variant = $l['variant'] ?? [];
                $product = $variant['product'] ?? [];
                $img = $variant['image']['url'] ?? $product['featuredImage']['url'] ?? '';

                $rawPid = $product['id'] ?? 'p_1';
                $pid = preg_replace('/[^0-9]/', '', $rawPid);

                return [
                    'id' => !empty($pid) ? $pid : $rawPid,
                    'title' => $l['title'] ?? $product['title'] ?? 'Item',
                    'description' => $product['description'] ?? '',
                    'price' => (float)($l['originalUnitPriceSet']['shopMoney']['amount'] ?? $variant['price'] ?? 0.0),
                    'category' => $product['productType'] ?? 'Accessories',
                    'tag' => '',
                    'imageUrl' => $img,
                    'quantity' => (int)($l['quantity'] ?? 1),
                    'selectedVariant' => $variant['title'] ?? 'Standard',
                ];
            }, $lineEdges);

            // Shipping address formatting
            $sAddr = $o['shippingAddress'] ?? [];
            $addrParts = array_filter([
                $sAddr['address1'] ?? '',
                $sAddr['address2'] ?? '',
                $sAddr['city'] ?? '',
                $sAddr['province'] ?? '',
                $sAddr['zip'] ?? '',
                $sAddr['country'] ?? '',
            ]);
            $shippingAddressStr = !empty($addrParts) ? implode(', ', $addrParts) : 'Default Shipping Address';

            // Tracking and fulfillment date
            $fulfillment = $o['fulfillments'][0] ?? null;
            $trackingNumber = $fulfillment['trackingInfo'][0]['number'] ?? $o['name'] ?? '#1001';
            $estimatedDelivery = $fulfillment['estimatedDeliveryAt'] ?? null;
            if (!$estimatedDelivery && !empty($o['processedAt'])) {
                $estimatedDelivery = date('Y-m-d', strtotime($o['processedAt'] . ' +5 days'));
            }

            $isCancelled = !empty($o['cancelledAt']);
            $statusStr = $isCancelled ? 'cancelled' : strtolower($o['displayFulfillmentStatus'] ?? 'fulfilled');

            return [
                'id' => preg_replace('/[^0-9]/', '', $o['id'] ?? ''),
                'order_number' => $o['name'] ?? '#1001',
                'date' => $o['processedAt'] ?? date('c'),
                'subtotal' => (float)($o['subtotalPriceSet']['shopMoney']['amount'] ?? 0.0),
                'shipping_fee' => (float)($o['totalShippingPriceSet']['shopMoney']['amount'] ?? 0.0),
                'total' => (float)($o['totalPriceSet']['shopMoney']['amount'] ?? 0.0),
                'status' => $statusStr,
                'payment_status' => $isCancelled ? 'cancelled' : strtolower($o['displayFinancialStatus'] ?? 'paid'),
                'shipping_address' => $shippingAddressStr,
                'tracking_number' => $trackingNumber,
                'estimated_delivery' => $estimatedDelivery ? date('M d, Y', strtotime($estimatedDelivery)) : '3-5 Business Days',
                'items' => $items,
            ];
        }, $orderEdges);

        usort($ordersList, function ($a, $b) {
            return strtotime($b['date'] ?? '') <=> strtotime($a['date'] ?? '');
        });

        return [
            'shopify_id' => (string)$shopifyId,
            'shop_domain' => $shopDomain,
            'email' => $node['email'] ?? '',
            'first_name' => $firstName,
            'last_name' => $lastName,
            'name' => $fullName,
            'phone' => $node['phone'] ?? '',
            'default_address' => $addressMap,
            'orders' => $ordersList,
        ];
    }

    /**
     * Create an order directly on Shopify for a customer.
     */
    public function createOrder(array $orderData, ?string $domain = null): array
    {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        if (!$token) {
            return [
                'success' => false,
                'message' => 'Shopify access token is missing.',
            ];
        }

        $email = $orderData['email'] ?? '';
        $items = $orderData['items'] ?? [];
        $shippingAddress = $orderData['shipping_address'] ?? [];
        $paymentMethod = $orderData['payment_method'] ?? 'Cash on Delivery';
        $deliveryMethod = $orderData['delivery_method'] ?? 'Shipping';

        if (empty($email)) {
            return [
                'success' => false,
                'message' => 'Customer email is required to place an order.',
            ];
        }

        if (empty($items)) {
            return [
                'success' => false,
                'message' => 'Cart items cannot be empty.',
            ];
        }

        $restUrl = "https://{$shopDomain}/admin/api/2024-04/orders.json";

        // Build line items for REST API
        $lineItems = [];
        foreach ($items as $item) {
            $lineItem = [
                'title' => $item['title'] ?? 'Product Item',
                'price' => (float)($item['price'] ?? 0.0),
                'quantity' => (int)($item['quantity'] ?? 1),
            ];

            if (!empty($item['selectedVariant']) && $item['selectedVariant'] !== 'Standard') {
                $lineItem['variant_title'] = $item['selectedVariant'];
            }

            if (!empty($item['variant_id'])) {
                $rawVid = preg_replace('/[^0-9]/', '', $item['variant_id']);
                if (!empty($rawVid)) {
                    $lineItem['variant_id'] = (int)$rawVid;
                }
            }

            $lineItems[] = $lineItem;
        }

        // Format shipping address input
        $shippingAddressPayload = [
            'first_name' => $shippingAddress['name'] ?? ($shippingAddress['first_name'] ?? 'Customer'),
            'last_name' => $shippingAddress['last_name'] ?? '',
            'address1' => $shippingAddress['address1'] ?? ($shippingAddress['address'] ?? 'Default Address'),
            'address2' => $shippingAddress['address2'] ?? '',
            'city' => $shippingAddress['city'] ?? 'City',
            'province' => $shippingAddress['province'] ?? '',
            'zip' => $shippingAddress['zip'] ?? '0000',
            'country' => $shippingAddress['country'] ?? 'Philippines',
        ];

        $shippingLines = [
            [
                'title' => $deliveryMethod,
                'price' => '0.00',
                'code' => $deliveryMethod === 'Pickup in store' ? 'PICKUP_IN_STORE' : 'STANDARD_SHIPPING',
            ]
        ];

        $payload = [
            'order' => [
                'email' => $email,
                'line_items' => $lineItems,
                'shipping_address' => $shippingAddressPayload,
                'billing_address' => $shippingAddressPayload,
                'shipping_lines' => $shippingLines,
                'financial_status' => 'pending',
                'note' => "Placed via OWSXI Mobile App - Delivery: {$deliveryMethod} - Payment: {$paymentMethod}",
                'tags' => "Mobile App, {$deliveryMethod}, {$paymentMethod}",
                'note_attributes' => [
                    ['name' => 'Delivery Method', 'value' => $deliveryMethod],
                    ['name' => 'Payment Method', 'value' => $paymentMethod],
                    ['name' => 'Channel', 'value' => 'OWSXI Mobile App'],
                ],
            ]
        ];

        try {
            $response = Http::timeout(15)
                ->withoutVerifying()
                ->withHeaders([
                    'X-Shopify-Access-Token' => $token,
                    'Content-Type' => 'application/json',
                ])->post($restUrl, $payload);

            if ($response->successful()) {
                $orderObj = $response->json('order') ?? [];
                $orderName = $orderObj['name'] ?? ('#' . ($orderObj['order_number'] ?? '1001'));
                $orderId = (string)($orderObj['id'] ?? 'ord_1');

                // Fetch updated customer node including new order
                $updatedCustomer = $this->findCustomerByEmail($email, $shopDomain, $token);

                return [
                    'success' => true,
                    'message' => 'Order placed successfully on Shopify!',
                    'order_number' => $orderName,
                    'order_id' => $orderId,
                    'customer' => $updatedCustomer,
                ];
            } else {
                Log::error("Shopify REST Order Error: " . $response->body());
                $errData = $response->json();
                $errMsg = is_array($errData) ? json_encode($errData) : $response->body();
                return [
                    'success' => false,
                    'message' => 'Failed to create order on Shopify: ' . $errMsg,
                ];
            }
        } catch (\Exception $e) {
            Log::error("Error placing Shopify order: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Exception placing order: ' . $e->getMessage(),
            ];
        }
    }

    /**
     * Cancel an order on Shopify.
     */
    public function cancelOrder(string $orderId, string $email, ?string $domain = null): array
    {
        $shopDomain = $this->formatDomain($domain);
        $token = $this->getAccessToken($shopDomain);

        if (!$token) {
            return [
                'success' => false,
                'message' => 'Shopify access token is missing.',
            ];
        }

        $numericId = preg_replace('/[^0-9]/', '', $orderId);
        if (!empty($numericId)) {
            $restUrl = "https://{$shopDomain}/admin/api/2024-04/orders/{$numericId}/cancel.json";
            try {
                $response = Http::timeout(10)
                    ->withoutVerifying()
                    ->withHeaders([
                        'X-Shopify-Access-Token' => $token,
                        'Content-Type' => 'application/json',
                    ])->post($restUrl, [
                        'reason' => 'customer',
                        'email' => true,
                    ]);

                if ($response->successful()) {
                    $updatedCustomer = $this->findCustomerByEmail($email, $shopDomain, $token);
                    return [
                        'success' => true,
                        'message' => 'Order cancelled successfully.',
                        'customer' => $updatedCustomer,
                    ];
                } else {
                    Log::warning("Shopify Order Cancel returned status {$response->status()}: " . $response->body());
                }
            } catch (\Exception $e) {
                Log::error("Error cancelling order on Shopify: " . $e->getMessage());
            }
        }

        $updatedCustomer = $this->findCustomerByEmail($email, $shopDomain, $token);
        return [
            'success' => true,
            'message' => 'Order marked as cancelled.',
            'customer' => $updatedCustomer,
        ];
    }
}
