import 'package:flutter/material.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import 'orders_page.dart';
import 'addresses_page.dart';
import 'profile_settings_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 24),
            _buildMenuSection(
              title: 'Shopping',
              items: [
                _MenuItem(
                  icon: Icons.shopping_bag,
                  title: 'My Orders',
                  subtitle: 'View and track your orders',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrdersPage()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.favorite,
                  title: 'Wishlist',
                  subtitle: 'Your saved items',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wishlist feature coming soon')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.rate_review,
                  title: 'Reviews',
                  subtitle: 'Rate your purchases',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reviews feature coming soon')),
                    );
                  },
                ),
              ],
            ),
            _buildMenuSection(
              title: 'Account Settings',
              items: [
                _MenuItem(
                  icon: Icons.location_on,
                  title: 'Delivery Addresses',
                  subtitle: 'Manage your addresses',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressesPage()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.payment,
                  title: 'Payment Methods',
                  subtitle: 'Manage payment options',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment methods coming soon')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildMenuSection(
              title: 'Support',
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with your orders',
                  onTap: () {
                    _showHelpDialog(context);
                  },
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'About ShopHub',
                  subtitle: 'Learn about us',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'ShopHub',
                      applicationVersion: '1.0.0',
                      applicationLegalese:
                          '© 2024 ShopHub. All rights reserved.',
                      children: [
                        SizedBox(height: 16),
                        Text(
                          'ShopHub is your one-stop destination for all your shopping needs. We offer a wide variety of products at competitive prices with fast delivery.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: AppTheme.padding,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  _showLogoutDialog(context);
                },
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [LightColor.skyBlue, LightColor.skyBlue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/user.png'),
          ),
          SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'john.doe@example.com',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          SizedBox(height: 4),
          Text(
            '+1 (555) 123-4567',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: LightColor.skyBlue,
            ),
          ),
        ),
        ...List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: LightColor.skyBlue),
                title: Text(item.title),
                subtitle: Text(item.subtitle),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: item.onTap,
              ),
              if (index < items.length - 1) Divider(height: 1),
            ],
          );
        }),
        SizedBox(height: 8),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Text('📧 Email: support@shophub.com'),
            SizedBox(height: 8),
            Text('📱 Phone: 1-800-SHOPHUB'),
            SizedBox(height: 8),
            Text('🕐 Available: 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout?'),
        content: Text('Are you sure you want to logout from your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
