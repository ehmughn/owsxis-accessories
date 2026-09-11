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
    this.variants = const ['Standard', 'Holographic', 'Die-Cut'],
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
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedVariants = ['Standard'];
    if (json['variants'] != null) {
      if (json['variants'] is List) {
        parsedVariants = (json['variants'] as List).map((v) => v.toString()).toList();
      } else if (json['variants'] is String) {
        parsedVariants = [json['variants'].toString()];
      }
    }

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
    };
  }
}

class CartItem {
  final Product product;
  int quantity;
  String selectedVariant;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedVariant = 'Standard',
  });

  double get totalPrice => product.price * quantity;
}

enum OrderStatus { pending, processing, shipped, delivered }

class OrderModel {
  final String id;
  final DateTime date;
  final OrderStatus status;
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
