<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ShopifyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    protected ShopifyService $shopifyService;

    public function __construct(ShopifyService $shopifyService)
    {
        $this->shopifyService = $shopifyService;
    }

    /**
     * Authenticate or register a customer using Shopify customer accounts.
     */
    public function authenticate(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'nullable|string',
            'first_name' => 'nullable|string',
            'last_name' => 'nullable|string',
            'phone' => 'nullable|string',
            'domain' => 'nullable|string',
            'action' => 'nullable|string',
            'is_sign_up' => 'nullable|boolean',
        ]);

        $email = $request->input('email');
        $password = $request->input('password');
        $firstName = $request->input('first_name');
        $lastName = $request->input('last_name');
        $phone = $request->input('phone');
        $domain = $request->input('domain') ?: $request->query('domain');

        $action = $request->input('action');
        if (!$action) {
            $action = $request->boolean('is_sign_up') ? 'register' : 'login';
        }

        $result = $this->shopifyService->authenticateCustomer(
            $email,
            $password,
            $domain,
            $firstName,
            $lastName,
            $phone,
            $action
        );

        if (!$result['success']) {
            return response()->json([
                'status' => 'error',
                'message' => $result['message'] ?? 'Unable to authenticate customer account.',
            ], 200);
        }

        return response()->json([
            'status' => 'success',
            'source' => 'shopify_live',
            'data' => $result['data'],
        ]);
    }

    /**
     * Update customer address on Shopify.
     */
    public function updateAddress(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'address1' => 'nullable|string',
            'address2' => 'nullable|string',
            'city' => 'nullable|string',
            'province' => 'nullable|string',
            'zip' => 'nullable|string',
            'country' => 'nullable|string',
            'domain' => 'nullable|string',
        ]);

        $email = $request->input('email');
        $domain = $request->input('domain');
        $addressData = $request->only(['address1', 'address2', 'city', 'province', 'zip', 'country']);

        $updated = $this->shopifyService->updateCustomerAddress($email, $addressData, $domain);

        return response()->json([
            'status' => 'success',
            'source' => 'shopify_live',
            'data' => $updated,
        ]);
    }

    /**
     * Create order on Shopify.
     */
    public function createOrder(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'items' => 'required|array',
            'shipping_address' => 'nullable|array',
            'payment_method' => 'nullable|string',
            'delivery_method' => 'nullable|string',
            'domain' => 'nullable|string',
        ]);

        $orderData = $request->only(['email', 'items', 'shipping_address', 'payment_method', 'delivery_method']);
        $domain = $request->input('domain');

        $result = $this->shopifyService->createOrder($orderData, $domain);

        return response()->json($result);
    }

    /**
     * Cancel order on Shopify.
     */
    public function cancelOrder(Request $request): JsonResponse
    {
        $request->validate([
            'email' => 'required|email',
            'order_id' => 'required|string',
            'domain' => 'nullable|string',
        ]);

        $email = $request->input('email');
        $orderId = $request->input('order_id');
        $domain = $request->input('domain');

        $result = $this->shopifyService->cancelOrder($orderId, $email, $domain);

        return response()->json($result);
    }
}
