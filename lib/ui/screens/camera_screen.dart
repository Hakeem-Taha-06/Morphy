import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../widgets/filter_selector.dart';
import '../widgets/capture_button.dart';
import '../widgets/flash_toggle.dart';
import '../widgets/gender_indicator.dart';
import '../widgets/intensity_slider.dart';

/// Main camera screen with full UI overlay
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // Current filter state
  int _selectedFilterIndex = 0;
  double _filterIntensity = 0.5;
  bool _isFlashOn = false;
  bool _isRecording = false;

  // Get current filter
  FilterItem get _currentFilter => sampleFilters[_selectedFilterIndex];

  void _onFilterChanged(FilterItem filter, int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
    debugPrint('Filter changed to: ${filter.name}');
  }

  void _onIntensityChanged(double value) {
    setState(() {
      _filterIntensity = value;
    });
    debugPrint('Intensity: ${(value * 100).toInt()}%');
  }

  void _onFlashChanged(bool isOn) {
    setState(() {
      _isFlashOn = isOn;
    });
    debugPrint('Flash: ${isOn ? "ON" : "OFF"}');
  }

  void _onCapture() {
    debugPrint('📸 Photo captured!');
    // TODO: Implement photo capture
  }

  void _onRecordingStart() {
    setState(() {
      _isRecording = true;
    });
    debugPrint('🔴 Recording started');
    // TODO: Implement video recording start
  }

  void _onRecordingStop() {
    setState(() {
      _isRecording = false;
    });
    debugPrint('⏹️ Recording stopped');
    // TODO: Implement video recording stop
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: Camera preview placeholder
          _buildCameraPreview(),

          // Gradient overlay for better UI visibility
          _buildGradientOverlay(),

          // UI Overlays
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),

                // Spacer to push everything down
                const Spacer(),

                // Bottom Controls (Stack for overlapping elements)
                _buildBottomControls(),
              ],
            ),
          ),

          // Recording indicator
          if (_isRecording) _buildRecordingIndicator(),
        ],
      ),
    );
  }

  /// Camera preview placeholder (gradient background)
  Widget _buildCameraPreview() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cameraPlaceholder),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_outlined,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Preview',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gradient overlay for better visibility of UI elements
  Widget _buildGradientOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.cameraOverlayGradient,
        ),
      ),
    );
  }

  /// Top bar with gender indicator and flash toggle
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gender indicator (left)
          const GenderIndicator(gender: Gender.male),

          // App title (center)
          Text(
            'Morphy',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary.withValues(alpha: 0.9),
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),

          // Flash toggle (right)
          FlashToggle(initialState: _isFlashOn, onChanged: _onFlashChanged),
        ],
      ),
    );
  }

  /// Bottom controls with filter selector, intensity slider and capture button
  Widget _buildBottomControls() {
    // Height calculation:
    // Capture button size (approx 90) + padding (24) = 114
    // Slider expanded height (220) needs to fit
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Filter Selector (at bottom, same line as capture button)
          // Adjusted bottom padding to align center of filters with center of capture button
          // Capture button center is at bottom + 24 + 45 (half height) = 69px from bottom
          // Filter item height is approx 80px (54 circle + text)
          // We want center of circle (27px from top of item) to align with 69px
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: FilterSelector(
              initialIndex: _selectedFilterIndex,
              onFilterChanged: _onFilterChanged,
            ),
          ),

          // 2. Capture Button (Centered at bottom)
          Positioned(
            bottom: 48,
            child: CaptureButton(
              onTapCapture: _onCapture,
              onRecordingStart: _onRecordingStart,
              onRecordingStop: _onRecordingStop,
              filterColors: _currentFilter.colors,
            ),
          ),

          // 3. Intensity Slider (Centered above capture button)
          // Positioned higher up so the arrow sits above the button
          Positioned(
            bottom: 138,
            left: 0,
            right: 0,
            child: Center(
              child: IntensitySlider(
                initialValue: _filterIntensity,
                onChanged: _onIntensityChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recording indicator at top
  Widget _buildRecordingIndicator() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.recording.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'REC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
