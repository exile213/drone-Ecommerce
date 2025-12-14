import '../models/product_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class ProductService {
  // Get all products
  static Future<Map<String, dynamic>> getAllProducts({
    String? category,
    String? search,
  }) async {
    String endpoint = ApiConstants.products;
    List<String> params = [];

    if (category != null && category.isNotEmpty) {
      params.add('category=$category');
    }
    if (search != null && search.isNotEmpty) {
      params.add('search=$search');
    }

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    final response = await ApiService.get(endpoint);

    if (response['success'] == true && response['products'] != null) {
      return {
        'success': true,
        'products': (response['products'] as List)
            .map((item) => ProductModel.fromJson(item))
            .toList(),
        'count': response['count'] ?? 0,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to fetch products',
      'products': <ProductModel>[],
    };
  }

  // Get product by ID
  static Future<Map<String, dynamic>> getProductById(int id) async {
    final response = await ApiService.get('${ApiConstants.products}?id=$id');

    if (response['success'] == true && response['product'] != null) {
      return {
        'success': true,
        'product': ProductModel.fromJson(response['product']),
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Product not found',
    };
  }

  // Get products by seller
  static Future<Map<String, dynamic>> getProductsBySeller(int sellerId) async {
    final response = await ApiService.get(
      '${ApiConstants.productsBySeller}&seller_id=$sellerId',
    );

    if (response['success'] == true && response['products'] != null) {
      return {
        'success': true,
        'products': (response['products'] as List)
            .map((item) => ProductModel.fromJson(item))
            .toList(),
        'count': response['count'] ?? 0,
      };
    }

    return {
      'success': false,
      'message': response['message'] ?? 'Failed to fetch products',
      'products': <ProductModel>[],
    };
  }

  // Create product
  static Future<Map<String, dynamic>> createProduct({
    required int sellerId,
    required String name,
    String? description,
    required double price,
    required int stockQuantity,
    required String category,
    String? imageUrl,
  }) async {
    final response = await ApiService.post(
      ApiConstants.products,
      {
        'seller_id': sellerId,
        'name': name,
        'description': description,
        'price': price,
        'stock_quantity': stockQuantity,
        'category': category,
        'image_url': imageUrl,
      },
    );

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to create product',
      'product_id': response['product_id'],
    };
  }

  // Update product
  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? category,
    String? imageUrl,
  }) async {
    final Map<String, dynamic> data = {'id': id};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
    if (category != null) data['category'] = category;
    if (imageUrl != null) data['image_url'] = imageUrl;

    final response = await ApiService.put(ApiConstants.products, data);

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to update product',
    };
  }

  // Delete product
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    final response = await ApiService.delete('${ApiConstants.products}?id=$id');

    return {
      'success': response['success'] == true,
      'message': response['message'] ?? 'Failed to delete product',
    };
  }
}

