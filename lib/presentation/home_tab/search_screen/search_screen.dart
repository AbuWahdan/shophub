import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/search_controller.dart' as sc;
import '../../../design/app_colors.dart';
import '../../../design/app_spacing.dart';
import '../../../design/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product/product_model.dart';
import '../../../models/search_history_model.dart';
import '../../../models/search_result_model.dart';
import '../../../repositories/search_repository.dart';
import '../../../widgets/product_card/product_card.dart';

/// Opens the full-screen search UI.
///
/// Registers its own [SearchController] scoped to this route; it is
/// automatically disposed when the screen is popped.
///
/// Usage from Home / Categories tab:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => SearchScreen(username: currentUser.username),
/// ));
/// ```
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      sc.SearchController(repository: SearchRepository()),
      tag: 'search_screen',
      permanent: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initForUser(username);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _SearchAppBar(controller: controller),
      body: _SearchBody(controller: controller),
    );
  }}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar with search field
// ─────────────────────────────────────────────────────────────────────────────

class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({required this.controller});

  final sc.SearchController controller;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: AppSpacing.md),
        child: _SearchField(controller: controller),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final sc.SearchController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: controller.textController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.homeSearchHint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
        suffixIcon: Obx(() {
          final q = controller.query.value;

          if (q.isEmpty) return const SizedBox.shrink();

          return IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: controller.clearSearch,
          );
        }),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: controller.onFieldFocused,
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          controller.onHistoryItemTapped(
            SearchHistoryModel(
              id: -1,
              searchText: value.trim(),
              searchType: 'PRODUCT',
            ),
          );
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — switches between: history panel, loading, error, results, empty
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.controller});

  final sc.SearchController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show history overlay when field is short/empty and focused.
      if (controller.showHistory.value) {
        return _HistoryPanel(controller: controller);
      }

      // Searching spinner.
      if (controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      // Error state.
      if (controller.searchError.value != null) {
        return _SearchErrorView(
          onRetry: () => controller
              .onHistoryItemTapped(
            SearchHistoryModel(
              id: -1,
              searchText: controller.query.value,
              searchType: 'PRODUCT',
            ),
          ),
        );
      }

      // Results.
      if (controller.results.isNotEmpty) {
        return _ResultsGrid(results: controller.results);
      }

      // Empty results for a non-empty query.
      if (controller.query.value.trim().isNotEmpty) {
        return _EmptyResults(query: controller.query.value);
      }

      // Default idle state (query too short, no focus event yet).
      return const _IdlePlaceholder();
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History panel
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.controller});

  final sc.SearchController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Obx(() {
      if (controller.isHistoryLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }

      if (controller.history.isEmpty) {
        return Padding(
          padding: AppSpacing.insetsMd,
          child: Center(
            child: Text(
              l10n.noSearchHistory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentSearches,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                // Clear all button.
                Obx(
                      () => TextButton(
                    onPressed: controller.isClearingHistory.value
                        ? null
                        : controller.clearAllHistory,
                    child: Text(
                      l10n.clearAll,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // History list.
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: controller.history.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
              itemBuilder: (_, index) {
                final item = controller.history[index];
                return _HistoryTile(
                  item: item,
                  onTap: () => controller.onHistoryItemTapped(item),
                  onDelete: () => controller.deleteHistoryItem(item),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  final SearchHistoryModel item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.history_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
      title: Text(
        item.searchText,
        style: AppTextStyles.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded, size: 18),
        color: AppColors.textHint,
        onPressed: onDelete,
        tooltip: 'Remove',
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 0,
      ),
      dense: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results grid — reuses existing ProductCard
// ─────────────────────────────────────────────────────────────────────────────

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.results});

  final List<SearchResultModel> results;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.insetsMd,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
      ),
      itemCount: results.length,
      itemBuilder: (_, index) {
        final item = results[index];
        // Map SearchResultModel → ProductModel so ProductCard is reused as-is.
        return ProductCard(product: _toProductModel(item));
      },
    );
  }

  /// Converts a [SearchResultModel] to the shared [ProductModel] that
  /// [ProductCard] already knows how to render.
  ProductModel _toProductModel(SearchResultModel item) {
    return ProductModel(
      id: item.id,
      detId: item.detId,
      name: item.itemName,
      description: item.itemDesc,
      basePrice: item.itemPrice,
      baseStock: item.itemQty,
      primaryImageUrl: item.itemImgUrl ?? '',
      categoryId: item.catId,
      category: item.category,
      createdBy: item.itemOwner ,
      itemOwner: item.itemOwner,
      isActive: item.isActive ? 1 : 0,
      rating: item.avgRating,
      finalPrice: item.finalPrice,

      // Optional fields if available on item
      discountPrice: item.itemDiscount > 0
          ? item.finalPrice
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State placeholders
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 72,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.noResultsForQuery(query),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.insetsMd,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 72,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.errorLoadingProducts,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.manage_search_rounded,
            size: 72,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.searchPrompt,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}