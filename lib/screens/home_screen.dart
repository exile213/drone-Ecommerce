import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../utils/constants.dart' as constants;
import '../utils/debug_logger.dart';
import 'buyer/product_detail_screen.dart';
import 'seller/products_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, required this.user, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<ProductModel> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // #region agent log
    DebugLogger.log(location: 'home_screen.dart:27', message: 'initState called', data: {'productCount': _featuredProducts.length}, hypothesisId: 'A');
    // #endregion
    WidgetsBinding.instance.addObserver(this);
    _loadFeaturedProducts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // #region agent log
    DebugLogger.log(location: 'home_screen.dart:42', message: 'App lifecycle changed', data: {'state': state.toString()}, hypothesisId: 'C');
    // #endregion
    if (state == AppLifecycleState.resumed) {
      // #region agent log
      DebugLogger.log(location: 'home_screen.dart:45', message: 'App resumed, refreshing products', hypothesisId: 'C');
      // #endregion
      _loadFeaturedProducts();
    }
  }

  Future<void> _loadFeaturedProducts() async {
    // #region agent log
    DebugLogger.log(location: 'home_screen.dart:79', message: '_loadFeaturedProducts called', data: {'mounted': mounted, 'currentProductCount': _featuredProducts.length, 'userId': widget.user.id, 'userRole': widget.user.role}, hypothesisId: 'A');
    // #endregion
    setState(() => _isLoading = true);
    final result = await ProductService.getAllProducts(
      excludeSellerId: widget.user.id, // Exclude user's own products
    );
    // #region agent log
    DebugLogger.log(location: 'home_screen.dart:85', message: 'API call completed', data: {'success': result['success'], 'productCount': result['success'] ? (result['products'] as List).length : 0, 'mounted': mounted, 'excludeSellerId': widget.user.id}, hypothesisId: 'A');
    // #endregion

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          // Get first 6 products as featured, with client-side filtering as safety measure
          final allProducts = result['products'] as List<ProductModel>;
          // #region agent log
          DebugLogger.log(location: 'home_screen.dart:92', message: 'Filtering products', data: {'totalProducts': allProducts.length, 'userId': widget.user.id, 'ownProductsCount': allProducts.where((p) => p.sellerId == widget.user.id).length}, hypothesisId: 'A');
          // #endregion
          // Filter out own products on client side as safety measure
          final filteredProducts = allProducts.where((product) => product.sellerId != widget.user.id).toList();
          // #region agent log
          DebugLogger.log(location: 'home_screen.dart:96', message: 'After client-side filter', data: {'filteredCount': filteredProducts.length}, hypothesisId: 'A');
          // #endregion
          // Get first 6 products as featured
          _featuredProducts = filteredProducts.take(6).toList();
        }
      });
      // #region agent log
      DebugLogger.log(location: 'home_screen.dart:101', message: 'setState completed', data: {'productCount': _featuredProducts.length, 'featuredProductIds': _featuredProducts.map((p) => p.id).toList(), 'featuredSellerIds': _featuredProducts.map((p) => p.sellerId).toList()}, hypothesisId: 'A');
      // #endregion
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFeaturedProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0ea5e9), Color(0xFF6366f1)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flight, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Welcome, ${widget.user.fullName}!',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore our drone marketplace',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.shopping_bag,
                      title: 'Browse',
                      color: Colors.blue,
                      onTap: () {
                        widget.onNavigateToTab?.call(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.shopping_cart,
                      title: 'Cart',
                      color: Colors.orange,
                      onTap: () {
                        widget.onNavigateToTab?.call(2);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Show "My Products" for user role (buyer + seller)
                  // User role can manage products as a seller
                  if (widget.user.role == constants.AppConstants.roleUser &&
                      !widget.user.isAdmin)
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.inventory_2,
                        title: 'My Products',
                        color: Colors.green,
                        onTap: () {
                          // #region agent log
                          DebugLogger.log(location: 'home_screen.dart:197', message: 'Navigating to ProductsListScreen', hypothesisId: 'B');
                          // #endregion
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductsListScreen(user: widget.user),
                            ),
                          ).then((_) {
                            // #region agent log
                            DebugLogger.log(location: 'home_screen.dart:207', message: 'Returned from ProductsListScreen, refreshing', hypothesisId: 'B');
                            // #endregion
                            _loadFeaturedProducts();
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Featured products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Products',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0f172a),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0ea5e9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Products grid
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _featuredProducts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748b),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _featuredProducts[index];
                        return SizedBox(
                          width: 180,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0ea5e9,
                                  ).withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
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
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: product.imageUrl != null
                                          ? Image.network(
                                              product.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: const Color(0xFF0f172a),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
