import 'package:flutter/material.dart';

/// Morphy App Color Palette
/// Modern, Instagram-like colors with semi-transparent overlays
class AppColors {
  AppColors._();

  // Primary background (dark mode)
  static const Color background = Color(0xFF0A0A0A);
  static const Color backgroundSecondary = Color(0xFF1A1A1A);

  // Overlays & Panels
  static const Color overlayDark = Color(0x99000000);
  static const Color overlayLight = Color(0x33FFFFFF);
  static const Color panelBackground = Color(0xCC1A1A1A);

  // Accent colors
  static const Color primary = Color(0xFF8B5CF6); // Vibrant purple
  static const Color secondary = Color(0xFFEC4899); // Pink accent
  static const Color accent = Color(0xFF06B6D4); // Cyan accent

  // Recording & Action
  static const Color recording = Color(0xFFEF4444); // Red for recording
  static const Color recordingGlow = Color(0x66EF4444);

  // Text & Icons
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color iconActive = Color(0xFFFFFFFF);
  static const Color iconInactive = Color(0x99FFFFFF);

  // Filter selector
  static const Color filterSelected = Color(0xFFFFFFFF);
  static const Color filterUnselected = Color(0x66FFFFFF);
  static const Color filterHighlight = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient cameraOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x66000000),
      Color(0x00000000),
      Color(0x00000000),
      Color(0x66000000),
    ],
    stops: [0.0, 0.2, 0.8, 1.0],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF06B6D4)],
  );

  // Camera placeholder gradient (for demo without actual camera)
  static const LinearGradient cameraPlaceholder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
  );
}
