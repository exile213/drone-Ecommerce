import '../models/order_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class OrderService {
  // Create order from cart
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required String deliveryDate,
    required String deliveryTime,
    required String deliveryAddress,
  }) async {
    final response = await ApiService.post(
      ApiConstants.orders,
      {
        'user_id': userId,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
        'delivery_address': deliveryAddress,
      },
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to create order',
      'order_id': response['order_id'],
      'total_amount': response['total_amount'],
    };
  }

  // Get orders by user ID
  static Future<Map<String, dynamic>> getOrdersByUser(int userId) async {
    final response = await ApiService.get(
      '${ApiConstants.ordersByUser}&user_id=$userId',
    );

    if (response['success'] == true && response['orders'] != null) {
      return {
        'success': true,
        'orders': (response['orders'] as List)
            .map((item) => OrderModel.fromJson(item))
            .toList(),
        'count': response['count'] ?? 0,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to fetch orders',
      'orders': <OrderModel>[],
    };
  }

  // Get orders by seller ID
  static Future<Map<String, dynamic>> getOrdersBySeller(int sellerId) async {
    final response = await ApiService.get(
      '${ApiConstants.ordersBySeller}&seller_id=$sellerId',
    );

    if (response['success'] == true && response['orders'] != null) {
      return {
        'success': true,
        'orders': (response['orders'] as List)
            .map((item) => OrderModel.fromJson(item))
            .toList(),
        'count': response['count'] ?? 0,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to fetch orders',
      'orders': <OrderModel>[],
    };
  }

  // Get order by ID
  static Future<Map<String, dynamic>> getOrderById(int id) async {
    final response = await ApiService.get('${ApiConstants.orders}?id=$id');

    if (response['success'] == true && response['order'] != null) {
      return {
        'success': true,
        'order': OrderModel.fromJson(response['order']),
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Order not found',
    };
  }

  // Update order status
  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await ApiService.put(
      ApiConstants.updateOrderStatus,
      {
        'order_id': orderId,
        'status': status,
      },
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to update order status',
      'status': response['status'],
    };
  }
}

