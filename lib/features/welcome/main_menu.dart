import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/setup/players_selection_page.dart';
import 'package:loup_garou/features/shop/shop_page.dart';

class MainMenu extends ConsumerStatefulWidget {
  const MainMenu({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainMenuState();
}

class _MainMenuState extends ConsumerState<MainMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0a0e27),
              const Color(0xFF1a1f3a),
              const Color(0xFF2d1b3d),
            ],
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
                      opacity: (0.2 + (index % 3) * 0.2) * _fadeAnimation.value,
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
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Moon icon
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(12),
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
                      child: Image.asset('assets/wolf_nobg.png'),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'LOUP GAROU',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [Color(0xFFf5e6d3), Color(0xFFd4af37)],
                          ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
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
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'The Werewolf Game',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Start button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MenuButton(
                              label: 'NEW GAME',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlayersSelectionPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _MenuButton(
                              label: 'Shop',
                              icon: Icons.shopping_cart_outlined,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShopPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _MenuButton(
                        label: 'RULES',
                        icon: Icons.menu_book_rounded,
                        isSecondary: true,
                        onPressed: () {
                          _showRulesDialog(context);
                        },
                      ),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFd4af37).withValues(alpha: 0.3),
          ),
        ),
        title: const Text(
          'How to Play',
          style: TextStyle(
            color: Color(0xFFd4af37),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            '🌙 OBJECTIVE\n'
            'Village team: Eliminate all werewolves\n'
            'Werewolf team: Outnumber the villagers\n\n'
            '🌓 GAME FLOW\n'
            '1. Night Phase: Special roles act\n'
            '2. Day Phase: Discuss and vote\n'
            '3. Repeat until one team wins\n\n'
            '🐺 ROLES\n'
            'Werewolf: Kills villagers at night\n'
            'Seer: Sees one player\'s alignment\n'
            'Protector: Guards one player\n'
            'Witch: One heal, one poison\n'
            'Hunter: Kills a wolf when eliminated\n'
            'Ancient: 2 lives, sets talking order',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(color: Color(0xFFd4af37)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSecondary;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.isSecondary
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
                  ),
            border: widget.isSecondary
                ? Border.all(
                    color: const Color(0xFFd4af37).withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.isSecondary
                ? null
                : [
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
              Icon(
                widget.icon,
                color: widget.isSecondary
                    ? const Color(0xFFd4af37)
                    : const Color(0xFF0a0e27),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: widget.isSecondary
                      ? const Color(0xFFd4af37)
                      : const Color(0xFF0a0e27),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
