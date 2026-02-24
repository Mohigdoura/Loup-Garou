import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GiveToNarratorPage extends StatefulWidget {
  const GiveToNarratorPage({super.key});

  @override
  State<GiveToNarratorPage> createState() => _GiveToNarratorPageState();
}

class _GiveToNarratorPageState extends State<GiveToNarratorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
            ),
          ),
          child: Stack(
            children: [
              // Animated background stars
              ...List.generate(30, (index) {
                return Positioned(
                  left: (index * 37) % MediaQuery.of(context).size.width,
                  top: (index * 53) % MediaQuery.of(context).size.height,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity:
                            (0.2 + (index % 3) * 0.2) * _fadeAnimation.value,
                        child: Container(
                          width: 2 + (index % 3).toDouble(),
                          height: 2 + (index % 3).toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

              // Main content
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Narrator icon with pulse animation
                        Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFf5e6d3),
                                const Color(0xFFd4af37).withValues(alpha: 0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFd4af37,
                                ).withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: Color(0xFF0a0e27),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          'Ready to Begin',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            foreground: Paint()
                              ..shader =
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFFf5e6d3),
                                      Color(0xFFd4af37),
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 400, 70),
                                  ),
                            shadows: [
                              Shadow(
                                color: const Color(
                                  0xFFd4af37,
                                ).withValues(alpha: 0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Instructions
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFFd4af37,
                              ).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.transfer_within_a_station,
                                size: 48,
                                color: const Color(0xFFd4af37),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Pass the phone to\nthe Narrator',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  height: 1.4,
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'The Narrator will guide the game\nthrough night and day phases',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 1),

                        // Start button
                        _StartGameButton(
                          onPressed: () {
                            context.pushReplacement("/game");
                          },
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartGameButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _StartGameButton({required this.onPressed});

  @override
  State<_StartGameButton> createState() => _StartGameButtonState();
}

class _StartGameButtonState extends State<_StartGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFd4af37).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF0a0e27),
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'START GAME',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFF0a0e27),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
