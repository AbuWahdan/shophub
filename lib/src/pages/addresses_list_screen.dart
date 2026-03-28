import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/address_controller.dart';
import '../../data/domain_models/address_entity.dart';
import '../../src/state/auth_state.dart';
import '../../src/design/app_text_styles.dart';
import '../../src/shared/widgets/empty_state.dart';
import '../../src/themes/theme.dart';
import 'add_edit_address_screen.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  late AddressController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AddressController>();
    
    // Initialize on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoad();
    });
  }

  void _initializeAndLoad() {
    final auth = context.read<AuthState>();
    if (auth.isLoggedIn && auth.user != null) {
      _controller.username = auth.user!.username.trim();
      _controller.loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final isLoggedIn = auth.isLoggedIn && auth.user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        elevation: 0,
      ),
      body: !isLoggedIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Please log in to manage addresses'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          : Obx(() {
              // Show error state
              if (_controller.error.isNotEmpty) {
                return RefreshIndicator(
                  onRefresh: () => _controller.loadAddresses(forceRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error Loading Addresses',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.error.value,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _controller.loadAddresses(forceRefresh: true),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show loading state
              if (_controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // Show empty state
              if (_controller.addresses.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => _controller.loadAddresses(forceRefresh: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: EmptyState(
                          icon: Icons.location_on_outlined,
                          title: 'No Addresses',
                          message: 'You don\'t have any saved addresses yet.',
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show addresses list
              return RefreshIndicator(
                onRefresh: () => _controller.loadAddresses(forceRefresh: true),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _controller.addresses.length,
                  itemBuilder: (context, index) {
                    final address = _controller.addresses[index];
                    return _AddressCard(
                      address: address,
                      isDefault: address.isDefault,
                      onEdit: () => _openEditAddress(address),
                      onDelete: () => _deleteAddress(address),
                      onSetDefault: () => _setDefaultAddress(address),
                    );
                  },
                ),
              );
            }),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: () => _openAddAddress(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _openAddAddress() async {
    final result = await Navigator.push<AddressEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditAddressScreen(
          username: _controller.username,
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        await _controller.addAddress(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _openEditAddress(AddressEntity address) async {
    final result = await Navigator.push<AddressEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditAddressScreen(
          username: _controller.username,
          initialAddress: address,
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        await _controller.updateAddress(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteAddress(AddressEntity address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && address.addressId != null) {
      try {
        await _controller.deleteAddress(address.addressId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _setDefaultAddress(AddressEntity address) async {
    if (address.addressId != null) {
      try {
        await _controller.setDefaultAddress(address.addressId!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Default address updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  final bool isDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.isDefault,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isDefault)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onEdit,
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!isDefault)
                      PopupMenuItem(
                        onTap: onSetDefault,
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, size: 18),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.streetAddress,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${address.city}, ${address.state} ${address.zipCode}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              address.country,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${address.phone}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
