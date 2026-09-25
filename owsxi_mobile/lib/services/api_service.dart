import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static String? _customBaseUrl;

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb) return 'http://localhost:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static void setBaseUrl(String newUrl) {
    _customBaseUrl = newUrl.replaceAll(RegExp(r'/*$'), '');
  }

  static List<String> get _candidateUrls {
    return {
      baseUrl,
      'http://127.0.0.1:8000/api',
      'http://localhost:8000/api',
      'http://10.0.2.2:8000/api',
    }.toList();
  }

  /// Get products from Laravel backend.
  static Future<List<Product>> getProducts({String? shopDomain, bool live = false}) async {
    final queryParams = <String, String>{};
    if (shopDomain != null && shopDomain.isNotEmpty) {
      queryParams['shop'] = shopDomain;
    }
    if (live) {
      queryParams['live'] = '1';
    }

    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/products').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
        final response = await http.get(uri).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] != null && data['data'] is List) {
            _customBaseUrl = base; // Save working URL
            final List list = data['data'];
            return list.map((item) => Product.fromJson(item)).toList();
          }
        }
      } catch (e) {
        debugPrint('ApiService.getProducts failed for $base: $e');
      }
    }
    return [];
  }

  /// Fetch live products from a specific Shopify store via Laravel backend.
  static Future<List<Product>> fetchShopifyProducts(String domain) async {
    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/shopify/fetch');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'domain': domain}),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] != null && data['data'] is List) {
            _customBaseUrl = base;
            final List list = data['data'];
            return list.map((item) => Product.fromJson(item)).toList();
          }
        }
      } catch (e) {
        debugPrint('ApiService.fetchShopifyProducts failed for $base: $e');
      }
    }
    return [];
  }

  /// Sync products from a Shopify store into the Laravel database.
  static Future<List<Product>> syncShopifyProducts(String domain) async {
    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/shopify/sync');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'domain': domain}),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] != null && data['data'] is List) {
            _customBaseUrl = base;
            final List list = data['data'];
            return list.map((item) => Product.fromJson(item)).toList();
          }
        }
      } catch (e) {
        debugPrint('ApiService.syncShopifyProducts failed for $base: $e');
      }
    }
    return [];
  }

  /// Authenticate or register customer account via Shopify backend proxy.
  static Future<Map<String, dynamic>> authenticateShopifyCustomer({
    required String email,
    String? password,
    String? firstName,
    String? lastName,
    String? phone,
    String? domain,
    bool isSignUp = false,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'action': isSignUp ? 'register' : 'login',
      'is_sign_up': isSignUp,
      if (password != null && password.isNotEmpty) 'password': password,
      if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
      if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (domain != null && domain.isNotEmpty) 'domain': domain,
    };

    String? lastErrorMessage;

    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/shopify/customer/auth');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 &&
            data['status'] == 'success' &&
            data['data'] != null &&
            data['data'] is Map<String, dynamic>) {
          _customBaseUrl = base;
          return {'success': true, 'data': Map<String, dynamic>.from(data['data'])};
        } else if (data['message'] != null) {
          lastErrorMessage = data['message'].toString();
          return {'success': false, 'message': lastErrorMessage};
        }
      } catch (e) {
        debugPrint('ApiService.authenticateShopifyCustomer failed for $base: $e');
      }
    }
    return {
      'success': false,
      'message': lastErrorMessage ?? 'Unable to connect to backend server. Please check your network connection.',
    };
  }

  /// Update customer shipping address on Shopify via Laravel backend.
  static Future<Map<String, dynamic>?> updateShopifyCustomerAddress({
    required String email,
    required Map<String, dynamic> addressData,
    String? domain,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      ...addressData,
      if (domain != null && domain.isNotEmpty) 'domain': domain,
    };

    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/shopify/customer/update-address');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['data'] != null && data['data'] is Map<String, dynamic>) {
            _customBaseUrl = base;
            return data['data'];
          }
        }
      } catch (e) {
        debugPrint('ApiService.updateShopifyCustomerAddress failed for $base: $e');
      }
    }
    return null;
  }

  /// Create an order on Shopify via Laravel backend.
  static Future<Map<String, dynamic>> createShopifyOrder({
    required String email,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    String paymentMethod = 'Cash on Delivery',
    String deliveryMethod = 'Shipping',
    String? domain,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'items': items,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'delivery_method': deliveryMethod,
      if (domain != null && domain.isNotEmpty) 'domain': domain,
    };

    String? lastErrorMessage;

    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/shopify/order/create');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 15));

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['success'] == true) {
          _customBaseUrl = base;
          return Map<String, dynamic>.from(data);
        } else if (data['message'] != null) {
          lastErrorMessage = data['message'].toString();
          return {'success': false, 'message': lastErrorMessage};
        }
      } catch (e) {
        debugPrint('ApiService.createShopifyOrder failed for $base: $e');
      }
    }
    return {
      'success': false,
      'message': lastErrorMessage ?? 'Unable to connect to backend server to place order.',
    };
  }

  /// Cancel an order on Shopify via Laravel backend.
  static Future<Map<String, dynamic>> cancelShopifyOrder({
    required String orderId,
    required String email,
    String? domain,
  }) async {
    final payload = <String, dynamic>{
      'order_id': orderId,
      'email': email,
      if (domain != null && domain.isNotEmpty) 'domain': domain,
    };

    String? lastErrorMessage;

    for (final base in _candidateUrls) {
      try {
        final uri = Uri.parse('$base/shopify/order/cancel');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 10));

        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['success'] == true) {
          _customBaseUrl = base;
          return Map<String, dynamic>.from(data);
        } else if (data['message'] != null) {
          lastErrorMessage = data['message'].toString();
          return {'success': false, 'message': lastErrorMessage};
        }
      } catch (e) {
        debugPrint('ApiService.cancelShopifyOrder failed for $base: $e');
      }
    }
    return {
      'success': false,
      'message': lastErrorMessage ?? 'Order marked as cancelled locally.',
    };
  }
}
