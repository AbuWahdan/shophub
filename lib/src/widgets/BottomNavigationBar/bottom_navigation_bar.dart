import 'package:flutter/material.dart';

import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/app_text_styles.dart';
import 'bottom_curved_painter.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int)? onIconPresedCallback;
  final int cartBadgeCount;
  const CustomBottomNavigationBar({
    super.key,
    this.onIconPresedCallback,
    this.cartBadgeCount = 0,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _xController;
  late AnimationController _yController;
  @override
  void initState() {
    _xController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    );
    _yController = AnimationController(
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    );

    Listenable.merge([_xController, _yController]).addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _xController.value =
        _indexToPosition(_selectedIndex) / MediaQuery.of(context).size.width;
    _yController.value = 1.0;

    super.didChangeDependencies();
  }

  double _indexToPosition(int index) {
    // Calculate button positions based off of their
    // index (works with `MainAxisAlignment.spaceAround`)
    const buttonCount = 4;
    final appWidth = MediaQuery.of(context).size.width;
    final buttonsWidth = _getButtonContainerWidth();
    final startX = (appWidth - buttonsWidth) / 2;
    final effectiveIndex = _resolveIndexForDirection(index, buttonCount);
    return startX +
        effectiveIndex.toDouble() * buttonsWidth / buttonCount +
        buttonsWidth / (buttonCount * 2.0);
  }

  int _resolveIndexForDirection(int index, int buttonCount) {
    final direction = Directionality.of(context);
    if (direction == TextDirection.rtl) {
      return buttonCount - 1 - index;
    }
    return index;
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  Widget _icon(IconData icon, bool isEnable, int index) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusPill)),
        onTap: () {
          _handlePressed(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          alignment: isEnable ? Alignment.topCenter : Alignment.center,
          child: AnimatedContainer(
            height: isEnable ? AppSpacing.jumbo : AppSpacing.xl,
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isEnable
                  ? AppColors.accentOrange
                  : Theme.of(context).colorScheme.surface,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: isEnable
                      ? AppColors.highlightSoft
                      : Theme.of(context).colorScheme.surface,
                  blurRadius: AppSpacing.jumbo,
                  spreadRadius: AppSpacing.sm,
                  offset: const Offset(AppSpacing.sm, AppSpacing.sm),
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Opacity(
                  opacity: isEnable ? _yController.value : 1,
                  child: Icon(
                    icon,
                    color: isEnable
                        ? AppColors.white
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                // Cart badge
                if (index == 2 && widget.cartBadgeCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: AppSpacing.xl,
                      height: AppSpacing.xl,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.cartBadgeCount > 99
                              ? '99+'
                              : widget.cartBadgeCount.toString(),
                          style: AppTextStyles.labelSmall(context)
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final inCurve = ElasticOutCurve(0.38);
    return CustomPaint(
      painter: BackgroundCurvePainter(
        _xController.value * MediaQuery.of(context).size.width,
        Tween<double>(
          begin: Curves.easeInExpo.transform(_yController.value),
          end: inCurve.transform(_yController.value),
        ).transform(_yController.velocity.sign * 0.5 + 0.5),
        Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  double _getButtonContainerWidth() {
    double width = MediaQuery.of(context).size.width;
    if (width > AppSpacing.navMaxWidth) {
      width = AppSpacing.navMaxWidth;
    }
    return width;
  }

  void _handlePressed(int index) {
    if (_selectedIndex == index || _xController.isAnimating) return;
    widget.onIconPresedCallback?.call(index);
    setState(() {
      _selectedIndex = index;
    });

    _yController.value = 1.0;
    _xController.animateTo(
      _indexToPosition(index) / MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 620),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      _yController.animateTo(1.0, duration: const Duration(milliseconds: 1200));
    });
    _yController.animateTo(0.0, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;
    final height = AppSpacing.navHeight;
    return SizedBox(
      width: appSize.width,
      height: AppSpacing.navHeight,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            width: appSize.width,
            height: height - AppSpacing.sm,
            child: _buildBackground(),
          ),
          Positioned(
            left: (appSize.width - _getButtonContainerWidth()) / 2,
            top: 0,
            width: _getButtonContainerWidth(),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _icon(Icons.home, _selectedIndex == 0, 0),
                _icon(Icons.category, _selectedIndex == 1, 1),
                _icon(Icons.card_travel, _selectedIndex == 2, 2),
                _icon(Icons.person, _selectedIndex == 3, 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
