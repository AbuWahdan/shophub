import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/route.dart';
import 'app_settings.dart';
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/state/auth_state.dart';
import '../../../widgets/section_header/section_header.dart';
import 'change_email/change_email_screen.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedLanguageCode = 'en';
  bool _emailNotificationsEnabled = true;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _themeMode = AppSettings.themeMode.value;
    _selectedLanguageCode = AppSettings.locale.value?.languageCode ?? 'en';
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    // Re-read persisted settings in case they changed from another screen.
    if (!mounted) return;
    setState(() {
      _themeMode = AppSettings.themeMode.value;
      _selectedLanguageCode =
          AppSettings.locale.value?.languageCode ?? 'en';
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.insetsMd,
          children: [
            // ── Display ──────────────────────────────────────────────────────
            _SettingsSection(
              title: l10n.settingsDisplay,
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode,
                  title: l10n.settingsTheme,
                  subtitle: '${l10n.themeLight} / ${l10n.themeDark}',
                  trailing: Switch(
                    value: _themeMode == ThemeMode.dark,
                    onChanged: (isDark) async {
                      final mode =
                      isDark ? ThemeMode.dark : ThemeMode.light;
                      setState(() => _themeMode = mode);
                      await AppSettings.setThemeMode(mode);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Language & Region ─────────────────────────────────────────────
            _SettingsSection(
              title: l10n.settingsLanguageRegion,
              children: [
                _LanguageTile(
                  selectedLanguageCode: _selectedLanguageCode,
                  onChanged: (languageCode) async {
                    setState(() => _selectedLanguageCode = languageCode);
                    await AppSettings.setLocale(Locale(languageCode));
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Account ───────────────────────────────────────────────────────
            _SettingsSection(
              title: l10n.settingsAccount,
              children: [
                if (isLoggedIn) ...[
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: l10n.settingsChangePassword,
                    subtitle: l10n.settingsChangePasswordSubtitle,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.changePassword,
                    ),
                  ),
                  const Divider(),
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    title: 'Change Email',
                    subtitle: 'Update your email address',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ChangeEmailScreen(),
                        settings:
                        RouteSettings(name: AppRoutes.changeEmail),
                      ),
                    ),
                  ),
                  const Divider(),
                ],
                _SettingsTile(
                  icon: Icons.email,
                  title: l10n.settingsEmailNotifications,
                  subtitle: l10n.settingsEmailNotificationsSubtitle,
                  trailing: Switch(
                    value: _emailNotificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _emailNotificationsEnabled = value),
                  ),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.notifications,
                  title: l10n.settingsPushNotifications,
                  subtitle: l10n.settingsPushNotificationsSubtitle,
                  trailing: Switch(
                    value: _pushNotificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _pushNotificationsEnabled = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── About ─────────────────────────────────────────────────────────
            _SettingsSection(
              title: l10n.settingsAbout,
              children: [
                _SettingsTile(
                  icon: Icons.info,
                  title: l10n.settingsAboutApp,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.about),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.privacy_tip,
                  title: l10n.settingsPrivacyPolicy,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.privacy),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.description,
                  title: l10n.settingsTerms,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.terms),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.help,
                  title: l10n.settingsHelp,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.help),
                ),
                const Divider(),
                _SettingsTile(
                  icon: Icons.article_outlined,
                  title:
                  MaterialLocalizations.of(context).licensesPageTitle,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.licenses),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────────

/// A labelled section with a [SectionHeader] followed by [children].
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        ...children,
      ],
    );
  }
}

/// A single settings row built on [ListTile].
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySmall)
          : null,
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: AppSpacing.iconSm),
      onTap: onTap,
    );
  }
}

/// Language toggle tile (en ↔ ar).
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.selectedLanguageCode,
    required this.onChanged,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: Icon(Icons.language, color: AppColors.primary),
      title: Text(l10n.settingsLanguage, style: AppTextStyles.bodyLarge),
      subtitle: Text(
        '${l10n.languageEnglish} / ${l10n.languageArabic}',
        style: AppTextStyles.bodySmall,
      ),
      trailing: Switch(
        value: selectedLanguageCode == 'ar',
        onChanged: (isArabic) => onChanged(isArabic ? 'ar' : 'en'),
      ),
    );
  }
}