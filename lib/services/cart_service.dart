import '../models/cart_item_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CartService {
  // Get cart by user ID
  static Future<Map<String, dynamic>> getCartByUser(int userId) async {
    final response = await ApiService.get(
      '${ApiConstants.cartByUser}&user_id=$userId',
    );

    if (response['success'] == true && response['cart_items'] != null) {
      return {
        'success': true,
        'cartItems': (response['cart_items'] as List)
            .map((item) => CartItemModel.fromJson(item))
            .toList(),
        'total': response['total'] ?? 0.0,
        'count': response['count'] ?? 0,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to fetch cart',
      'cartItems': <CartItemModel>[],
      'total': 0.0,
    };
  }

  // Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await ApiService.post(
      ApiConstants.cart,
      {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      },
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to add item to cart',
      'cart_item_id': response['cart_item_id'],
    };
  }

  // Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItem({
    required int id,
    required int quantity,
  }) async {
    final response = await ApiService.put(
      ApiConstants.cart,
      {
        'id': id,
        'quantity': quantity,
      },
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to update cart item',
    };
  }

  // Remove item from cart
  static Future<Map<String, dynamic>> removeFromCart(int id) async {
    final response = await ApiService.delete('${ApiConstants.cart}?id=$id');

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to remove item from cart',
    };
  }
}

