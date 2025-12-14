import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart' as constants;

class SellerOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  final UserModel user;

  const SellerOrderDetailScreen({
    super.key,
    required this.order,
    required this.user,
  });

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  late OrderModel _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    final result = await OrderService.updateOrderStatus(
      orderId: _order.id!,
      status: newStatus,
    );

    if (mounted) {
      setState(() => _isUpdating = false);

      if (result['success']) {
        setState(() {
          _order = _order.copyWith(status: newStatus);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${_order.id}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(_order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(_order.status),
                            ),
                          ),
                          child: Text(
                            _order.statusDisplay,
                            style: TextStyle(
                              color: _getStatusColor(_order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_order.buyerName != null)
                      _buildInfoRow(Icons.person, 'Buyer', _order.buyerName!),
                    if (_order.buyerEmail != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email, 'Email', _order.buyerEmail!),
                    ],
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, 'Delivery Date', _order.deliveryDate),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, 'Delivery Time', _order.deliveryTime.substring(0, 5)),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Delivery Address', _order.deliveryAddress),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.attach_money, 'Total Amount', _order.formattedTotal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Update status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Order Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _order.status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: constants.AppConstants.orderStatusPending,
                          child: const Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: constants.AppConstants.orderStatusShipped,
                          child: const Text('Shipped'),
                        ),
                        DropdownMenuItem(
                          value: constants.AppConstants.orderStatusCompleted,
                          child: const Text('Completed'),
                        ),
                      ],
                      onChanged: _isUpdating
                          ? null
                          : (value) {
                              if (value != null && value != _order.status) {
                                _updateStatus(value);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Order items
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            
            if (_order.items != null && _order.items!.isNotEmpty)
              ..._order.items!.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: item.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              ),
                            )
                          : const Icon(Icons.image, size: 60),
                      title: Text(
                        item.productName ?? 'Product',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Quantity: ${item.quantity} • ${item.formattedPrice} each'),
                      trailing: Text(
                        item.formattedTotal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

