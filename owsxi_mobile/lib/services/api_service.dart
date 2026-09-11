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
}
