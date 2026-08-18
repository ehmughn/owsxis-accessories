import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
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

  // Exact Stitch Design Catalog Products
  final List<Product> _products = [
    const Product(
      id: 'p1',
      title: 'Midnight Oracle Sticker Sheet',
      description: 'A detailed flat lay die-cut vinyl sticker sheet featuring mystical oracle and tarot card designs in a deep midnight blue and gold color palette.',
      price: 12.00,
      category: 'Sticker Sheet',
      tag: 'New',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAaUCVojpKm1Wc4MmX-cV8EzPqlWdHO3Yv-DVNVoTaQFw_g5j_J1UWuVecaLkMvNJEMaLYyR4oBZXYAPEv1mIIQhd7AExxgDitJcOmLQQkYDcynB-ml8_hTwGVYVPzQENH_fOrvEovR3SDYqQAaYtzei_w0_bzBD_f6VA7aeyWg9aFDZFZtcYEjykLmozCW8HJogjULfsIvz-oJV8TH_r6Rpvo-GfGIebpcjY8NgPz_my0_-ooQ7vKs',
      inStock: true,
      stockQuantity: 42,
      rating: 4.9,
      variants: ['Midnight Blue', 'Matte Gold', 'Clear Chrome'],
    ),
    const Product(
      id: 'p2',
      title: 'Sad Floppy Enamel Pin',
      description: 'Glossy enamel pin depicting a retro 90s floppy disk character crying, pastel pink and purple colors with sharp black outlines.',
      price: 10.00,
      category: 'Enamel Pin',
      tag: 'Featured',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCUFM4qRqFC_TZJeKTQwQwXnyCV1oIE3FIsO9aSKabURyd4PrpOsRlw4xYZ2wmGEZJJwpfC0A8FQ7E9yGPPlX9eNzrQacQgghUEx_27dW1XcV0xijMvHdMAoZS_MLppRkDKsOk4BnW6szl_7KSGIBMaYRM4kxk_4mjJ1c7cbX1kDUR6E3GlCpd9qSv5IJ2hwgcRPMVWG1yiSdMJ-SO0nJIchRt7KLu8QDeqpaSIte_F--ngrO4IVYym',
      inStock: true,
      stockQuantity: 18,
      rating: 4.8,
      variants: ['Pastel Pink', 'Retro Purple', 'Neon Chrome'],
    ),
    const Product(
      id: 'p3',
      title: 'WebSurfer99 Art Print',
      description: 'Stylized art print featuring a chaotic collage of 90s internet aesthetics, wireframe globes, and pixelated text in bright red and yellow.',
      price: 25.00,
      category: 'Art Print',
      tag: 'Hot',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCp0qgN3hBny3TPVFbO7gGAmejrSe3KwHRVeGQLZTMOODCvK8cHlFXLT4bRYOLIMt1aW0jvRSTpW_cChXB0qkmSIz24tAPXzcv7kmIaeQm7dCL5uUNLPAGDYRety9OFhKXnj2FaH3v7Ue2fGqA7NAc9gGpVufVvlpN77HV0H_QFC6Cm3zZyP9pdAF_SHEaEKZhLJDGalWB2Zn9QBt51e_lJaArk5vwQe08YtS-9dqcbnSH9c6_wHr3P',
      inStock: true,
      stockQuantity: 65,
      rating: 5.0,
      variants: ['A3 Poster', 'A4 Frame', 'Canvas Roll'],
    ),
    const Product(
      id: 'p4',
      title: 'Sad Hammy',
      description: 'Graphic vector illustration of a sad looking round hamster with teary eyes, thick dark navy outlines and flat pastel coloring.',
      price: 12.00,
      category: 'Enamel Pin',
      tag: 'Popular',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAdNguKsbcgtZO-M6Iuy4uQdlUcn9NKKTY59IZcPCsOYikVNszPE_P_ud5kiX1B8mB7fjAcQar79qEQ6qShae-DAd2NXHPI2hmDSXIqwZ2K3w-5ZF7SMejF1zrPv4NhkvZJ9-r5d2lx6iFi5fjm85zl19M9osR86hcgHeKh252Mkqwdq_zE6qAfhJoj_e4gTMSKIebPSxKUYUhHF5N3Yl3dA055CtmBwcc4fHZ_5f4KRB-7gOlZWPjH',
      inStock: true,
      stockQuantity: 30,
      rating: 4.7,
      variants: ['Standard Pin', 'Magnetic Back'],
    ),
    const Product(
      id: 'p5',
      title: 'Pixel Pack',
      description: 'Holographic stickers featuring pixel art cherries, smiley face, alien head, and star with heavy deep red hard shadows.',
      price: 8.00,
      category: 'Sticker Set',
      tag: 'Retro',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDROe5ErrwF4brRLhwG3-qCpOK-nc_8RS-wpMH03HbpQanpDZeP1OjRK0B4aNkvGcmF6zYkMIgTMn8HsXOCuwle9yWztjOKlUdbwwJXo3SmUqY2VwwzrWuQW33TWlpGJvTXytC-OeRSHFkHfY3Z41uB_Fw38lio4qXcrPzplnvx26KDtZVi_cneILaxlnRT-XASXAvTNR9-IELbwesr5Rf4aPM0FHvnhNtaf0NWmXZT_smwVapZuJb-',
      inStock: true,
      stockQuantity: 50,
      rating: 4.9,
      variants: ['4-Pack Set', '8-Pack Deluxe'],
    ),
    const Product(
      id: 'p6',
      title: 'Arcade',
      description: 'Acrylic keychain charm shaped like a retro arcade cabinet with vibrant red, yellow, and navy blue block colors and thick black outlines.',
      price: 10.00,
      category: 'Acrylic Charm',
      tag: '90s Arcade',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBgNaIqsvnXhSC2fmogcdeeT0-NR647lu-0_qqGa5zL8m4oy__7RCfyG9VDgXEOP4sdRz7BFYkk6w2P9LkIy_OkmnOrq0orHkSNDGZs8BfvhK1lypN5tuiMunezlG5vC7uX_DgZdLcCsTP4gZWw078mgUDULncBs9iHLwXOpxPAgDk2s5JWqMYwVzGQxowDPTjZLkHaYt8ReUwGYc6QHRFeGWWOk_jA4ACg8W6NHuKF4A6B7X5zM7EY',
      inStock: true,
      stockQuantity: 24,
      rating: 4.9,
      variants: ['Standard Chain', 'Carabiner Hook'],
    ),
    const Product(
      id: 'p7',
      title: 'Owsxi Core Logo Die-Cut',
      description: 'The original. Heavy-duty vinyl, weather-proof, and designed to withstand the apocalypse (or at least your water bottle). Stick it anywhere.',
      price: 4.00,
      category: 'Sticker Sheet',
      tag: 'Bestseller',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCcnwM1Bk3l-XchT6vPNA31i2CtadHQx4pb-IKNm3A-zfxoQJNXum5h2-HEmYHJNXtZEAPRigFu7JAcjL01UEJAaVG_lsil-CBl6hCOCk3DjHODabNnj5SHlxWwYIz2toNL3vi5KVgS6_b-bKWGJRSTZuUcWDC_Sesy_l897TJFtWBToF0TJ1tx8ho-V3twIPY7_bcsnLaMWhlcQbDtdERAf9Adq0xCsG7bXxc3Eopg_kFcRef17x4x',
      inStock: true,
      stockQuantity: 100,
      rating: 5.0,
      variants: ['Die-Cut Gloss', 'Matte Vinyl'],
    ),
    const Product(
      id: 'p8',
      title: 'Neon Sleeze Tee',
      description: 'Vintage graphic t-shirt with a bold, distressed typographic design reading "SLEAZE" in neon pink against a faded black background.',
      price: 45.00,
      category: 'Apparel',
      tag: 'Oversized',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAOUZEA3XJ4qxo0B7ZxWRiIcQTGu49Mdx6cyWdMzf62sJkOux2orbN9JqNU-LvgIWtQXbqJ_ij8Q2G261Ly6Z7KNwrK3GyKv7XUi7pMbWdXHtJ1pLATj6abUuxzYDRjJjTz5O_WQNOe7wFi4Pmf5i4cVenUH1CBX-XM1cxhwxWWysKQoUD5uY6UXehjgr-o0O6RjA30dWB-VRmSv5YArgcBbyb7dRDlvDClygSXQ6khShfi0_Y2d5J4',
      inStock: true,
      stockQuantity: 15,
      rating: 4.8,
      variants: ['Size: S', 'Size: M', 'Size: L', 'Size: XL'],
    ),
    const Product(
      id: 'p9',
      title: 'Padlock Chain',
      description: 'Chunky oversized silver chain necklace with a large, stylized padlock pendant in heavy stainless steel with an industrial clasp.',
      price: 85.00,
      category: 'Accessories',
      tag: 'Stainless',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCU5I2likToMSg83qGYlJpCC5Rvjv8SZFKpULN4bxz8HoPHPBUz1Oa6ngbRmhxiLM384jllHUrMzaW_pK3IAdbEEXGbCw9a9WxfpLXZx_t_d0WUxK0bKU3BMGQNJn-D4ahNH8V_ljnmx_bR9lB9JNAlvrjWbwE7RfTJkVgawOhj6sAyw_jFR5AjJG321rHxNmf5izxjRleiORaZxgNTZjsqTkFb2G4TG4-d5lBuRvS5XJbz3oLcmn9G',
      inStock: true,
      stockQuantity: 20,
      rating: 4.9,
      variants: ['OS Silver', 'OS Dark Chrome'],
    ),
    const Product(
      id: 'p10',
      title: 'Remix Sticker Pack',
      description: 'High-gloss vinyl stickers featuring retro-futuristic icons, floppy disk, geometric starburst, and bold typography spelling out "REMIX".',
      price: 15.00,
      category: 'Collectibles',
      tag: '12 Designs',
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCjIKk84q9GKCp4xn4EZ14pBjqMT7AI9PESLXaE2CygRTPJhAlIasvDUrJrFesk1p7tXe8dzd8Zlemak_gSqtaM9uhPki_-kPBCXdWkBk9bJPZwnUrv2YT0x9E5VlV7JdgtzfFD0YHeTqVwU4tkEH26s-hNKH2oikavhl7VzPo3frkFzqlFd77q9zSonSVmtRBFDzEdofy2eKVje87TPFp19NMAAsEfucJW_6zGkbF4UIRdfMQpWYfP',
      inStock: true,
      stockQuantity: 40,
      rating: 4.9,
      variants: ['Holographic', 'Glossy Vinyl'],
    ),
  ];

  List<Product> get products => List.unmodifiable(_products);

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
