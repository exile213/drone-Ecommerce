import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart' as constants;
import '../seller/product_form_screen.dart';

class AdminAllProductsScreen extends StatefulWidget {
  final UserModel user;

  const AdminAllProductsScreen({super.key, required this.user});

  @override
  State<AdminAllProductsScreen> createState() => _AdminAllProductsScreenState();
}

class _AdminAllProductsScreenState extends State<AdminAllProductsScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call when backend is ready
    // For now, using mock data
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Mock data - will be replaced with API call
        _products = [
          ProductModel(
            id: 1,
            sellerId: 2,
            name: 'DJI Mavic 3 Pro',
            description: 'Professional drone with 4K camera',
            price: 15999.99,
            stockQuantity: 5,
            category: 'Drone',
            imageUrl: null,
            sellerName: 'John Seller',
            sellerEmail: 'john@example.com',
          ),
          ProductModel(
            id: 2,
            sellerId: 3,
            name: 'Drone Battery Pack',
            description: 'High capacity battery for drones',
            price: 299.99,
            stockQuantity: 20,
            category: 'Batteries',
            imageUrl: null,
            sellerName: 'Jane Seller',
            sellerEmail: 'jane@example.com',
          ),
          ProductModel(
            id: 3,
            sellerId: 2,
            name: 'FPV Controller',
            description: 'First person view controller',
            price: 599.99,
            stockQuantity: 8,
            category: 'Controllers',
            imageUrl: null,
            sellerName: 'John Seller',
            sellerEmail: 'john@example.com',
          ),
        ];
      });
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

    // TODO: Replace with actual API call when backend is ready
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${product.name}" deleted (mock action)'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProducts();
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false) ||
          (product.sellerName?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: constants.AppConstants.adminLight,
            boxShadow: [
              BoxShadow(
                color: constants.AppConstants.adminPrimary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products or sellers...',
              prefixIcon: const Icon(
                Icons.search,
                color: constants.AppConstants.adminPrimary,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: constants.AppConstants.adminPrimary,
                      ),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: constants.AppConstants.adminPrimary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: constants.AppConstants.adminPrimary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: constants.AppConstants.adminPrimary,
                  width: 2,
                ),
              ),
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
                            ? 'No products found'
                            : 'No products match your search',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
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
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: constants.AppConstants.adminPrimary
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color:
                                            constants.AppConstants.adminLight,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: constants.AppConstants.adminLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.image, size: 30),
                                ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${product.formattedPrice} • Stock: ${product.stockQuantity}',
                              ),
                              if (product.sellerName != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 14,
                                      color:
                                          constants.AppConstants.adminPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Seller: ${product.sellerName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            constants.AppConstants.adminPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                            icon: const Icon(Icons.more_vert),
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
    );
  }
}
