import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    fetchProductsFromBackend();
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
    _currentCustomerIndex = index;
    notifyListeners();
  }

  // Auth & Profile State
  bool _isLoggedIn = true;
  String _userName = 'Alex Vance';
  String _userEmail = 'alex@stickercollector.io';
  String _userPhone = '+1 555-0198';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  void login({String? name, String? email}) {
    _isLoggedIn = true;
    if (name != null && name.isNotEmpty) _userName = name;
    if (email != null && email.isNotEmpty) _userEmail = email;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String phone}) {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
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
          p.category.toLowerCase().contains(_selectedCategory.toLowerCase());
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Wishlist
  final Set<String> _wishlistProductIds = {'p1', 'p2', 'p4'};

  Set<String> get wishlistProductIds => Set.unmodifiable(_wishlistProductIds);

  List<Product> get wishlistProducts {
    return _products.where((p) => _wishlistProductIds.contains(p.id)).toList();
  }

  void toggleWishlist(String productId) {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
    } else {
      _wishlistProductIds.add(productId);
    }
    notifyListeners();
  }

  bool isWishlisted(String productId) => _wishlistProductIds.contains(productId);

  // Stitch Scrapbook Cart Items
  final List<CartItem> _cartItems = [
    CartItem(
      product: const Product(
        id: 'p8',
        title: 'Neon Sleeze Tee',
        description: 'Faded black, oversized fit, distressed print.',
        price: 45.00,
        category: 'Apparel',
        tag: 'Apparel',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAOUZEA3XJ4qxo0B7ZxWRiIcQTGu49Mdx6cyWdMzf62sJkOux2orbN9JqNU-LvgIWtQXbqJ_ij8Q2G261Ly6Z7KNwrK3GyKv7XUi7pMbWdXHtJ1pLATj6abUuxzYDRjJjTz5O_WQNOe7wFi4Pmf5i4cVenUH1CBX-XM1cxhwxWWysKQoUD5uY6UXehjgr-o0O6RjA30dWB-VRmSv5YArgcBbyb7dRDlvDClygSXQ6khShfi0_Y2d5J4',
      ),
      quantity: 1,
      selectedVariant: 'Size: L',
    ),
    CartItem(
      product: const Product(
        id: 'p9',
        title: 'Padlock Chain',
        description: 'Heavy stainless steel, industrial clasp.',
        price: 85.00,
        category: 'Accessories',
        tag: 'Accessories',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCU5I2likToMSg83qGYlJpCC5Rvjv8SZFKpULN4bxz8HoPHPBUz1Oa6ngbRmhxiLM384jllHUrMzaW_pK3IAdbEEXGbCw9a9WxfpLXZx_t_d0WUxK0bKU3BMGQNJn-D4ahNH8V_ljnmx_bR9lB9JNAlvrjWbwE7RfTJkVgawOhj6sAyw_jFR5AjJG321rHxNmf5izxjRleiORaZxgNTZjsqTkFb2G4TG4-d5lBuRvS5XJbz3oLcmn9G',
      ),
      quantity: 1,
      selectedVariant: 'OS',
    ),
    CartItem(
      product: const Product(
        id: 'p10',
        title: 'Remix Sticker Pack',
        description: 'Holographic finish, 12 unique designs.',
        price: 15.00,
        category: 'Collectibles',
        tag: 'Collectibles',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCjIKk84q9GKCp4xn4EZ14pBjqMT7AI9PESLXaE2CygRTPJhAlIasvDUrJrFesk1p7tXe8dzd8Zlemak_gSqtaM9uhPki_-kPBCXdWkBk9bJPZwnUrv2YT0x9E5VlV7JdgtzfFD0YHeTqVwU4tkEH26s-hNKH2oikavhl7VzPo3frkFzqlFd77q9zSonSVmtRBFDzEdofy2eKVje87TPFp19NMAAsEfucJW_6zGkbF4UIRdfMQpWYfP',
      ),
      quantity: 2,
      selectedVariant: 'Pack',
    ),
  ];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  String? _appliedPromoCode;
  double _discountPercent = 0.0;

  String? get appliedPromoCode => _appliedPromoCode;

  void addToCart(Product product, {String variant = 'Standard', int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id && item.selectedVariant == variant,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        selectedVariant: variant,
      ));
    }
    notifyListeners();
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

  // Stitch Order Models
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'OW-9021',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.shipped,
      items: [
        CartItem(
          product: const Product(
            id: 'p_bead',
            title: 'Custom Blue Beaded Keychain',
            description: '',
            price: 24.00,
            category: 'Accessories',
            tag: '',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuChksUQNXwz-dIEcpwjFmhwBthA7k9dAYePHT1LZILinos_KNaT2E_WlBj8zeE0wDnJHnWXpKL8SRUKKurOett7PuVn5TLTduO7AV2xGIUKGfUTbNIQokHJTgYIc_yr17o1r-HG-udCzml2Pi3fj9KqTkXiLZA3QOqq3kvPY4039oqITNYIeM5p7tGlfR9W_LNvImgJi46Dh5baPgVnUEBLB6SPS90TrmqwcNtTCFXuFUwQavEkKps0',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 24.00,
      shippingFee: 5.00,
      total: 30.92,
      shippingAddress: '104 Retro Pop Ave, Studio 4B, New York, NY',
      trackingNumber: 'OWX-99482710-US',
    ),
    OrderModel(
      id: 'OW-8711',
      date: DateTime.now().subtract(const Duration(days: 30)),
      status: OrderStatus.delivered,
      items: [
        CartItem(
          product: const Product(
            id: 'p8',
            title: 'Oversized Graphic Tee',
            description: '',
            price: 45.00,
            category: 'Apparel',
            tag: '',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAl4-gHHNaz2kX9azm-BsDUSwC0Di-JuCGe2R-6zOhV55ljce4epqUe9USzXLAoeM1bbHBIYIa2JVPiHJYAKjiRwc7is8JHiZ9jBZierOuV9OQKIRMVVWm21JcViL1qm2fN79icmzwOHKqdissn48aWxJzB4v7SlAE6rWCP_JexdXeU0oCvfwgrzm0q7oXhT-0rCP0oqYiBHL_mmD6oRVpscV25YJOS2Si3SCAXl8ZGydesk4QKl3wQ',
          ),
          quantity: 1,
        ),
      ],
      subtotal: 45.00,
      shippingFee: 0.0,
      total: 45.00,
      shippingAddress: '104 Retro Pop Ave, Studio 4B, New York, NY',
      trackingNumber: 'OWX-77218394-US',
    ),
  ];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  OrderModel? get selectedOrder => _orders.firstWhere((o) => o.id == 'OW-9021', orElse: () => _orders.first);

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


}
