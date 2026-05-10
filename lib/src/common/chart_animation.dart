import 'package:flutter/material.dart';

/// Controls how a chart animates when first displayed or when data changes.
///
/// Pass a [ChartAnimation] to any chart widget to configure the speed
/// and easing curve of the reveal animation.
///
/// Example:
/// ```dart
/// // Slow, elegant reveal (default)
/// ChartAnimation.elegant()
///
/// // Snappy, quick reveal
/// ChartAnimation.snappy()
///
/// // No animation at all
/// ChartAnimation.none()
///
/// // Fully custom
/// ChartAnimation(
///   duration: Duration(milliseconds: 800),
///   curve: Curves.easeInOutCubic,
/// )
/// ```
class ChartAnimation {
  /// Duration of the reveal animation.
  final Duration duration;

  /// Easing curve applied to the animation.
  final Curve curve;

  /// Whether animation is enabled at all.
  /// When false, chart renders instantly at full state.
  final bool enabled;

  const ChartAnimation({
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.enabled = true,
  });

  // ─── Presets ─────────────────────────────────────────────────────────────

  /// Slow, elegant reveal. Great for dashboards and first impressions.
  /// Duration: 1200ms — Curve: easeOutCubic
  factory ChartAnimation.elegant() => const ChartAnimation(
        duration: Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        enabled: true,
      );

  /// Snappy, energetic reveal. Great for frequently updated data.
  /// Duration: 400ms — Curve: easeOutBack
  factory ChartAnimation.snappy() => const ChartAnimation(
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        enabled: true,
      );

  /// Bouncy spring-like reveal. Great for playful UIs.
  /// Duration: 800ms — Curve: elasticOut
  factory ChartAnimation.bouncy() => const ChartAnimation(
        duration: Duration(milliseconds: 800),
        curve: Curves.elasticOut,
        enabled: true,
      );

  /// No animation — chart renders instantly at full state.
  factory ChartAnimation.none() => const ChartAnimation(
        duration: Duration(milliseconds: 0),
        curve: Curves.linear,
        enabled: false,
      );
}

/// A mixin that provides animation controller lifecycle management
/// to any chart [State] class.
///
/// Apply this mixin to your chart's State, then call [initAnimation]
/// inside [initState] and use [animationValue] inside your painter.
///
/// Example:
/// ```dart
/// class _FlBarChartState extends State<FlBarChart>
///     with SingleTickerProviderStateMixin, ChartAnimationMixin {
///
///   @override
///   void initState() {
///     super.initState();
///     initAnimation(widget.animation, this);
///   }
///
///   @override
///   void dispose() {
///     disposeAnimation();
///     super.dispose();
///   }
/// }
/// ```
mixin ChartAnimationMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Current animation progress value from `0.0` (start) to `1.0` (complete).
  /// Use this value in your [CustomPainter] to scale drawing progress.
  double get animationValue => _animation.value;

  /// Initializes the animation controller and starts the animation.
  ///
  /// Call this inside [initState]. Pass the widget's [ChartAnimation] config
  /// and the [TickerProvider] (always `this` when using
  /// [SingleTickerProviderStateMixin]).
  void initAnimation(ChartAnimation config, TickerProvider vsync) {
    _controller = AnimationController(
      duration: config.enabled ? config.duration : Duration.zero,
      vsync: vsync,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: config.curve,
    )..addListener(() => setState(() {}));

    if (config.enabled) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  /// Restarts the animation from the beginning.
  ///
  /// Call this when chart data changes and you want to re-animate.
  void replayAnimation() {
    _controller.forward(from: 0.0);
  }

  /// Disposes the animation controller. Always call inside [dispose].
  void disposeAnimation() {
    _controller.dispose();
  }
}
