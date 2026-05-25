import 'package:flutter/material.dart';

import '../../../widgets/BottomNavigationBar/bottom_navigation_bar.dart';

class CategoriesBottomNavigation extends StatelessWidget {
  const CategoriesBottomNavigation({super.key, this.onSelected});

  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavigationBar(onIconPresedCallback: onSelected);
  }
}
