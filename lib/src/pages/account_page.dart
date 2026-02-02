import 'package:flutter/material.dart';

import '../config/app_images.dart';
import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../shared/dialogs/app_dialogs.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_image.dart';
import '../themes/theme.dart';
import 'addresses_page.dart';
import 'orders_page.dart';
import 'profile_settings_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildMenuSection(
              context: context,
              title: l10n.accountShoppingSection,
              items: [
                _MenuItem(
                  icon: Icons.shopping_bag,
                  title: l10n.accountMyOrders,
                  subtitle: l10n.accountMyOrdersSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrdersPage()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.favorite,
                  title: l10n.accountWishlist,
                  subtitle: l10n.accountWishlistSubtitle,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.accountWishlistComingSoon),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.rate_review,
                  title: l10n.accountReviews,
                  subtitle: l10n.accountReviewsSubtitle,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.accountReviewsComingSoon),
                      ),
                    );
                  },
                ),
              ],
            ),
            _buildMenuSection(
              context: context,
              title: l10n.accountSettingsSection,
              items: [
                _MenuItem(
                  icon: Icons.location_on,
                  title: l10n.accountDeliveryAddresses,
                  subtitle: l10n.accountDeliveryAddressesSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressesPage()),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.payment,
                  title: l10n.accountPaymentMethods,
                  subtitle: l10n.accountPaymentMethodsSubtitle,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.accountPaymentMethodsComingSoon),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.settings,
                  title: l10n.accountSettings,
                  subtitle: l10n.accountSettingsSubtitle,
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
              context: context,
              title: l10n.accountSupportSection,
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: l10n.accountHelp,
                  subtitle: l10n.accountHelpSubtitle,
                  onTap: () {
                    _showHelpDialog(context);
                  },
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: l10n.accountAbout,
                  subtitle: l10n.accountAboutSubtitle,
                  onTap: () {
                    AppDialogs.showAbout(
                      context: context,
                      applicationName: l10n.appTitle,
                      applicationVersion: l10n.appVersion,
                      legalese: l10n.appLegalese,
                    );
                  },
                ),
              ],
            ),
            Padding(
              padding: AppTheme.padding,
              child: AppButton(
                label: l10n.settingsLogout,
                style: AppButtonStyle.danger,
                onPressed: () {
                  _showLogoutDialog(context);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: AppSpacing.insetsXxl,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          ClipOval(
            child: AppImage(
              path: AppImages.userProfilePlaceholder,
              width: AppSpacing.hero,
              height: AppSpacing.hero,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.accountUserName,
            style: AppTextStyles.titleLarge(context)
                .copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.accountUserEmail,
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.accountUserPhone,
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required BuildContext context,
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: AppTextStyles.strong(
              context,
              AppTextStyles.bodyLarge(context).copyWith(color: AppColors.primary),
            ),
          ),
        ),
        ...List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.title, style: AppTextStyles.bodyLarge(context)),
                subtitle: Text(
                  item.subtitle,
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios, size: AppSpacing.iconSm),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                Divider(height: AppSpacing.borderThin),
            ],
          );
        }),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = context.l10n;
    AppDialogs.showInfo(
      context: context,
      title: l10n.accountHelp,
      message: l10n.accountHelpMessage,
      closeLabel: l10n.commonClose,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = context.l10n;
    AppDialogs.showConfirmation(
      context: context,
      title: l10n.settingsLogoutConfirmTitle,
      message: l10n.accountLogoutConfirmMessage,
      confirmLabel: l10n.commonLogout,
      cancelLabel: l10n.commonCancel,
      onConfirm: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
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
