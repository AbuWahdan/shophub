import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_images.dart';
import '../../core/config/route.dart';

import '../../core/app/app_theme.dart';
import '../../design/app_colors.dart';
import '../../design/app_radius.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';
import '../../widgets/dialogs/app_dialogs.dart';
import '../../widgets/widgets/app_image.dart';
import '../../core/state/auth_state.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthState>();
    final user = auth.user;
    final isLoggedIn = auth.isLoggedIn && user != null;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.insetsMd,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: AppImage(
                  path: AppImages.userProfilePlaceholder,
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isLoggedIn) ...[
                Text(
                  user.username.isEmpty ? l10n.accountUserName : user.username,
                  style: AppTextStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  user.email.isEmpty ? l10n.accountUserEmail : user.email,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    child: Text(l10n.loginSignIn),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              _buildMenuItem(
                context,
                Icons.shopping_bag,
                l10n.profileOrders,
                () {
                  Navigator.pushNamed(context, AppRoutes.orders);
                },
              ),
              _buildMenuItem(
                context,
                Icons.inventory_2_outlined,
                l10n.accountMyProducts,
                () {
                  Navigator.pushNamed(context, AppRoutes.myProducts);
                },
              ),
              _buildMenuItem(
                context,
                Icons.location_on,
                l10n.profileAddresses,
                () {
                  Navigator.pushNamed(context, AppRoutes.addresses);
                },
              ),
              _buildMenuItem(context, Icons.settings, l10n.profileSettings, () {
                Navigator.pushNamed(context, AppRoutes.settings);
              }),
              _buildMenuItem(
                context,
                Icons.add_business,
                l10n.insertProductMenu,
                () {
                  Navigator.pushNamed(context, AppRoutes.insertProduct);
                },
              ),
              _buildMenuItem(context, Icons.favorite, l10n.accountWishlist, () {
                Navigator.pushNamed(context, AppRoutes.wishlist);
              }),
              if (isLoggedIn)
                _buildMenuItem(context, Icons.logout, l10n.settingsLogout, () {
                  _showLogoutDialog(context);
                }),
            ],
          ),
        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: const Icon(Icons.arrow_forward_ios, size: AppSpacing.iconSm),
        onTap: onTap,
      ),
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
        context.read<AuthState>().logout().then((_) {
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        });
      },
    );
  }
}
