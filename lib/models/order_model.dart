class OrderModel {
  final int? id;
  final int userId;
  final double totalAmount;
  final String deliveryDate;
  final String deliveryTime;
  final String deliveryAddress;
  final String status;
  final String? buyerName;
  final String? buyerEmail;
  final String? createdAt;
  final String? updatedAt;
  final List<OrderItemModel>? items;

  OrderModel({
    this.id,
    required this.userId,
    required this.totalAmount,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.deliveryAddress,
    required this.status,
    this.buyerName,
    this.buyerEmail,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  // Convert from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      userId: int.parse(json['user_id'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      deliveryDate: json['delivery_date'] as String,
      deliveryTime: json['delivery_time'] as String,
      deliveryAddress: json['delivery_address'] as String,
      status: json['status'] as String,
      buyerName: json['buyer_name'] as String?,
      buyerEmail: json['buyer_email'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => OrderItemModel.fromJson(item))
                .toList()
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_amount': totalAmount,
      'delivery_date': deliveryDate,
      'delivery_time': deliveryTime,
      'delivery_address': deliveryAddress,
      'status': status,
    };
  }

  // Copy with method for updates
  OrderModel copyWith({
    int? id,
    int? userId,
    double? totalAmount,
    String? deliveryDate,
    String? deliveryTime,
    String? deliveryAddress,
    String? status,
    String? buyerName,
    String? buyerEmail,
    String? createdAt,
    String? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  String get formattedTotal => '₱${totalAmount.toStringAsFixed(2)}';
  bool get isPending => status == 'pending';
  bool get isShipped => status == 'shipped';
  bool get isCompleted => status == 'completed';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'shipped':
        return 'Shipped';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}

class OrderItemModel {
  final int? id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final String? productName;
  final String? imageUrl;
  final String? createdAt;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.imageUrl,
    this.createdAt,
  });

  // Convert from JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int?,
      orderId: int.parse(json['order_id'].toString()),
      productId: int.parse(json['product_id'].toString()),
      quantity: int.parse(json['quantity'].toString()),
      price: double.parse(json['price'].toString()),
      productName: json['product_name'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  String get formattedPrice => '₱${price.toStringAsFixed(2)}';
  double get itemTotal => price * quantity;
  String get formattedTotal => '₱${itemTotal.toStringAsFixed(2)}';
}
