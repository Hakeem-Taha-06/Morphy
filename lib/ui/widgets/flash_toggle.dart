import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// Flash toggle button with scale/fade animation
class FlashToggle extends StatefulWidget {
  final bool initialState;
  final ValueChanged<bool>? onChanged;

  const FlashToggle({super.key, this.initialState = false, this.onChanged});

  @override
  State<FlashToggle> createState() => _FlashToggleState();
}

class _FlashToggleState extends State<FlashToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialState;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOn = !_isOn;
    });

    HapticFeedback.lightImpact();
    _controller.forward(from: 0);
    widget.onChanged?.call(_isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOn
                      ? AppColors.primary.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Icon(
                  _isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: _isOn ? AppColors.primary : AppColors.iconActive,
                  size: 26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
