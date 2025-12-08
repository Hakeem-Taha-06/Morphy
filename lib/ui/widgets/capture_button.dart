import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

/// Capture button with tap (photo) and long-press (video) functionality
/// Features: pulse animation, radial progress, color transition
class CaptureButton extends StatefulWidget {
  final VoidCallback? onTapCapture;
  final VoidCallback? onRecordingStart;
  final VoidCallback? onRecordingStop;
  final Duration maxRecordDuration;
  final List<Color>? filterColors;

  const CaptureButton({
    super.key,
    this.onTapCapture,
    this.onRecordingStart,
    this.onRecordingStop,
    this.maxRecordDuration = const Duration(seconds: 30),
    this.filterColors,
  });

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _recordingController;
  late AnimationController _scaleController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  // State
  bool _isRecording = false;
  Timer? _recordingTimer;

  // Dimensions
  static const double _outerSize = 80.0;
  static const double _ringWidth = 5.0;

  @override
  void initState() {
    super.initState();

    // Pulse animation for tap
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Recording progress animation
    _recordingController = AnimationController(
      duration: widget.maxRecordDuration,
      vsync: this,
    );
    _recordingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopRecording();
      }
    });

    // Scale animation for recording
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordingController.dispose();
    _scaleController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pulseController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pulseController.reverse();
    if (!_isRecording) {
      HapticFeedback.heavyImpact(); // Stronger click
      widget.onTapCapture?.call();
    }
  }

  void _onTapCancel() {
    _pulseController.reverse();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _startRecording();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _stopRecording();
  }

  void _startRecording() {
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
    });

    HapticFeedback.vibrate(); // Distinct vibration for recording start
    _scaleController.forward();
    _recordingController.forward(from: 0);
    widget.onRecordingStart?.call();
  }

  void _stopRecording() {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
    });

    HapticFeedback.lightImpact();
    _scaleController.reverse();
    _recordingController.stop();
    _recordingController.reset();
    widget.onRecordingStop?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _scaleAnimation,
          _recordingController,
        ]),
        builder: (context, child) {
          final scale = _pulseAnimation.value * _scaleAnimation.value;

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: _outerSize + 10,
              height: _outerSize + 10,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Recording progress ring
                  if (_isRecording)
                    SizedBox(
                      width: _outerSize + 8,
                      height: _outerSize + 8,
                      child: CircularProgressIndicator(
                        value: _recordingController.value,
                        strokeWidth: 4,
                        backgroundColor: AppColors.recording.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.recording,
                        ),
                      ),
                    ),

                  // Outer ring
                  Container(
                    width: _outerSize,
                    height: _outerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording
                            ? AppColors.recording.withValues(alpha: 0.8)
                            : AppColors.textPrimary,
                        width: _ringWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
