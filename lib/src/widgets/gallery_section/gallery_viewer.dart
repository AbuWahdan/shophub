import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class GalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  static Future<void> show(
      BuildContext context, {
        required List<String> images,
        int initialIndex = 0,
      }) {
    HapticFeedback.lightImpact();
    return Navigator.of(context).push(
      _GalleryRoute(
        builder: (_) => GalleryViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer>
    with TickerProviderStateMixin {
  late final PageController _pageController;

  // Entry fade/scale
  late final AnimationController _entryController;
  late final Animation<double>   _bgOpacity;

  // Zoom animation — re-created each double-tap, disposed on completion
  AnimationController? _zoomController;

  int    _currentIndex = 0;
  double _dragOffsetY  = 0.0;

  final Map<int, TransformationController> _transformControllers = {};

  // ── Image rendering ───────────────────────────────────────────────────────

  /// Renders the correct widget for any image source:
  ///   • `/…`    → local device file  → [Image.file]
  ///   • `http…` → remote URL         → [Image.network]
  ///   • other   → bundled asset      → [Image.asset]
  Widget _buildImage(String path, {required BoxFit fit}) {
    const errorWidget = Icon(
      Icons.image_not_supported_outlined,
      color: Colors.white54,
      size: 48,
    );

    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: fit,
        width: double.infinity,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: double.infinity,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                  progress.expectedTotalBytes!
                  : null,
              color: Colors.white54,
            ),
          );
        },
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  TransformationController _controllerFor(int index) {
    return _transformControllers.putIfAbsent(
      index,
          () => TransformationController(),
    );
  }

  bool _isZoomedIn(int index) {
    final c = _transformControllers[index];
    if (c == null) return false;
    return c.value.getMaxScaleOnAxis() > 1.05;
  }

  bool get _zoomed => _isZoomedIn(_currentIndex);

  double get _dismissProgress => (_dragOffsetY.abs() / 300).clamp(0.0, 1.0);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _bgOpacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    _zoomController?.dispose();
    for (final c in _transformControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Dismiss ───────────────────────────────────────────────────────────────

  void _dismiss() {
    HapticFeedback.lightImpact();
    _entryController.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  // ── Vertical drag ─────────────────────────────────────────────────────────

  void _onVerticalDragUpdate(DragUpdateDetails d) =>
      setState(() => _dragOffsetY += d.delta.dy);

  void _onVerticalDragEnd(DragEndDetails d) {
    final velocity = d.velocity.pixelsPerSecond.dy.abs();
    if (_dragOffsetY.abs() > 90 || velocity > 400) {
      _dismiss();
    } else {
      setState(() => _dragOffsetY = 0.0);
    }
  }

  void _onVerticalDragCancel() => setState(() => _dragOffsetY = 0.0);

  // ── Double-tap zoom ───────────────────────────────────────────────────────

  void _onDoubleTap(int index, TapDownDetails details) {
    HapticFeedback.selectionClick();

    final tc   = _controllerFor(index);
    final from = tc.value.clone();
    final to   = _isZoomedIn(index)
        ? Matrix4.identity()
        : _zoomedMatrix(details.localPosition, scale: 2.5);

    _zoomController?.dispose();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    final anim = Matrix4Tween(begin: from, end: to).animate(
      CurvedAnimation(parent: _zoomController!, curve: Curves.easeInOut),
    );

    anim.addListener(() => tc.value = anim.value);

    _zoomController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {}); // refresh _zoomed → PageView physics update
      }
    });

    _zoomController!.forward();
  }

  Matrix4 _zoomedMatrix(Offset focalPoint, {required double scale}) {
    final dx = -focalPoint.dx * (scale - 1);
    final dy = -focalPoint.dy * (scale - 1);
    return Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _bgOpacity,
          builder: (context, child) {
            final alpha = _bgOpacity.value * (1 - _dismissProgress * 0.7);
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(alpha * 0.93),
                  ),
                ),
                Positioned(
                  top: -60,
                  right: -60,
                  child: Opacity(
                    opacity: alpha * 0.18,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (child != null) child,
              ],
            );
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        GestureDetector(
          onVerticalDragUpdate: _zoomed ? null : _onVerticalDragUpdate,
          onVerticalDragEnd:    _zoomed ? null : _onVerticalDragEnd,
          onVerticalDragCancel: _zoomed ? null : _onVerticalDragCancel,
          child: Transform.translate(
            offset: Offset(0, _dragOffsetY),
            child: Opacity(
              opacity: (1 - _dismissProgress * 0.65).clamp(0.0, 1.0),
              child: PageView.builder(
                controller: _pageController,
                physics: _zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: widget.images.length,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = i);
                },
                itemBuilder: (_, index) => _buildImagePage(index),
              ),
            ),
          ),
        ),

        Positioned(
          top: 0, left: 0, right: 0,
          child: _buildTopBar(),
        ),

        if (widget.images.length > 1)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(),
          ),
      ],
    );
  }

  Widget _buildImagePage(int index) {
    return GestureDetector(
      onDoubleTapDown: (d) => _onDoubleTap(index, d),
      onDoubleTap: () {}, // required for onDoubleTapDown to fire
      child: InteractiveViewer(
        transformationController: _controllerFor(index),
        minScale: 1.0,
        maxScale: 4.0,
        clipBehavior: Clip.none,
        panEnabled:   _isZoomedIn(index),
        scaleEnabled: false,
        child: Center(
          child: _buildImage(widget.images[index], fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical:   AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.images.length > 1)
              _GlassBadge(
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              )
            else
              const SizedBox.shrink(),

            GestureDetector(
              onTap: _dismiss,
              child: _GlassBadge(
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                'Double-tap to zoom  ·  Swipe down to close',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, _buildDot),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width:  isActive ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? AppColors.primary
            : Colors.white.withOpacity(0.35),
      ),
    );
  }
}

// ── Glass badge ───────────────────────────────────────────────────────────────

class _GlassBadge extends StatelessWidget {
  final Widget child;
  const _GlassBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}

// ── Custom page route (transparent background, fade transition) ───────────────

class _GalleryRoute extends PageRoute<void> {
  final WidgetBuilder builder;
  _GalleryRoute({required this.builder}) : super(fullscreenDialog: false);

  @override bool get opaque           => false;
  @override bool get maintainState    => true;
  @override bool get barrierDismissible => true;
  @override Color get barrierColor    => Colors.transparent;
  @override String? get barrierLabel  => null;

  @override
  Duration get transitionDuration        => const Duration(milliseconds: 300);
  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) =>
      builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) =>
      FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
}