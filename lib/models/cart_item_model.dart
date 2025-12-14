class CartItemModel {
  final int? id;
  final int userId;
  final int productId;
  final int quantity;
  final String? productName;
  final double? price;
  final String? imageUrl;
  final int? stockQuantity;
  final double? itemTotal;
  final String? createdAt;

  CartItemModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.price,
    this.imageUrl,
    this.stockQuantity,
    this.itemTotal,
    this.createdAt,
  });

  // Convert from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int?,
      userId: int.parse(json['user_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      quantity: int.parse(json['quantity'].toString()),
      productName: json['name'] as String?,
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : null,
      imageUrl: json['image_url'] as String?,
      stockQuantity: json['stock_quantity'] != null
          ? int.parse(json['stock_quantity'].toString())
          : null,
      itemTotal: json['item_total'] != null
          ? double.parse(json['item_total'].toString())
          : null,
      createdAt: json['created_at'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'product_id': productId, 'quantity': quantity};
  }

  // Copy with method for updates
  CartItemModel copyWith({
    int? id,
    int? userId,
    int? productId,
    int? quantity,
    String? productName,
    double? price,
    String? imageUrl,
    int? stockQuantity,
    double? itemTotal,
    String? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      itemTotal: itemTotal ?? this.itemTotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedPrice =>
      price != null ? '₱${price!.toStringAsFixed(2)}' : '';
  String get formattedTotal =>
      itemTotal != null ? '₱${itemTotal!.toStringAsFixed(2)}' : '';
  bool get isAvailable => stockQuantity != null && stockQuantity! >= quantity;
}
