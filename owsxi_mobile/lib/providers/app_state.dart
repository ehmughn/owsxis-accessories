import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    fetchProductsFromBackend();
    loadSavedSession();
  }

  // Backend & Shopify State
  bool _isLoadingProducts = false;
  String? _backendError;
  bool _isBackendConnected = false;
  String _currentShopDomain = 'owsxi.myshopify.com';

  bool get isLoadingProducts => _isLoadingProducts;
  String? get backendError => _backendError;
  bool get isBackendConnected => _isBackendConnected;
  String get currentShopDomain => _currentShopDomain;

  // Navigation State
  int _currentCustomerIndex = 0; // 0: Home, 1: Shop, 2: Cart, 3: Account

  int get currentCustomerIndex => _currentCustomerIndex;

  void setCustomerIndex(int index) {
    if (index < 0) {
      _currentCustomerIndex = 0;
    } else if (index > 3) {
      _currentCustomerIndex = 3;
    } else {
      _currentCustomerIndex = index;
    }
    notifyListeners();
  }

  // Auth & Profile State (Default unauthenticated guest mode)
  bool _isLoggedIn = false;
  String? _customerShopifyId;
  String? _authError;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  Map<String, String> _userAddress = {
    'address1': '',
    'address2': '',
    'city': '',
    'province': '',
    'zip': '',
    'country': 'Philippines',
  };
  List<OrderModel> _orders = [];

  bool get isLoggedIn => _isLoggedIn;
  String? get customerShopifyId => _customerShopifyId;
  String? get authError => _authError;
  String get userName => _userName.isNotEmpty ? _userName : 'Guest Customer';
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  Map<String, String> get userAddress => Map.unmodifiable(_userAddress);
  List<OrderModel> get orders {
    final list = List<OrderModel>.from(_orders);
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  String get formattedAddress {
    final parts = [
      _userAddress['address1'],
      _userAddress['address2'],
      _userAddress['city'],
      _userAddress['province'],
      _userAddress['zip'],
      _userAddress['country'],
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'No address set' : parts.join(', ');
  }

  /// Log in or register customer via Shopify backend proxy
  Future<bool> loginWithShopify({
    required String email,
    String? password,
    String? firstName,
    String? lastName,
    String? phone,
    bool isSignUp = false,
  }) async {
    _authError = null;
    notifyListeners();

    try {
      final res = await ApiService.authenticateShopifyCustomer(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        domain: _currentShopDomain,
        isSignUp: isSignUp,
      );

      if (res['success'] == true && res['data'] != null) {
        final customerData = res['data'] as Map<String, dynamic>;
        _isLoggedIn = true;
        _customerShopifyId = customerData['shopify_id']?.toString();
        _userEmail = customerData['email']?.toString() ?? email;
        _userName = customerData['name']?.toString() ??
            "${firstName ?? ''} ${lastName ?? ''}".trim();
        if (_userName.isEmpty) {
          _userName = _userEmail.split('@').first;
        }
        _userPhone = customerData['phone']?.toString() ?? phone ?? '';

        if (customerData['default_address'] != null &&
            customerData['default_address'] is Map) {
          final addr = Map<String, dynamic>.from(customerData['default_address']);
          _userAddress = {
            'address1': addr['address1']?.toString() ?? '',
            'address2': addr['address2']?.toString() ?? '',
            'city': addr['city']?.toString() ?? '',
            'province': addr['province']?.toString() ?? '',
            'zip': addr['zip']?.toString() ?? '',
            'country': addr['country']?.toString() ?? 'Philippines',
          };
        }

        // Parse orders from Shopify
        if (customerData['orders'] != null && customerData['orders'] is List) {
          final List rawOrders = customerData['orders'];
          _orders = rawOrders.map((o) {
            final List rawItems = o['items'] is List ? o['items'] : [];
            final itemsList = rawItems.map((i) {
              return CartItem(
                product: Product(
                  id: i['id']?.toString() ?? 'p_1',
                  title: i['title']?.toString() ?? 'Item',
                  description: i['description']?.toString() ?? '',
                  price: (i['price'] as num?)?.toDouble() ?? 0.0,
                  category: i['category']?.toString() ?? 'Accessories',
                  tag: '',
                  imageUrl: i['imageUrl']?.toString() ?? '',
                ),
                quantity: (i['quantity'] as num?)?.toInt() ?? 1,
                selectedVariant: i['selectedVariant']?.toString() ?? 'Standard',
              );
            }).toList();

            final statusStr = (o['status']?.toString() ?? '').toLowerCase();
            OrderStatus statusEnum = OrderStatus.delivered;
            if (statusStr.contains('unfulfilled') || statusStr.contains('pending')) {
              statusEnum = OrderStatus.pending;
            } else if (statusStr.contains('partial') || statusStr.contains('processing')) {
              statusEnum = OrderStatus.processing;
            } else if (statusStr.contains('shipped') || statusStr.contains('in_transit')) {
              statusEnum = OrderStatus.shipped;
            }

            return OrderModel(
              id: o['id']?.toString() ??
                  'ord_${DateTime.now().millisecondsSinceEpoch}',
              date: DateTime.tryParse(o['date']?.toString() ?? '') ??
                  DateTime.now(),
              status: statusEnum,
              paymentStatus: (o['payment_status']?.toString() ?? 'paid').toUpperCase(),
              estimatedDelivery: o['estimated_delivery']?.toString() ?? '3-5 Business Days',
              items: itemsList,
              subtotal: (o['subtotal'] as num?)?.toDouble() ?? (o['total'] as num?)?.toDouble() ?? 0.0,
              shippingFee: (o['shipping_fee'] as num?)?.toDouble() ?? 0.0,
              total: (o['total'] as num?)?.toDouble() ?? 0.0,
              shippingAddress: o['shipping_address']?.toString() ?? formattedAddress,
              trackingNumber: o['order_number']?.toString() ?? o['tracking_number']?.toString() ?? '#1001',
            );
          }).toList();
          _orders.sort((a, b) => b.date.compareTo(a.date));
        }

        await _saveSession();
        notifyListeners();
        return true;
      } else {
        _authError = res['message']?.toString() ?? 'Failed to authenticate customer account.';
      }
    } catch (e) {
      _authError = 'Customer auth error: $e';
    } finally {
      notifyListeners();
    }
    return false;
  }

  /// Session Persistence Methods
  Future<void> loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final savedEmail = prefs.getString('user_email');

      if (isLoggedIn && savedEmail != null && savedEmail.isNotEmpty) {
        _isLoggedIn = true;
        _userEmail = savedEmail;
        _userName = prefs.getString('user_name') ?? '';
        _userPhone = prefs.getString('user_phone') ?? '';
        _customerShopifyId = prefs.getString('customer_shopify_id');
        notifyListeners();

        // Refresh latest customer profile and orders from backend
        await loginWithShopify(email: savedEmail);
      }
    } catch (e) {
      debugPrint('Error loading saved session: $e');
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', _isLoggedIn);
      await prefs.setString('user_email', _userEmail);
      await prefs.setString('user_name', _userName);
      await prefs.setString('user_phone', _userPhone);
      if (_customerShopifyId != null) {
        await prefs.setString('customer_shopify_id', _customerShopifyId!);
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_phone');
      await prefs.remove('customer_shopify_id');
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  /// Update shipping address and sync to Shopify
  Future<bool> updateCustomerAddress({
    required String address1,
    String? address2,
    required String city,
    required String province,
    required String zip,
    String country = 'Philippines',
  }) async {
    _userAddress = {
      'address1': address1,
      'address2': address2 ?? '',
      'city': city,
      'province': province,
      'zip': zip,
      'country': country,
    };
    notifyListeners();

    if (_userEmail.isNotEmpty) {
      final updated = await ApiService.updateShopifyCustomerAddress(
        email: _userEmail,
        addressData: _userAddress,
        domain: _currentShopDomain,
      );
      return updated != null;
    }
    return true;
  }

  void login({String? name, String? email}) {
    _isLoggedIn = true;
    if (name != null && name.isNotEmpty) _userName = name;
    if (email != null && email.isNotEmpty) _userEmail = email;
    _saveSession();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _customerShopifyId = null;
    _userName = '';
    _userEmail = '';
    _userPhone = '';
    _userAddress = {
      'address1': '',
      'address2': '',
      'city': '',
      'province': '',
      'zip': '',
      'country': 'Philippines',
    };
    _orders = [];
    _cartItems.clear();
    _clearSession();
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String phone}) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    _saveSession();
    notifyListeners();
  }

  // Catalog Products
  List<Product> _products = [];


  List<Product> get products => List.unmodifiable(_products);

  /// Fetch products from Laravel backend
  Future<void> fetchProductsFromBackend({String? shopDomain, bool live = false}) async {
    _isLoadingProducts = true;
    _backendError = null;
    notifyListeners();

    try {
      final fetched = await ApiService.getProducts(shopDomain: shopDomain, live: live);
      if (fetched.isNotEmpty) {
        _products = fetched;
        _isBackendConnected = true;
        _backendError = null;
        if (shopDomain != null && shopDomain.isNotEmpty) {
          _currentShopDomain = shopDomain;
        }
      } else {
        _isBackendConnected = false;
        _backendError = 'Unable to fetch products from backend at ${ApiService.baseUrl}';
      }
    } catch (e) {
      _isBackendConnected = false;
      _backendError = 'Backend error: $e';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  /// Sync live Shopify products into backend database and view in mobile app
  Future<void> fetchShopifyStore(String domain) async {
    if (domain.isEmpty) return;
    _isLoadingProducts = true;
    _backendError = null;
    _currentShopDomain = domain;
    notifyListeners();

    try {
      final fetched = await ApiService.fetchShopifyProducts(domain);
      if (fetched.isNotEmpty) {
        _products = fetched;
        _isBackendConnected = true;
        _backendError = null;
      } else {
        // Fallback to sync
        final synced = await ApiService.syncShopifyProducts(domain);
        if (synced.isNotEmpty) {
          _products = synced;
          _isBackendConnected = true;
          _backendError = null;
        } else {
          _backendError = 'No products found or failed to load Shopify store "$domain" via backend';
        }
      }
    } catch (e) {
      _backendError = 'Shopify fetch error: $e';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  // Search & Filters
  String _searchQuery = '';
  String _selectedCategory = 'All';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get availableCategories {
    final categoriesSet = <String>{'All'};
    for (final p in _products) {
      final cat = p.category.trim();
      if (cat.isNotEmpty) {
        categoriesSet.add(cat);
      }
    }
    return categoriesSet.toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          p.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase() ||
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Cart Items
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  String? _appliedPromoCode;
  double _discountPercent = 0.0;

  String? get appliedPromoCode => _appliedPromoCode;

  bool addToCart(
    Product product, {
    String variant = 'Standard',
    int quantity = 1,
    ProductVariant? variantObj,
  }) {
    ProductVariant? targetVariant = variantObj;
    if (targetVariant == null && product.productVariants.isNotEmpty) {
      try {
        targetVariant = product.productVariants.firstWhere(
          (v) => v.title == variant ||
              v.title == (variant == 'Default Variant' ? 'Default Title' : variant) ||
              v.selectedOptions.containsValue(variant),
        );
      } catch (_) {
        targetVariant = product.productVariants.first;
      }
    }

    if (targetVariant != null) {
      if (targetVariant.inventoryQuantity <= 0) {
        return false;
      }
    } else {
      if (!product.inStock || product.stockQuantity <= 0) {
        return false;
      }
    }

    final vId = targetVariant?.variantId ?? targetVariant?.id;
    final vPrice = targetVariant?.price;
    final vImg = targetVariant?.imageUrl;

    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedVariant == variant,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
      if (vId != null && vId.isNotEmpty) {
        _cartItems[existingIndex].selectedVariantId = vId;
      }
      if (vPrice != null && vPrice > 0) {
        _cartItems[existingIndex].variantPrice = vPrice;
      }
      if (vImg != null && vImg.isNotEmpty) {
        _cartItems[existingIndex].variantImageUrl = vImg;
      }
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        selectedVariant: variant,
        selectedVariantId: vId,
        variantPrice: vPrice,
        variantImageUrl: vImg,
      ));
    }
    notifyListeners();
    return true;
  }

  void updateCartQuantity(int index, int delta) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity += delta;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  bool applyPromoCode(String code) {
    if (code.toUpperCase() == 'SCRAPBOOK20' || code.toUpperCase() == 'OWSXI10') {
      _appliedPromoCode = code.toUpperCase();
      _discountPercent = 0.15;
      notifyListeners();
      return true;
    }
    return false;
  }

  double get cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get cartDiscount {
    return cartSubtotal * _discountPercent;
  }

  double get cartTaxes => 14.40;

  double get cartShipping => 0.0;

  double get cartTotal => cartSubtotal - cartDiscount + cartTaxes;

  OrderModel? get selectedOrder =>
      _orders.isEmpty ? null : _orders.firstWhere((o) => o.id == 'OW-9021', orElse: () => _orders.first);

  void checkoutCurrentCart(String address) {
    if (_cartItems.isEmpty) return;

    final newOrder = OrderModel(
      id: 'OW-${1000 + _orders.length + 1}',
      date: DateTime.now(),
      status: OrderStatus.processing,
      items: List.from(_cartItems),
      subtotal: cartSubtotal,
      shippingFee: cartShipping,
      total: cartTotal,
      shippingAddress: address,
      trackingNumber: 'OWX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}-US',
    );

    _orders.insert(0, newOrder);
    _cartItems.clear();
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final old = _orders[index];
      _orders[index] = OrderModel(
        id: old.id,
        date: old.date,
        status: newStatus,
        items: old.items,
        subtotal: old.subtotal,
        shippingFee: old.shippingFee,
        total: old.total,
        shippingAddress: old.shippingAddress,
        trackingNumber: old.trackingNumber,
      );
      notifyListeners();
    }
  }

  /// Place order directly on Shopify via backend proxy
  Future<Map<String, dynamic>> placeShopifyOrder({
    required String name,
    required String address1,
    String? address2,
    required String city,
    required String province,
    required String zip,
    String country = 'Philippines',
    String paymentMethod = 'Cash on Delivery',
    String deliveryMethod = 'Shipping',
  }) async {
    if (_cartItems.isEmpty) {
      return {'success': false, 'message': 'Cart is empty.'};
    }

    final itemsPayload = _cartItems.map((item) {
      return {
        'id': item.product.id,
        'variant_id': item.selectedVariantId,
        'title': item.product.title,
        'price': item.unitPrice,
        'quantity': item.quantity,
        'selectedVariant': item.selectedVariant,
      };
    }).toList();

    final shippingAddressPayload = {
      'name': name,
      'address1': address1,
      'address2': address2 ?? '',
      'city': city,
      'province': province,
      'zip': zip,
      'country': country,
    };

    final result = await ApiService.createShopifyOrder(
      email: _userEmail,
      items: itemsPayload,
      shippingAddress: shippingAddressPayload,
      paymentMethod: paymentMethod,
      deliveryMethod: deliveryMethod,
      domain: _currentShopDomain,
    );

    if (result['success'] == true) {
      if (result['customer'] != null && result['customer'] is Map) {
        final cust = Map<String, dynamic>.from(result['customer']);
        if (cust['orders'] != null && cust['orders'] is List) {
          final List rawOrders = cust['orders'];
          _orders = rawOrders.map((o) {
            final List rawItems = o['items'] is List ? o['items'] : [];
            final itemsList = rawItems.map((i) {
              return CartItem(
                product: Product(
                  id: i['id']?.toString() ?? 'p_1',
                  title: i['title']?.toString() ?? 'Item',
                  description: i['description']?.toString() ?? '',
                  price: (i['price'] as num?)?.toDouble() ?? 0.0,
                  category: i['category']?.toString() ?? 'Accessories',
                  tag: '',
                  imageUrl: i['imageUrl']?.toString() ?? '',
                ),
                quantity: (i['quantity'] as num?)?.toInt() ?? 1,
                selectedVariant: i['selectedVariant']?.toString() ?? 'Standard',
              );
            }).toList();

            final statusStr = (o['status']?.toString() ?? '').toLowerCase();
            OrderStatus statusEnum = OrderStatus.delivered;
            if (statusStr.contains('unfulfilled') || statusStr.contains('pending')) {
              statusEnum = OrderStatus.pending;
            } else if (statusStr.contains('partial') || statusStr.contains('processing')) {
              statusEnum = OrderStatus.processing;
            } else if (statusStr.contains('shipped') || statusStr.contains('in_transit')) {
              statusEnum = OrderStatus.shipped;
            }

            return OrderModel(
              id: o['id']?.toString() ?? 'ord_${DateTime.now().millisecondsSinceEpoch}',
              date: DateTime.tryParse(o['date']?.toString() ?? '') ?? DateTime.now(),
              status: statusEnum,
              paymentStatus: (o['payment_status']?.toString() ?? 'paid').toUpperCase(),
              estimatedDelivery: o['estimated_delivery']?.toString() ?? '3-5 Business Days',
              items: itemsList,
              subtotal: (o['subtotal'] as num?)?.toDouble() ?? (o['total'] as num?)?.toDouble() ?? 0.0,
              shippingFee: (o['shipping_fee'] as num?)?.toDouble() ?? 0.0,
              total: (o['total'] as num?)?.toDouble() ?? 0.0,
              shippingAddress: o['shipping_address']?.toString() ?? '$address1, $city',
              trackingNumber: o['order_number']?.toString() ?? o['tracking_number']?.toString() ?? '#1001',
            );
          }).toList();
          _orders.sort((a, b) => b.date.compareTo(a.date));
        }
      } else {
        final fullAddress = '$address1, $city $zip';
        checkoutCurrentCart(fullAddress);
      }

      _cartItems.clear();
      notifyListeners();
    }

    return result;
  }

  /// Request cancellation for an order
  Future<Map<String, dynamic>> cancelShopifyOrder(String orderId) async {
    // Optimistically update status locally
    updateOrderStatus(orderId, OrderStatus.cancelled);

    final result = await ApiService.cancelShopifyOrder(
      orderId: orderId,
      email: _userEmail,
      domain: _currentShopDomain,
    );

    if (result['success'] == true && result['customer'] != null && result['customer'] is Map) {
      final cust = Map<String, dynamic>.from(result['customer']);
      if (cust['orders'] != null && cust['orders'] is List) {
        final List rawOrders = cust['orders'];
        _orders = rawOrders.map((o) {
          final List rawItems = o['items'] is List ? o['items'] : [];
          final itemsList = rawItems.map((i) {
            return CartItem(
              product: Product(
                id: i['id']?.toString() ?? 'p_1',
                title: i['title']?.toString() ?? 'Item',
                description: i['description']?.toString() ?? '',
                price: (i['price'] as num?)?.toDouble() ?? 0.0,
                category: i['category']?.toString() ?? 'Accessories',
                tag: '',
                imageUrl: i['imageUrl']?.toString() ?? '',
              ),
              quantity: (i['quantity'] as num?)?.toInt() ?? 1,
              selectedVariant: i['selectedVariant']?.toString() ?? 'Standard',
            );
          }).toList();

          final statusStr = (o['status']?.toString() ?? '').toLowerCase();
          OrderStatus statusEnum = OrderStatus.delivered;
          if (statusStr.contains('cancel')) {
            statusEnum = OrderStatus.cancelled;
          } else if (statusStr.contains('unfulfilled') || statusStr.contains('pending')) {
            statusEnum = OrderStatus.pending;
          } else if (statusStr.contains('partial') || statusStr.contains('processing')) {
            statusEnum = OrderStatus.processing;
          } else if (statusStr.contains('shipped') || statusStr.contains('in_transit')) {
            statusEnum = OrderStatus.shipped;
          }

          return OrderModel(
            id: o['id']?.toString() ?? 'ord_${DateTime.now().millisecondsSinceEpoch}',
            date: DateTime.tryParse(o['date']?.toString() ?? '') ?? DateTime.now(),
            status: statusEnum,
            paymentStatus: (o['payment_status']?.toString() ?? 'paid').toUpperCase(),
            estimatedDelivery: o['estimated_delivery']?.toString() ?? '3-5 Business Days',
            items: itemsList,
            subtotal: (o['subtotal'] as num?)?.toDouble() ?? (o['total'] as num?)?.toDouble() ?? 0.0,
            shippingFee: (o['shipping_fee'] as num?)?.toDouble() ?? 0.0,
            total: (o['total'] as num?)?.toDouble() ?? 0.0,
            shippingAddress: o['shipping_address']?.toString() ?? formattedAddress,
            trackingNumber: o['order_number']?.toString() ?? o['tracking_number']?.toString() ?? '#1001',
          );
        }).toList();
        _orders.sort((a, b) => b.date.compareTo(a.date));
      }
    }

    notifyListeners();
    return result;
  }
}
