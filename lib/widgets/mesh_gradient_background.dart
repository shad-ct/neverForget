import 'dart:math';
import 'package:flutter/material.dart';

/// A background that displays a random wallpaper from the bundled assets,
/// covered by a subtle dark gradient to ensure text readability.
class MeshGradientBackground extends StatefulWidget {
  final Widget child;

  const MeshGradientBackground({super.key, required this.child});

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground> {
  static const List<String> _wallpapers = [
    'lib/wallpapers/image.png',
    'lib/wallpapers/image copy.png',
    'lib/wallpapers/image copy 2.png',
    'lib/wallpapers/image copy 3.png',
    'lib/wallpapers/image copy 4.png',
    'lib/wallpapers/image copy 5.png',
    'lib/wallpapers/image copy 6.png',
    'lib/wallpapers/image copy 7.png',
    'lib/wallpapers/image copy 8.png',
    'lib/wallpapers/image copy 9.png',
    'lib/wallpapers/image copy 10.png',
    'lib/wallpapers/image copy 11.png',
    'lib/wallpapers/image copy 12.png',
  ];

  // Pick a single random wallpaper per app session.
  static final String _selectedWallpaper = _wallpapers[Random().nextInt(_wallpapers.length)];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1A), // Fallback
        image: DecorationImage(
          image: ResizeImage(
            AssetImage(_selectedWallpaper),
            width: 800, // Drastically cuts memory usage and decode time
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // Darken the image so glassmorphism and text stand out clearly
            Colors.black.withValues(alpha: 0.6),
            BlendMode.darken,
          ),
        ),
      ),
      child: widget.child,
    );
  }
}
