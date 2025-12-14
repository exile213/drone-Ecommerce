import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart' as constants;
import 'admin_order_detail_screen.dart';

class AdminAllOrdersScreen extends StatefulWidget {
  final UserModel user;

  const AdminAllOrdersScreen({super.key, required this.user});

  @override
  State<AdminAllOrdersScreen> createState() => _AdminAllOrdersScreenState();
}

class _AdminAllOrdersScreenState extends State<AdminAllOrdersScreen> {
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

    // TODO: Replace with actual API call when backend is ready
    // For now, using mock data
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Mock data - will be replaced with API call
        _orders = [
          OrderModel(
            id: 1,
            userId: 2,
            totalAmount: 15999.99,
            deliveryDate: '2024-01-15',
            deliveryTime: '14:00:00',
            deliveryAddress: '123 Main St, City',
            status: 'pending',
            buyerName: 'John Buyer',
            buyerEmail: 'john@example.com',
            createdAt: '2024-01-10 10:00:00',
          ),
          OrderModel(
            id: 2,
            userId: 3,
            totalAmount: 899.98,
            deliveryDate: '2024-01-16',
            deliveryTime: '10:00:00',
            deliveryAddress: '456 Oak Ave, City',
            status: 'shipped',
            buyerName: 'Jane Buyer',
            buyerEmail: 'jane@example.com',
            createdAt: '2024-01-11 15:30:00',
          ),
          OrderModel(
            id: 3,
            userId: 4,
            totalAmount: 1599.99,
            deliveryDate: '2024-01-14',
            deliveryTime: '16:00:00',
            deliveryAddress: '789 Pine Rd, City',
            status: 'completed',
            buyerName: 'Bob Buyer',
            buyerEmail: 'bob@example.com',
            createdAt: '2024-01-09 09:00:00',
          ),
        ];

        if (_selectedStatus != null) {
          _orders = _orders
              .where((order) => order.status == _selectedStatus)
              .toList();
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
    return Column(
      children: [
        // Status filter
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
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Filter by Status',
              prefixIcon: const Icon(
                Icons.filter_list,
                color: constants.AppConstants.adminPrimary,
              ),
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
              filled: true,
              fillColor: Colors.white,
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
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: constants.AppConstants.adminPrimary
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminOrderDetailScreen(
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
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getStatusColor(order.status),
                                        ),
                                      ),
                                      child: Text(
                                        order.statusDisplay,
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
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
                                      Icon(
                                        Icons.person,
                                        size: 16,
                                        color:
                                            constants.AppConstants.adminPrimary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Buyer: ${order.buyerName}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        order.buyerEmail ?? 'No email',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Delivery: ${order.deliveryDate} at ${order.deliveryTime.substring(0, 5)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      order.formattedTotal,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color:
                                            constants.AppConstants.adminPrimary,
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
    );
  }
}
