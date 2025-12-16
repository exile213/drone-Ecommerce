import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/product_service.dart';
import '../../services/storage_service.dart';
import '../../utils/debug_logger.dart';
import '../../widgets/product_image_widget.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends StatefulWidget {
  final UserModel user;

  const ProductsListScreen({super.key, required this.user});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // #region agent log
    DebugLogger.log(
      location: 'products_list_screen.dart:27',
      message: '_loadProducts called',
      data: {'mounted': mounted, 'currentProductCount': _products.length},
      hypothesisId: 'B',
    );
    // #endregion
    setState(() => _isLoading = true);
    // #region agent log
    DebugLogger.log(
      location: 'products_list_screen.dart:31',
      message: 'setState isLoading=true called',
      data: {'mounted': mounted},
      hypothesisId: 'B',
    );
    // #endregion

    final result = await ProductService.getProductsBySeller(widget.user.id!);
    // #region agent log
    DebugLogger.log(
      location: 'products_list_screen.dart:36',
      message: 'API call completed',
      data: {
        'success': result['success'],
        'productCount': result['success']
            ? (result['products'] as List).length
            : 0,
        'mounted': mounted,
      },
      hypothesisId: 'C',
    );
    // #endregion

    if (mounted) {
      // #region agent log
      DebugLogger.log(
        location: 'products_list_screen.dart:41',
        message: 'About to call setState with results',
        data: {
          'success': result['success'],
          'productCount': result['success']
              ? (result['products'] as List).length
              : 0,
        },
        hypothesisId: 'B',
      );
      // #endregion
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _products = result['products'] as List<ProductModel>;
        }
      });
      // #region agent log
      DebugLogger.log(
        location: 'products_list_screen.dart:50',
        message: 'setState completed',
        data: {'productCount': _products.length},
        hypothesisId: 'B',
      );
      // #endregion
    } else {
      // #region agent log
      DebugLogger.log(
        location: 'products_list_screen.dart:53',
        message: 'Widget not mounted, skipping setState',
        hypothesisId: 'D',
      );
      // #endregion
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Store image URL for cleanup before deleting product
    final imageUrl = product.imageUrl;

    final result = await ProductService.deleteProduct(product.id!);

    if (mounted) {
      if (result['success']) {
        // Delete image from Firebase Storage if it exists (silently - don't fail if deletion fails)
        if (imageUrl != null) {
          await StorageService.deleteImageIfFirebase(imageUrl);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Products list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No products yet'
                              : 'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first product',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: product.imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ProductImageWidget(
                                      imageUrl: product.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorWidget: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                                  )
                                : Builder(
                                    builder: (context) {
                                      // #region agent log
                                      DebugLogger.log(
                                        location:
                                            'products_list_screen.dart:217',
                                        message: 'Product has no imageUrl',
                                        data: {
                                          'productId': product.id,
                                          'productName': product.name,
                                          'imageUrlIsNull':
                                              product.imageUrl == null,
                                        },
                                        hypothesisId: 'F',
                                      );
                                      // #endregion
                                      return const Icon(Icons.image, size: 60);
                                    },
                                  ),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${product.formattedPrice} • Stock: ${product.stockQuantity}',
                                ),
                                if (product.description != null &&
                                    product.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      product.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductFormScreen(
                                        user: widget.user,
                                        product: product,
                                      ),
                                    ),
                                  ).then((_) => _loadProducts());
                                } else if (value == 'delete') {
                                  _deleteProduct(product);
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductFormScreen(
                                    user: widget.user,
                                    product: product,
                                  ),
                                ),
                              ).then((_) => _loadProducts());
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductFormScreen(user: widget.user),
            ),
          ).then((_) => _loadProducts());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
