import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/src/config/app_images.dart';
import 'package:sinwar_shoping/src/config/route.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../shared/dialogs/app_dialogs.dart';
import '../shared/widgets/app_image.dart';
import '../state/auth_state.dart';
import '../themes/theme.dart';

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
        padding: AppTheme.padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              _buildMenuItem(context, Icons.help_outline, l10n.profileHelp, () {
                _showHelpDialog(context);
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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

  void _showHelpDialog(BuildContext context) {
    final l10n = context.l10n;
    AppDialogs.showInfo(
      context: context,
      title: l10n.profileHelp,
      message: l10n.profileHelpMessage,
      closeLabel: l10n.commonClose,
    );
  }
}
