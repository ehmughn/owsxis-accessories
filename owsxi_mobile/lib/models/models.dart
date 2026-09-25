class ProductOption {
  final String name;
  final List<String> values;

  const ProductOption({
    required this.name,
    required this.values,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    List<String> vals = [];
    if (json['values'] is List) {
      vals = (json['values'] as List).map((v) {
        final s = v.toString();
        return s == 'Default Title' ? 'Default Variant' : s;
      }).toList();
    }
    final rawName = json['name']?.toString() ?? 'Option';
    final name = rawName == 'Title' ? 'Variant' : rawName;
    return ProductOption(
      name: name,
      values: vals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'values': values,
    };
  }
}

class ProductVariant {
  final String id;
  final String variantId;
  final String title;
  final double price;
  final int inventoryQuantity;
  final String imageUrl;
  final Map<String, String> selectedOptions;

  const ProductVariant({
    required this.id,
    required this.variantId,
    required this.title,
    required this.price,
    this.inventoryQuantity = 10,
    this.imageUrl = '',
    this.selectedOptions = const {},
  });

  bool get isAvailable => inventoryQuantity > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    Map<String, String> sOpts = {};
    if (json['selected_options'] != null && json['selected_options'] is Map) {
      json['selected_options'].forEach((k, v) {
        final keyStr = k.toString() == 'Title' ? 'Variant' : k.toString();
        final valStr = v.toString() == 'Default Title' ? 'Default Variant' : v.toString();
        sOpts[keyStr] = valStr;
      });
    }

    final rawTitle = json['title']?.toString() ?? 'Standard';
    final title = rawTitle == 'Default Title' ? 'Default Variant' : rawTitle;

    return ProductVariant(
      id: json['id']?.toString() ?? '',
      variantId: json['variant_id']?.toString() ?? json['id']?.toString() ?? '',
      title: title,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      inventoryQuantity: (json['inventory_quantity'] as num?)?.toInt() ?? (json['inventoryQuantity'] as num?)?.toInt() ?? 10,
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      selectedOptions: sOpts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant_id': variantId,
      'title': title,
      'price': price,
      'inventory_quantity': inventoryQuantity,
      'image_url': imageUrl,
      'selected_options': selectedOptions,
    };
  }
}

class ProductMetafield {
  final String namespace;
  final String key;
  final String value;
  final String type;

  const ProductMetafield({
    required this.namespace,
    required this.key,
    required this.value,
    this.type = 'single_line_text_field',
  });

  String get label {
    final cleanKey = key.replaceAll('_', ' ').trim();
    if (cleanKey.isEmpty) return 'Details';
    return cleanKey
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  factory ProductMetafield.fromJson(Map<String, dynamic> json) {
    return ProductMetafield(
      namespace: json['namespace']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      type: json['type']?.toString() ?? 'single_line_text_field',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namespace': namespace,
      'key': key,
      'value': value,
      'type': type,
    };
  }
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String tag;
  final String imageUrl;
  final bool inStock;
  final int stockQuantity;
  final double rating;
  final List<String> variants;
  final List<ProductVariant> productVariants;
  final List<ProductOption> options;
  final List<ProductMetafield> metafields;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.tag,
    required this.imageUrl,
    this.inStock = true,
    this.stockQuantity = 25,
    this.rating = 4.9,
    this.variants = const ['Standard'],
    this.productVariants = const [],
    this.options = const [],
    this.metafields = const [],
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? tag,
    String? imageUrl,
    bool? inStock,
    int? stockQuantity,
    double? rating,
    List<String>? variants,
    List<ProductVariant>? productVariants,
    List<ProductOption>? options,
    List<ProductMetafield>? metafields,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      tag: tag ?? this.tag,
      imageUrl: imageUrl ?? this.imageUrl,
      inStock: inStock ?? this.inStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      variants: variants ?? this.variants,
      productVariants: productVariants ?? this.productVariants,
      options: options ?? this.options,
      metafields: metafields ?? this.metafields,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedVariants = ['Standard'];
    List<ProductVariant> parsedProductVariants = [];
    List<ProductOption> parsedOptions = [];
    List<ProductMetafield> parsedMetafields = [];

    if (json['options'] != null && json['options'] is List) {
      final List optList = json['options'];
      parsedOptions = optList
          .map((o) => ProductOption.fromJson(Map<String, dynamic>.from(o)))
          .toList();
    }

    if (json['metafields'] != null && json['metafields'] is List) {
      final List mList = json['metafields'];
      parsedMetafields = mList
          .map((m) => ProductMetafield.fromJson(Map<String, dynamic>.from(m)))
          .where((m) => m.namespace.isEmpty || m.namespace.toLowerCase() == 'custom')
          .toList();
    }

    if (json['variant_objects'] != null && json['variant_objects'] is List) {
      final List vList = json['variant_objects'];
      parsedProductVariants = vList
          .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v)))
          .toList();
    }

    if (json['variants'] != null) {
      if (json['variants'] is List) {
        final List vList = json['variants'];
        if (vList.isNotEmpty && vList.first is Map) {
          parsedProductVariants = vList
              .map((v) => ProductVariant.fromJson(Map<String, dynamic>.from(v)))
              .toList();
          parsedVariants = parsedProductVariants.map((v) => v.title).toList();
        } else {
          parsedVariants = vList.map((v) => v.toString()).toList();
        }
      } else if (json['variants'] is String) {
        parsedVariants = [json['variants'].toString()];
      }
    }

    if (parsedVariants.isEmpty && parsedProductVariants.isNotEmpty) {
      parsedVariants = parsedProductVariants.map((v) => v.title).toList();
    }

    parsedVariants = parsedVariants
        .map((v) => v == 'Default Title' ? 'Default Variant' : v)
        .toList();

    return Product(
      id: json['id']?.toString() ?? json['shopify_id']?.toString() ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Untitled Product',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? 'General',
      tag: json['tag']?.toString() ?? 'Featured',
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=500',
      inStock: json['in_stock'] ?? json['inStock'] ?? true,
      stockQuantity: (json['stock_quantity'] ?? json['stockQuantity'] as num?)?.toInt() ?? 25,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      variants: parsedVariants,
      productVariants: parsedProductVariants,
      options: parsedOptions,
      metafields: parsedMetafields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'tag': tag,
      'image_url': imageUrl,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'rating': rating,
      'variants': variants,
      'variant_objects': productVariants.map((v) => v.toJson()).toList(),
      'options': options.map((o) => o.toJson()).toList(),
      'metafields': metafields.map((m) => m.toJson()).toList(),
    };
  }
}

class CartItem {
  final Product product;
  int quantity;
  String selectedVariant;
  String? selectedVariantId;
  double? variantPrice;
  String? variantImageUrl;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedVariant = 'Standard',
    this.selectedVariantId,
    this.variantPrice,
    this.variantImageUrl,
  });

  double get unitPrice => variantPrice ?? product.price;
  double get totalPrice => unitPrice * quantity;
}

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final String paymentStatus;
  final String estimatedDelivery;
  final List<CartItem> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String shippingAddress;
  final String trackingNumber;

  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    this.paymentStatus = 'Paid',
    this.estimatedDelivery = '3-5 Business Days',
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.shippingAddress,
    required this.trackingNumber,
  });

  String get statusName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int totalOrders;
  final double totalSpent;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.totalOrders,
    required this.totalSpent,
  });
}
