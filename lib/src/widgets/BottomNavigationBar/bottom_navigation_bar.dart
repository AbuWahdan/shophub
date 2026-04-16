import 'package:flutter/material.dart';

import '../../design/app_text_styles.dart';
import '../../l10n/l10n.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int)? onIconPresedCallback;
  final int cartBadgeCount;

  const CustomBottomNavigationBar({
    super.key,
    this.onIconPresedCallback,
    this.cartBadgeCount = 0,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (Icons.home_rounded, l10n.navHome),
      (Icons.category_rounded, l10n.navCategories),
      (Icons.shopping_bag_rounded, l10n.navCart),
      (Icons.person_rounded, l10n.navAccount),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [AppShadows.topBarShadow],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.navHeight,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _selectedIndex == index;
              final (icon, label) = items[index];
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (_selectedIndex == index) return;
                    setState(() => _selectedIndex = index);
                    widget.onIconPresedCallback?.call(index);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: AppSpacing.sm,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: selected ? AppSpacing.xl : 0,
                          height: AppSpacing.xs,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                icon,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textHint,
                              ),
                              if (index == 2 && widget.cartBadgeCount > 0)
                                Positioned(
                                  right: -8,
                                  top: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                    ),
                                    height: AppSpacing.md,
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.full,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        widget.cartBadgeCount > 99
                                            ? '99+'
                                            : widget.cartBadgeCount.toString(),
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textOnPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            label,
                            style: AppTextStyles.caption.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textHint,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
