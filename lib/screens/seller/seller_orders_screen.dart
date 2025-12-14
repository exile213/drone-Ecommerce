import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart' as constants;
import 'seller_order_detail_screen.dart';

class SellerOrdersScreen extends StatefulWidget {
  final UserModel user;

  const SellerOrdersScreen({super.key, required this.user});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    final result = await OrderService.getOrdersBySeller(widget.user.id!);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _orders = result['orders'] as List<OrderModel>;
          if (_selectedStatus != null) {
            _orders = _orders
                .where((order) => order.status == _selectedStatus)
                .toList();
          }
        }
      });
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
        title: const Text('Incoming Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
                filled: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Orders')),
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
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                  _loadOrders();
                });
              },
            ),
          ),

          // Orders list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellerOrderDetailScreen(
                                    order: order,
                                    user: widget.user,
                                  ),
                                ),
                              ).then((_) => _loadOrders());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order #${order.id}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            order.status,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: _getStatusColor(
                                              order.status,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          order.statusDisplay,
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              order.status,
                                            ),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (order.buyerName != null) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Buyer: ${order.buyerName}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delivery: ${order.deliveryDate} at ${order.deliveryTime.substring(0, 5)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        order.formattedTotal,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOrders,
        tooltip: 'Refresh Orders',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
