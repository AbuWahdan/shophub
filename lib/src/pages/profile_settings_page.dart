import 'package:flutter/material.dart';
import '../themes/light_color.dart';
import '../themes/theme.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool isDarkMode = false;
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: AppTheme.padding,
        children: [
          _buildSection(
            title: 'Display',
            children: [
              _buildSettingItem(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Dark mode enabled' : 'Light mode enabled',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'Language & Region',
            children: [_buildLanguageDropdown()],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'Account',
            children: [
              _buildSettingItem(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Orders, offers, and updates',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              Divider(),
              _buildSettingItem(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Stay updated with deals',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'About',
            children: [
              _buildSettingItem(
                icon: Icons.info,
                title: 'About ShopHub',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'ShopHub',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2024 ShopHub. All rights reserved.',
                  );
                },
              ),
              Divider(),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  _showDialog(
                    context,
                    'Privacy Policy',
                    'Your privacy is important to us. We collect and process personal data in accordance with our privacy policy.',
                  );
                },
              ),
              Divider(),
              _buildSettingItem(
                icon: Icons.description,
                title: 'Terms & Conditions',
                onTap: () {
                  _showDialog(
                    context,
                    'Terms & Conditions',
                    'By using ShopHub, you agree to these terms and conditions.',
                  );
                },
              ),
              Divider(),
              _buildSettingItem(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  _showDialog(
                    context,
                    'Help & Support',
                    'Contact us at support@shophub.com for assistance.',
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout?'),
                    content: Text('Are you sure you want to logout?'),
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
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Account?'),
                    content: Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Account deleted')),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Delete Account',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
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
        ...children,
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: LightColor.skyBlue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildLanguageDropdown() {
    return ListTile(
      leading: Icon(Icons.language, color: LightColor.skyBlue),
      title: Text('Language'),
      trailing: DropdownButton<String>(
        value: selectedLanguage,
        items: ['English', 'Arabic', 'Spanish', 'French']
            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedLanguage = value;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Language changed to $value')),
            );
          }
        },
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
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
