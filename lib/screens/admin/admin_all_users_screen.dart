import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart' as constants;

class AdminAllUsersScreen extends StatefulWidget {
  final UserModel user;

  const AdminAllUsersScreen({super.key, required this.user});

  @override
  State<AdminAllUsersScreen> createState() => _AdminAllUsersScreenState();
}

class _AdminAllUsersScreenState extends State<AdminAllUsersScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call when backend is ready
    // For now, using mock data
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Mock data - will be replaced with API call
        _users = [
          UserModel(
            id: 1,
            firebaseUid: 'firebase_uid_1',
            email: 'admin@example.com',
            role: 'admin',
            fullName: 'Admin User',
            phone: '123-456-7890',
            address: 'Admin Address',
            createdAt: '2024-01-01 10:00:00',
          ),
          UserModel(
            id: 2,
            firebaseUid: 'firebase_uid_2',
            email: 'john@example.com',
            role: 'user',
            fullName: 'John Seller',
            phone: '234-567-8901',
            address: '123 Main St',
            createdAt: '2024-01-05 14:30:00',
          ),
          UserModel(
            id: 3,
            firebaseUid: 'firebase_uid_3',
            email: 'jane@example.com',
            role: 'user',
            fullName: 'Jane Buyer',
            phone: '345-678-9012',
            address: '456 Oak Ave',
            createdAt: '2024-01-10 09:15:00',
          ),
          UserModel(
            id: 4,
            firebaseUid: 'firebase_uid_4',
            email: 'bob@example.com',
            role: 'user',
            fullName: 'Bob Customer',
            phone: '456-789-0123',
            address: '789 Pine Rd',
            createdAt: '2024-01-12 16:45:00',
          ),
        ];
      });
    }
  }

  Future<void> _changeUserRole(UserModel user, String newRole) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Text(
          'Change ${user.fullName}\'s role from ${user.role} to $newRole?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: constants.AppConstants.adminPrimary,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // TODO: Replace with actual API call when backend is ready
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role changed to $newRole (mock action)'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    }
  }

  List<UserModel> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      return user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                constants.AppConstants.adminPrimary,
                constants.AppConstants.adminSecondary,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
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
                hintText: 'Search users by name or email...',
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

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No users found'
                              : 'No users match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
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
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  constants.AppConstants.adminPrimary,
                              child: Text(
                                user.fullName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(user.email),
                                if (user.phone != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    user.phone!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                if (user.role == 'user')
                                  PopupMenuItem(
                                    value: 'make_admin',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.admin_panel_settings,
                                          size: 20,
                                          color: constants
                                              .AppConstants
                                              .adminPrimary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Make Admin',
                                          style: TextStyle(
                                            color: constants
                                                .AppConstants
                                                .adminPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (user.role == 'admin' &&
                                    user.id != widget.user.id)
                                  PopupMenuItem(
                                    value: 'make_user',
                                    child: const Row(
                                      children: [
                                        Icon(Icons.person, size: 20),
                                        SizedBox(width: 8),
                                        Text('Make User'),
                                      ],
                                    ),
                                  ),
                              ],
                              onSelected: (value) {
                                if (value == 'make_admin') {
                                  _changeUserRole(user, 'admin');
                                } else if (value == 'make_user') {
                                  _changeUserRole(user, 'user');
                                }
                              },
                            ),
                            onTap: () {
                              // Show user details dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(user.fullName),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Email: ${user.email}'),
                                      if (user.phone != null)
                                        Text('Phone: ${user.phone}'),
                                      if (user.address != null)
                                        Text('Address: ${user.address}'),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: user.isAdmin
                                              ? constants
                                                    .AppConstants
                                                    .adminLight
                                              : Colors.blue[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'Role: ${user.role.toUpperCase()}',
                                          style: TextStyle(
                                            color: user.isAdmin
                                                ? constants
                                                      .AppConstants
                                                      .adminPrimary
                                                : Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
