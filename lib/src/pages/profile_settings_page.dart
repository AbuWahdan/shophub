import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../shared/dialogs/app_dialogs.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/section_header.dart';
import '../state/app_settings.dart';
import '../themes/theme.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedLanguage = 'system';
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _themeMode = AppSettings.themeMode.value;
    _selectedLanguage = AppSettings.locale.value?.languageCode ?? 'system';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: AppTheme.padding,
        children: [
          _buildSection(
            title: l10n.settingsDisplay,
            children: [
              _buildSettingItem(
                icon: Icons.dark_mode,
                title: l10n.settingsTheme,
                trailing: DropdownButton<ThemeMode>(
                  value: _themeMode,
                  onChanged: (value) async {
                    if (value == null) return;
                    setState(() {
                      _themeMode = value;
                    });
                    await AppSettings.setThemeMode(value);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.settingsThemeUpdated)),
                    );
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.themeSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.themeLight),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.themeDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSection(
            title: l10n.settingsLanguageRegion,
            children: [_buildLanguageDropdown()],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSection(
            title: l10n.settingsAccount,
            children: [
              _buildSettingItem(
                icon: Icons.email,
                title: l10n.settingsEmailNotifications,
                subtitle: l10n.settingsEmailNotificationsSubtitle,
                trailing: Switch(
                  value: _emailNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                ),
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.notifications,
                title: l10n.settingsPushNotifications,
                subtitle: l10n.settingsPushNotificationsSubtitle,
                trailing: Switch(
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildSection(
            title: l10n.settingsAbout,
            children: [
              _buildSettingItem(
                icon: Icons.info,
                title: l10n.settingsAboutApp,
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: l10n.settingsPrivacyPolicy,
                onTap: () {
                  Navigator.pushNamed(context, '/privacy');
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.description,
                title: l10n.settingsTerms,
                onTap: () {
                  Navigator.pushNamed(context, '/terms');
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.help,
                title: l10n.settingsHelp,
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.article_outlined,
                title: MaterialLocalizations.of(context).licensesPageTitle,
                onTap: () {
                  Navigator.pushNamed(context, '/licenses');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.settingsLogout,
            style: AppButtonStyle.danger,
            onPressed: () {
              AppDialogs.showConfirmation(
                context: context,
                title: l10n.settingsLogoutConfirmTitle,
                message: l10n.settingsLogoutConfirmMessage,
                confirmLabel: l10n.commonLogout,
                cancelLabel: l10n.commonCancel,
                onConfirm: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.settingsDeleteAccount,
            style: AppButtonStyle.danger,
            onPressed: () {
              AppDialogs.showConfirmation(
                context: context,
                title: l10n.settingsDeleteAccountConfirmTitle,
                message: l10n.settingsDeleteAccountConfirmMessage,
                confirmLabel: l10n.commonDelete,
                cancelLabel: l10n.commonCancel,
                onConfirm: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsAccountDeleted)),
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxxl),
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
        SectionHeader(title: title),
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
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge(context)),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall(context))
          : null,
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: AppSpacing.iconSm),
      onTap: onTap,
    );
  }

  Widget _buildLanguageDropdown() {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(Icons.language, color: AppColors.primary),
      title: Text(l10n.settingsLanguage, style: AppTextStyles.bodyLarge(context)),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        items: [
          DropdownMenuItem(
            value: 'system',
            child: Text(l10n.languageSystem),
          ),
          DropdownMenuItem(
            value: 'en',
            child: Text(l10n.languageEnglish),
          ),
          DropdownMenuItem(
            value: 'ar',
            child: Text(l10n.languageArabic),
          ),
        ],
        onChanged: (value) async {
          if (value == null) return;
          setState(() {
            _selectedLanguage = value;
          });
          await AppSettings.setLocale(value == 'system' ? null : Locale(value));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsLanguageUpdated)),
          );
        },
      ),
    );
  }
}
