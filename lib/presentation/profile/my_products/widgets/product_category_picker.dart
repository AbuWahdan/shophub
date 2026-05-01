import 'package:flutter/material.dart';
import '../../../../data/categories_data.dart';
import '../../../../design/app_colors.dart';
import '../../../../design/app_spacing.dart';
import '../../../../design/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/category_model.dart';
import 'product_section_title.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Insert-mode: expandable tree picker
// ─────────────────────────────────────────────────────────────────────────────

/// Expandable tree-style category picker for the **Insert** screen.
class InsertCategoryPicker extends StatefulWidget {
  const InsertCategoryPicker({
    super.key,
    required this.selectedSubCategoryId,
    required this.isDisabled,
    required this.onSelected,
  });

  final int? selectedSubCategoryId;
  final bool isDisabled;
  final ValueChanged<int> onSelected;

  @override
  State<InsertCategoryPicker> createState() => _InsertCategoryPickerState();
}

class _InsertCategoryPickerState extends State<InsertCategoryPicker> {
  int? _expandedCategoryId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedName = widget.selectedSubCategoryId != null
        ? CategoriesData.getCategoryById(widget.selectedSubCategoryId!)?.name
        : null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: RichText(
              text: TextSpan(
                text: l10n.productCategory,
                style: Theme.of(context).textTheme.titleMedium,
                children: [
                  TextSpan(
                    text: ' *',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.error),
                  ),
                ],
              ),
            ),
            subtitle: selectedName != null ? Text(selectedName) : null,
            trailing: const Icon(Icons.arrow_drop_down),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CategoriesData.getMainCategories().length,
            itemBuilder: (_, index) {
              final main = CategoriesData.getMainCategories()[index];
              final isExpanded = _expandedCategoryId == main.id;

              return Column(
                children: [
                  ListTile(
                    title: Text(main.name),
                    trailing: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onTap: widget.isDisabled
                        ? null
                        : () => setState(() {
                      _expandedCategoryId =
                      isExpanded ? null : main.id;
                    }),
                  ),
                  if (isExpanded)
                    ...main.children.map((child) {
                      final isSelected =
                          widget.selectedSubCategoryId == child.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 32,
                          right: 16,
                        ),
                        title: Text(child.name),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                            color: AppColors.success)
                            : null,
                        tileColor: isSelected
                            ? AppColors.success.withValues(alpha: 0.1)
                            : null,
                        onTap: widget.isDisabled
                            ? null
                            : () => widget.onSelected(child.id),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit-mode: flat dropdown picker
// ─────────────────────────────────────────────────────────────────────────────

/// Flat dropdown category picker for the **Edit** screen.
class EditCategoryPicker extends StatelessWidget {
  const EditCategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.isDisabled,
    required this.onChanged,
  });

  final CategoryModel? selectedCategory;
  final bool isDisabled;
  final ValueChanged<CategoryModel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductSectionTitle(
          title: l10n.productCategory,
          icon: Icons.category_outlined,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: DropdownButtonFormField<CategoryModel>(
            value: selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.productCategory,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            items: CategoriesData.getAllCategoriesFlat()
                .map(
                  (c) => DropdownMenuItem<CategoryModel>(
                value: c,
                child: Text(
                  c.parentId == null ? c.name : '  - ${c.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            onChanged: isDisabled ? null : onChanged,
          ),
        ),
      ],
    );
  }
}