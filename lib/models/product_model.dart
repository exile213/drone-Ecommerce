class ProductModel {
  final int? id;
  final int sellerId;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final String category;
  final String? imageUrl;
  final String? sellerName;
  final String? sellerEmail;
  final String? createdAt;
  final String? updatedAt;

  ProductModel({
    this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    required this.category,
    this.imageUrl,
    this.sellerName,
    this.sellerEmail,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int?,
      sellerId: int.parse(json['seller_id'].toString()),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      stockQuantity: int.parse(json['stock_quantity'].toString()),
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      sellerName: json['seller_name'] as String?,
      sellerEmail: json['seller_email'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category': category,
      'image_url': imageUrl,
    };
  }

  // Copy with method for updates
  ProductModel copyWith({
    int? id,
    int? sellerId,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? category,
    String? imageUrl,
    String? sellerName,
    String? sellerEmail,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isInStock => stockQuantity > 0;
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

