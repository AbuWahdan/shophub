import 'package:flutter/material.dart';
import '../../../models/data.dart';
import '../../src/config/app_constants.dart';
import '../../src/widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import '../cart_tab/shopping_cart_page.dart';
import 'home_page.dart';
import '../categories_tab/categories_page.dart';
import '../profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.title, this.initialTabIndex});

  final String? title;
  final int? initialTabIndex;

  static bool switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainPageState>();
    if (state == null) return false;
    state.switchToTab(index);
    return true;
  }

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int currentIndex;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    currentIndex = _normalizeTabIndex(widget.initialTabIndex);
    pages = [MyHomePage(), CategoriesPage(), ShoppingCartPage(), ProfilePage()];
  }

  int _normalizeTabIndex(int? index) {
    final candidate = index ?? AppConstants.homeTabIndex;
    if (candidate < AppConstants.homeTabIndex ||
        candidate > AppConstants.accountTabIndex) {
      return AppConstants.homeTabIndex;
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
