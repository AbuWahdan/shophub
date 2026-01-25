import 'package:flutter/material.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';
import 'orders_page.dart';
import 'addresses_page.dart';
import 'profile_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppTheme.padding,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/user.png'),
          ),
          SizedBox(height: 16),
          Text('John Doe', style: AppTheme.h4Style),
          SizedBox(height: 8),
          Text('john.doe@example.com', style: AppTheme.subTitleStyle),
          SizedBox(height: 24),
          _buildMenuItem(context, Icons.shopping_bag, 'Orders', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrdersPage()),
            );
          }),
          _buildMenuItem(context, Icons.location_on, 'Addresses', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressesPage()),
            );
          }),
          _buildMenuItem(context, Icons.settings, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
            );
          }),
          _buildMenuItem(context, Icons.help_outline, 'Help & Support', () {
            _showHelpDialog(context);
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: LightColor.skyBlue),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Text('Contact us at support@shophub.com for any assistance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
