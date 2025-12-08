import 'package:flutter/material.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.configureSystemUI();
  runApp(const MorphyApp());
}

class MorphyApp extends StatelessWidget {
  const MorphyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morphy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CameraScreen(),
    );
  }
}
