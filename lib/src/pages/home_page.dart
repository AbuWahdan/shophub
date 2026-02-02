import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import '../design/app_text_styles.dart';
import '../l10n/l10n.dart';
import '../model/data.dart';
import '../themes/theme.dart';
import '../widgets/extentions.dart';
import '../widgets/product_card.dart';
import '../widgets/product_icon.dart';

class MyHomePage extends StatefulWidget {
  final Function(int)? onCartUpdated;
  const MyHomePage({super.key, this.title, this.onCartUpdated});

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _icon(IconData icon, {Color? color}) {
    return Container(
      padding: AppSpacing.insetsSm,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: AppTheme.shadow,
      ),
      child: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
    ).ripple(() {}, borderRadius: BorderRadius.all(Radius.circular(13)));
  }

  Widget _categoryWidget() {
    return Container(
      margin: AppSpacing.vertical(AppSpacing.sm),
      width: AppTheme.fullWidth(context),
      height: AppSpacing.imageMd,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: AppData.categoryList
            .map(
              (category) => ProductIcon(
                model: category,
                label: _categoryLabel(context, category.name ?? ''),
                onSelected: (model) {
                  setState(() {
                    for (var item in AppData.categoryList) {
                      item.isSelected = false;
                    }
                    model.isSelected = true;
                  });
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _productWidget() {
    return Container(
      margin: AppSpacing.vertical(AppSpacing.sm),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.lg,
        ),
        itemCount: AppData.productList.length,
        itemBuilder: (context, index) {
          final product = AppData.productList[index];
          return ProductCard(
            product: product,
            onSelected: (model) {
              setState(() {
                for (var item in AppData.productList) {
                  item.isSelected = false;
                }
                model.isSelected = true;
              });
            },
          );
        },
      ),
    );
  }

  Widget _search() {
    return Container(
      margin: AppTheme.padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: AppSpacing.buttonSm,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context.l10n.homeSearchHint,
                  hintStyle: AppTextStyles.bodySmall(context),
                  contentPadding: AppSpacing.only(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    top: AppSpacing.xs,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          _icon(Icons.filter_list,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - AppSpacing.massive,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        dragStartBehavior: DragStartBehavior.down,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_search(), _categoryWidget(), _productWidget()],
        ),
      ),
    );
  }

  String _categoryLabel(BuildContext context, String category) {
    final l10n = context.l10n;
    switch (category) {
      case 'All':
        return l10n.categoryAll;
      case 'Sneakers':
        return l10n.categorySneakers;
      case 'Jackets':
        return l10n.categoryJackets;
      case 'Watches':
        return l10n.categoryWatches;
      case 'Electronics':
        return l10n.categoryElectronics;
      case 'Clothing':
        return l10n.categoryClothing;
      default:
        return category;
    }
  }
}
