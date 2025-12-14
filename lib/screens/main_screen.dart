import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart' as constants;
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'buyer/products_browse_screen.dart';
import 'buyer/cart_screen.dart';
import 'buyer/my_orders_screen.dart';
import 'seller/products_list_screen.dart';
import 'seller/seller_orders_screen.dart';
import 'admin/admin_all_products_screen.dart';
import 'admin/admin_all_orders_screen.dart';
import 'admin/admin_all_users_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;

  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  int _ordersRefreshKey = 0;

  List<Widget> get _screens {
    // Role-based screen navigation:
    // - Admin: Admin dashboard + buyer features (browse, cart, orders)
    // - User: Buyer + Seller features (home, browse, cart, orders)
    //   Note: "user" role can act as both buyer and seller
    if (widget.user.isAdmin) {
      return [
        AdminDashboardScreen(
          user: widget.user,
          onNavigateToTab: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        ProductsBrowseScreen(user: widget.user),
        CartScreen(user: widget.user),
        MyOrdersScreen(
          key: ValueKey(_ordersRefreshKey),
          user: widget.user,
          refreshKey: ValueKey(_ordersRefreshKey),
        ),
      ];
    }
    // User role: Can browse (buyer) and manage products (seller)
    return [
      HomeScreen(
        user: widget.user,
        onNavigateToTab: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      ProductsBrowseScreen(user: widget.user),
      CartScreen(user: widget.user),
      MyOrdersScreen(
        key: ValueKey(_ordersRefreshKey),
        user: widget.user,
        refreshKey: ValueKey(_ordersRefreshKey),
      ),
    ];
  }

  List<BottomNavigationBarItem> get _bottomNavItems {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: 'Browse',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart),
        label: 'Cart',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Orders',
      ),
    ];
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  String get _appBarTitle {
    if (widget.user.isAdmin) {
      switch (_currentIndex) {
        case 0:
          return 'Admin Dashboard';
        case 1:
          return 'Browse';
        case 2:
          return 'Cart';
        case 3:
          return 'Orders';
        default:
          return 'ShopMobile';
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return 'Home';
        case 1:
          return 'Browse';
        case 2:
          return 'Cart';
        case 3:
          return 'My Orders';
        default:
          return 'ShopMobile';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.user.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Refresh button for Cart and Orders tabs
          if (_currentIndex == 2) // Cart tab
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final cartProvider = Provider.of<CartProvider>(
                  context,
                  listen: false,
                );
                cartProvider.loadCart(widget.user.id!);
              },
              tooltip: 'Refresh Cart',
            ),
          if (_currentIndex == 3) // Orders tab
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _ordersRefreshKey++; // Change key to trigger refresh
                });
              },
              tooltip: 'Refresh Orders',
            ),
          // Admin badge
          if (isAdmin)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: constants.AppConstants.adminPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ADMIN',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Menu items
          if (widget.user.isAdmin) ...[
            // Admin menu - just logout
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ] else if (widget.user.role == constants.AppConstants.roleUser) ...[
            // User role menu: Can act as both buyer and seller
            // Shows seller features (My Products, Incoming Orders) + buyer features (via bottom nav)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'my_products',
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2),
                      SizedBox(width: 8),
                      Text('My Products'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'seller_orders',
                  child: Row(
                    children: [
                      Icon(Icons.shopping_bag),
                      SizedBox(width: 8),
                      Text('Incoming Orders'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'my_products') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductsListScreen(user: widget.user),
                    ),
                  );
                } else if (value == 'seller_orders') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SellerOrdersScreen(user: widget.user),
                    ),
                  );
                } else if (value == 'logout') {
                  _handleLogout();
                }
              },
            ),
          ] else ...[
            // Buyer only - just logout
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.user.isAdmin
                      ? [
                          constants.AppConstants.adminPrimary,
                          constants.AppConstants.adminSecondary,
                        ]
                      : [const Color(0xFF0ea5e9), const Color(0xFF6366f1)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.user.fullName[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        color: widget.user.isAdmin
                            ? constants.AppConstants.adminPrimary
                            : const Color(0xFF0ea5e9),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      widget.user.fullName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      widget.user.email,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.user.isAdmin
                            ? constants.AppConstants.adminLight
                            : const Color(0xFFe0f2fe),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.user.role.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.user.isAdmin
                              ? constants.AppConstants.adminPrimary
                              : const Color(0xFF0ea5e9),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF0f172a)),
              title: Text(
                'Home',
                style: GoogleFonts.inter(color: const Color(0xFF0f172a)),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Color(0xFF0f172a)),
              title: Text(
                'Browse Products',
                style: GoogleFonts.inter(color: const Color(0xFF0f172a)),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.shopping_cart,
                color: Color(0xFF0f172a),
              ),
              title: Text(
                'Shopping Cart',
                style: GoogleFonts.inter(color: const Color(0xFF0f172a)),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Color(0xFF0f172a)),
              title: Text(
                'My Orders',
                style: GoogleFonts.inter(color: const Color(0xFF0f172a)),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            // Seller menu section: User role can manage products and view orders
            // (User role = buyer + seller capabilities)
            if (widget.user.role == constants.AppConstants.roleUser &&
                !widget.user.isAdmin) ...[
              const Divider(color: Color(0xFFe2e8f0)),
              ListTile(
                leading: const Icon(
                  Icons.inventory_2,
                  color: Color(0xFF0f172a),
                ),
                title: Text(
                  'My Products',
                  style: GoogleFonts.inter(color: const Color(0xFF0f172a)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductsListScreen(user: widget.user),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.shopping_bag,
                  color: Color(0xFF0f172a),
                ),
                title: Text(
                  'Incoming Orders',
                  style: GoogleFonts.inter(color: const Color(0xFF0f172a)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SellerOrdersScreen(user: widget.user),
                    ),
                  );
                },
              ),
            ],
            // Admin menu section (only for admins)
            if (widget.user.isAdmin) ...[
              const Divider(color: Color(0xFFe2e8f0)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'ADMIN DASHBOARD',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: constants.AppConstants.adminPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.inventory_2,
                  color: constants.AppConstants.adminPrimary,
                ),
                title: Text(
                  'All Products',
                  style: GoogleFonts.inter(
                    color: constants.AppConstants.adminPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminAllProductsScreen(user: widget.user),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.receipt_long,
                  color: constants.AppConstants.adminPrimary,
                ),
                title: Text(
                  'All Orders',
                  style: GoogleFonts.inter(
                    color: constants.AppConstants.adminPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminAllOrdersScreen(user: widget.user),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.people,
                  color: constants.AppConstants.adminPrimary,
                ),
                title: Text(
                  'All Users',
                  style: GoogleFonts.inter(
                    color: constants.AppConstants.adminPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AdminAllUsersScreen(user: widget.user),
                    ),
                  );
                },
              ),
            ],
            const Divider(color: Color(0xFFe2e8f0)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.inter(color: Colors.red),
              ),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0ea5e9),
        unselectedItemColor: const Color(0xFF64748b),
        selectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: widget.user.isAdmin
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Browse',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
              ]
            : _bottomNavItems,
      ),
    );
  }
}
