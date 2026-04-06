import 'package:flutter/material.dart';

import '../config/route.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../shared/widgets/section_header.dart';
import '../state/app_settings.dart';
import '../themes/theme.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedLanguage = 'en';
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _themeMode = AppSettings.themeMode.value;
    _selectedLanguage = AppSettings.locale.value?.languageCode ?? 'en';
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
                subtitle: '${l10n.themeLight} / ${l10n.themeDark}',
                trailing: Switch(
                  value: _themeMode == ThemeMode.dark,
                  onChanged: (enabled) async {
                    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
                    setState(() {
                      _themeMode = mode;
                    });
                    await AppSettings.setThemeMode(mode);
                  },
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
                  Navigator.pushNamed(context, AppRoutes.about);
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: l10n.settingsPrivacyPolicy,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.privacy);
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.description,
                title: l10n.settingsTerms,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.terms);
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.help,
                title: l10n.settingsHelp,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.help);
                },
              ),
              const Divider(),
              _buildSettingItem(
                icon: Icons.article_outlined,
                title: MaterialLocalizations.of(context).licensesPageTitle,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.licenses);
                },
              ),
            ],
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
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: AppSpacing.iconSm),
      onTap: onTap,
    );
  }

  Widget _buildLanguageDropdown() {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(Icons.language, color: AppColors.primary),
      title: Text(l10n.settingsLanguage, style: AppTextStyles.bodyLarge),
      subtitle: Text(
        '${l10n.languageEnglish} / ${l10n.languageArabic}',
        style: AppTextStyles.bodySmall,
      ),
      trailing: Switch(
        value: _selectedLanguage == 'ar',
        onChanged: (isArabic) async {
          final languageCode = isArabic ? 'ar' : 'en';
          setState(() {
            _selectedLanguage = languageCode;
          });
          await AppSettings.setLocale(Locale(languageCode));
        },
      ),
    );
  }
}
