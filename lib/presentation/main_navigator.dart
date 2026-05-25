import 'package:flutter/material.dart';
import '../../models/data.dart';
import '../widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'cart_tab/shopping_cart_screen.dart';
import 'home_tab/home_page.dart';
import 'categories_tab/categories_page.dart';
import 'profile/profile_page.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key, this.title, this.initialTabIndex});

  final String? title;
  final int? initialTabIndex;

  static bool switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigatorState>();
    if (state == null) return false;
    state.switchToTab(index);
    return true;
  }

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  late int currentIndex;
  
  static const int accountTabIndex = 3;
  late List<Widget> pages;
  static const int homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = _normalizeTabIndex(widget.initialTabIndex);
    pages = [MyHomePage(), CategoriesPage(), ShoppingCartScreen(), ProfilePage()];
  }

  int _normalizeTabIndex(int? index) {
    final candidate = index ?? homeTabIndex;
    if (candidate < homeTabIndex ||
        candidate > accountTabIndex) {
      return homeTabIndex;
    }
    return candidate;
  }

  void onBottomIconPressed(int index) {
    switchToTab(index);
  }

  void switchToTab(int index) {
    final safeIndex = _normalizeTabIndex(index);
    if (safeIndex == currentIndex) return;
    setState(() {
      currentIndex = safeIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          switchInCurve: Curves.easeInToLinear,
          switchOutCurve: Curves.easeOutBack,
          child: pages[currentIndex],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ValueListenableBuilder<int>(
          valueListenable: AppData.cartCountNotifier,
          builder: (context, cartItemCount, _) => CustomBottomNavigationBar(
            onIconPresedCallback: onBottomIconPressed,
            //cartBadgeCount: cartItemCount,
          ),
        ),
      ),
    );
  }
}
