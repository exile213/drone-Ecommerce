import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../services/cart_service.dart';

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

    final result = await CartService.addToCart(
      userId: widget.user.id!,
      productId: widget.product.id!,
      quantity: _quantity,
    );

    if (mounted) {
      setState(() => _isAddingToCart = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add to cart'),
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Text(
                      widget.product.formattedPrice,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
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
                    Chip(
                      label: Text(widget.product.category),
                      avatar: const Icon(Icons.category, size: 18),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    if (widget.product.description != null &&
                        widget.product.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Quantity selector
                    if (widget.product.isInStock) ...[
                      Text(
                        'Quantity',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _quantity < widget.product.stockQuantity
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                          const Spacer(),
                          Text(
                            'Max: ${widget.product.stockQuantity}',
                            style: TextStyle(color: Colors.grey[600]),
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
                  child: ElevatedButton.icon(
                    onPressed: _isAddingToCart ? null : _addToCart,
                    icon: _isAddingToCart
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_cart),
                    label: Text(_isAddingToCart ? 'Adding...' : 'Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
