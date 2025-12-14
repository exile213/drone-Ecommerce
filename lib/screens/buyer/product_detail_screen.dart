import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final UserModel user;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.user,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAddingToCart = false;

  Future<void> _addToCart() async {
    if (!widget.product.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product is out of stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_quantity > widget.product.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only ${widget.product.stockQuantity} items available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isAddingToCart = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final success = await cartProvider.addToCart(
      widget.user.id!,
      widget.product.id!,
      _quantity,
    );

    if (mounted) {
      setState(() => _isAddingToCart = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add to cart'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // Allow normal back navigation without any side effects
        if (didPop) {
          // Navigation was successful, no action needed
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product image
              widget.product.imageUrl != null
                  ? Image.network(
                      widget.product.imageUrl!,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 64),
                    ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      widget.product.name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0f172a),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      widget.product.formattedPrice,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0ea5e9),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stock status
                    Row(
                      children: [
                        Icon(
                          widget.product.isInStock
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: widget.product.isInStock
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.product.isInStock
                              ? 'In Stock (${widget.product.stockQuantity} available)'
                              : 'Out of Stock',
                          style: TextStyle(
                            color: widget.product.isInStock
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFe0f2fe),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category,
                            size: 18,
                            color: Color(0xFF0ea5e9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.product.category,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0ea5e9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (widget.product.description != null &&
                        widget.product.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0f172a),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748b),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quantity selector
                    if (widget.product.isInStock) ...[
                      Text(
                        'Quantity',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0f172a),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Color(0xFF0ea5e9),
                            ),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantity',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0f172a),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: _quantity < widget.product.stockQuantity
                                  ? const Color(0xFF0ea5e9)
                                  : Colors.grey,
                            ),
                            onPressed: _quantity < widget.product.stockQuantity
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                          const Spacer(),
                          Text(
                            'Max: ${widget.product.stockQuantity}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748b),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.product.isInStock
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0ea5e9), Color(0xFF6366f1)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0ea5e9).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isAddingToCart ? null : _addToCart,
                      icon: _isAddingToCart
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isAddingToCart ? 'Adding...' : 'Add to Cart',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
