import 'package:flutter/material.dart';

class ApiConstants {
  // Laragon API Base URL
  // Note: ApiService.getBaseUrl() handles platform-specific URLs automatically
  // For Android Emulator: automatically uses 10.0.2.2
  // For iOS Simulator: automatically uses localhost
  // For Physical Device: you may need to manually set your computer's IP address
  // Example for physical device: 'http://192.168.1.xxx/ecommercephp-api'
  static const String baseUrl = 'http://localhost/ecommercephp-api';

  // API Endpoints
  static const String authRegister = '/controllers/auth.php?action=register';
  static const String authLogin = '/controllers/auth.php?action=login';
  static const String authUser = '/controllers/auth.php?action=getUser';

  static const String products = '/controllers/products.php';
  static const String productsBySeller =
      '/controllers/products.php?action=bySeller';

  static const String cart = '/controllers/cart.php';
  static const String cartByUser = '/controllers/cart.php?action=byUser';

  static const String orders = '/controllers/orders.php';
  static const String ordersByUser = '/controllers/orders.php?action=byUser';
  static const String ordersBySeller =
      '/controllers/orders.php?action=bySeller';
  static const String updateOrderStatus =
      '/controllers/orders.php?action=updateStatus';
}

class AppConstants {
  // Image upload endpoint (stored on Laragon server)
  static const String imageUploadPath = '/controllers/upload.php';
  // Note: Image URLs are constructed using ApiService.getBaseUrl() + '/uploads/'
  // This ensures platform-specific URLs are used automatically
  static const String imageBaseUrl =
      'http://localhost/ecommercephp-api/uploads/';

  // User Roles
  // Note: The role system works as follows:
  // - 'admin': Full admin dashboard access, can manage all products, orders, and users
  // - 'user': Hybrid role - can act as BOTH buyer (browse, add to cart, checkout)
  //   AND seller (add/edit/delete products, view incoming orders)
  //   This is more realistic as users can both buy and sell products in the marketplace
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusCompleted = 'completed';

  // Product Categories (Drone-themed)
  static const List<String> productCategories = [
    'Drone',
    'Drone Parts',
    'Accessories',
    'Batteries',
    'Controllers',
    'Propellers',
    'Camera Equipment',
  ];

  // Admin Color Scheme
  static const Color adminPrimary = Color(0xFF7c3aed); // violet-600
  static const Color adminSecondary = Color(0xFFa855f7); // violet-500
  static const Color adminLight = Color(0xFFede9fe); // violet-50
  static const Color adminDark = Color(0xFF6d28d9); // violet-700
}
