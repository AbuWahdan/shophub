import 'package:flutter/material.dart';
import 'package:sinwar_shoping/src/pages/shopping_cart_page.dart';

import '../widgets/BottomNavigationBar/bottom_navigation_bar.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.title});

  final String? title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  int cartItemCount = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      MyHomePage(onCartUpdated: _updateCartCount),
      CategoriesPage(),
      ShoppingCartPage(onCartUpdated: _updateCartCount),
      ProfilePage(),
    ];
  }

  void _updateCartCount(int count) {
    setState(() {
      cartItemCount = count;
    });
  }

  void onBottomIconPressed(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              switchInCurve: Curves.easeInToLinear,
              switchOutCurve: Curves.easeOutBack,
              child: pages[currentIndex],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CustomBottomNavigationBar(
                onIconPresedCallback: onBottomIconPressed,
                cartBadgeCount: cartItemCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
