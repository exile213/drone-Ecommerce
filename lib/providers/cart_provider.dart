import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _cartItems = [];
  double _total = 0.0;
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  double get total => _total;
  bool get isLoading => _isLoading;
  int get itemCount => _cartItems.length;

  // Load cart
  Future<void> loadCart(int userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await CartService.getCartByUser(userId);

    if (result['success']) {
      _cartItems = result['cartItems'] as List<CartItemModel>;
      _total = result['total'] as double;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add to cart
  Future<bool> addToCart(int userId, int productId, int quantity) async {
    final result = await CartService.addToCart(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );

    if (result['success']) {
      await loadCart(userId);
      return true;
    }
    return false;
  }

  // Update cart item
  Future<bool> updateCartItem(int id, int quantity) async {
    final result = await CartService.updateCartItem(id: id, quantity: quantity);
    if (result['success']) {
      // Reload cart to get updated data
      // Note: We'd need userId here, but for simplicity, just update locally
      final item = _cartItems.firstWhere((item) => item.id == id);
      final index = _cartItems.indexOf(item);
      _cartItems[index] = item.copyWith(quantity: quantity);
      _calculateTotal();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Remove from cart
  Future<bool> removeFromCart(int id) async {
    final result = await CartService.removeFromCart(id);
    if (result['success']) {
      _cartItems.removeWhere((item) => item.id == id);
      _calculateTotal();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Clear cart
  void clearCart() {
    _cartItems = [];
    _total = 0.0;
    notifyListeners();
  }

  // Calculate total
  void _calculateTotal() {
    _total = _cartItems.fold(0.0, (sum, item) => sum + (item.itemTotal ?? 0.0));
  }
}

