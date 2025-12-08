import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// Slide-up filter intensity control with expandable slider
class IntensitySlider extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double>? onChanged;

  const IntensitySlider({super.key, this.initialValue = 0.5, this.onChanged});

  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _snapController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  bool _isExpanded = false;
  late double _value;

  // Track haptic feedback state
  int? _activeHapticIndex;

  static const double _collapsedHeight = 60.0;
  static const double _expandedHeight = 220.0;
  static const double _sliderWidth = 60.0;
  static const double _snapThreshold = 0.05; // 5% snap range

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _snapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _heightAnimation =
        Tween<double>(begin: _collapsedHeight, end: _expandedHeight).animate(
          CurvedAnimation(
            parent: _expandController,
            curve: Curves.easeOutCubic,
          ),
        );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // If dragging up and not expanded, expand first
    if (!_isExpanded && details.delta.dy < -5) {
      _toggleExpand();
      return;
    }

    if (!_isExpanded) return;

    // Calculate new value based on drag
    final sliderHeight = _expandedHeight - _collapsedHeight - 40;
    final dragDelta = -details.delta.dy / sliderHeight;

    setState(() {
      _value = (_value + dragDelta).clamp(0.0, 1.0);
    });

    // Haptic feedback at key positions
    _checkHapticFeedback();

    widget.onChanged?.call(_value);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isExpanded) return;
    _snapToNearest();
  }

  void _snapToNearest() {
    double target = _value;
    bool shouldSnap = false;

    if ((_value - 0.0).abs() < _snapThreshold) {
      target = 0.0;
      shouldSnap = true;
    } else if ((_value - 0.5).abs() < _snapThreshold) {
      target = 0.5;
      shouldSnap = true;
    } else if ((_value - 1.0).abs() < _snapThreshold) {
      target = 1.0;
      shouldSnap = true;
    }

    if (shouldSnap) {
      HapticFeedback.mediumImpact(); // Stronger haptic for snap

      final start = _value;
      _snapController.reset();
      final animation = Tween<double>(begin: start, end: target).animate(
        CurvedAnimation(parent: _snapController, curve: Curves.easeOutBack),
      );

      animation.addListener(() {
        setState(() {
          _value = animation.value;
        });
        widget.onChanged?.call(_value);
      });

      _snapController.forward();
    }
  }

  void _checkHapticFeedback() {
    final checkpoints = [0.0, 0.5, 1.0];
    const threshold = 0.03; // Haptic zone size

    int? foundIndex;
    for (int i = 0; i < checkpoints.length; i++) {
      if ((_value - checkpoints[i]).abs() < threshold) {
        foundIndex = i;
        break;
      }
    }

    if (foundIndex != null) {
      // We are inside a checkpoint zone
      if (_activeHapticIndex != foundIndex) {
        // We just entered this zone
        HapticFeedback.selectionClick();
        _activeHapticIndex = foundIndex;
      }
    } else {
      // We are outside any checkpoint zone
      _activeHapticIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleExpand,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _expandController,
        builder: (context, child) {
          return Container(
            width: _sliderWidth,
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: _isExpanded
                  ? AppColors.panelBackground
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Slider track (visible when expanded)
                Expanded(
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _buildSliderTrack(),
                  ),
                ),

                // Arrow indicator with larger hit area
                Container(
                  width: _sliderWidth,
                  height: 50,
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: AppColors.iconActive.withValues(alpha: 0.9),
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliderTrack() {
    // Only render track when it's visible and has enough space
    if (_opacityAnimation.value <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackHeight = constraints.maxHeight;
          final fillHeight = trackHeight * _value;

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background track
              Container(
                width: 8,
                height: trackHeight,
                decoration: BoxDecoration(
                  color: AppColors.overlayLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Filled portion
              AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width: 8,
                height: fillHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Thumb indicator
              Positioned(
                bottom: fillHeight - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textPrimary,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
