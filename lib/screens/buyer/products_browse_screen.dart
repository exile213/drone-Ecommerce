import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart' as constants;
import '../../utils/debug_logger.dart';
import 'product_detail_screen.dart';

class ProductsBrowseScreen extends StatefulWidget {
  final UserModel user;

  const ProductsBrowseScreen({super.key, required this.user});

  @override
  State<ProductsBrowseScreen> createState() => _ProductsBrowseScreenState();
}

class _ProductsBrowseScreenState extends State<ProductsBrowseScreen> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // #region agent log
    DebugLogger.log(location: 'products_browse_screen.dart:30', message: '_loadProducts called', data: {'userId': widget.user.id, 'category': _selectedCategory, 'search': _searchQuery, 'currentProductCount': _products.length}, hypothesisId: 'A');
    // #endregion
    setState(() => _isLoading = true);

    final result = await ProductService.getAllProducts(
      category: _selectedCategory,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      excludeSellerId: widget.user.id,
    );
    // #region agent log
    DebugLogger.log(location: 'products_browse_screen.dart:38', message: 'API call completed', data: {'success': result['success'], 'productCount': result['success'] ? (result['products'] as List).length : 0, 'excludeSellerId': widget.user.id}, hypothesisId: 'A');
    // #endregion

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          final allProducts = result['products'] as List<ProductModel>;
          // #region agent log
          DebugLogger.log(location: 'products_browse_screen.dart:45', message: 'Filtering products', data: {'totalProducts': allProducts.length, 'userId': widget.user.id, 'ownProductsCount': allProducts.where((p) => p.sellerId == widget.user.id).length}, hypothesisId: 'A');
          // #endregion
          // Filter out own products on client side as safety measure
          _products = allProducts.where((product) => product.sellerId != widget.user.id).toList();
          // #region agent log
          DebugLogger.log(location: 'products_browse_screen.dart:49', message: 'After client-side filter', data: {'filteredCount': _products.length, 'productIds': _products.map((p) => p.id).toList(), 'sellerIds': _products.map((p) => p.sellerId).toList()}, hypothesisId: 'A');
          // #endregion
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            style: GoogleFonts.inter(),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF64748b)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF64748b)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFF64748b)),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _loadProducts();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF0ea5e9),
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _loadProducts(),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // Category filter
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('All', null),
              const SizedBox(width: 8),
              ...constants.AppConstants.productCategories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(category, category),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Products grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: const Color(0xFF64748b),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF0ea5e9),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748b),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0ea5e9) : Colors.grey.shade300,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
          _loadProducts();
        });
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0ea5e9).withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: product,
                      user: widget.user,
                    ),
                  ),
                ).then((_) => _loadProducts());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product image
                  Expanded(
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 48),
                          ),
                  ),

                  // Product info
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category?.toUpperCase() ?? 'PRODUCT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748b),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF0f172a),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.formattedPrice,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF0ea5e9),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Add button
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0ea5e9), Color(0xFF6366f1)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0ea5e9).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: product,
                            user: widget.user,
                          ),
                        ),
                      ).then((_) => _loadProducts());
                    },
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
