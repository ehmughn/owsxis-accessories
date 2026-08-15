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
