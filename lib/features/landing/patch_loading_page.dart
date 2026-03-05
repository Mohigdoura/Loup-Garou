import 'package:flutter/material.dart';

class PatchLoadingScreen extends StatefulWidget {
  const PatchLoadingScreen({super.key});

  @override
  State<PatchLoadingScreen> createState() => _PatchLoadingScreenState();
}

class _PatchLoadingScreenState extends State<PatchLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fadeAnim = Tween(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A), // match your dark theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🐺 Your app icon or wolf emoji as placeholder
            const Text('🐺', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 32),
            const Text(
              'Loup Garou',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnim,
              child: const Text(
                'Getting latest updates...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
