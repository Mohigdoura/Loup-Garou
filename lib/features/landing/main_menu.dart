import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/providers/ad_provider.dart';

class MainMenu extends ConsumerStatefulWidget {
  const MainMenu({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainMenuState();
}

class _MainMenuState extends ConsumerState<MainMenu> {
  @override
  void initState() {
    super.initState();
    ref.read(adProvider.notifier).loadInterstitial();
    ref.read(adProvider.notifier).loadRewarded();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Container(
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
              ...List.generate(30, (index) {
                return Positioned(
                  left: (index * 37) % MediaQuery.of(context).size.width,
                  top: (index * 53) % MediaQuery.of(context).size.height,
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
              }),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    Container(
                      width: 120,
                      height: 120,
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

                    Text(
                      l10n.appTitle,
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
                      l10n.appSubtitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),

                    const Spacer(flex: 1),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _MenuButton(
                        label: l10n.menuNewGame,
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => context.push('/name-selection'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _MenuButton(
                        label: l10n.menuShop,
                        icon: Icons.shopping_cart_outlined,
                        onPressed: () => context.push('/shop'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _MenuButton(
                        label: l10n.settings,
                        icon: Icons.settings,
                        onPressed: () => context.push('/settings'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _MenuButton(
                        label: l10n.menuRules,
                        icon: Icons.menu_book_rounded,
                        isSecondary: true,
                        onPressed: () => _showRulesDialog(context),
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRulesDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
        title: Text(
          l10n.rulesTitle,
          style: const TextStyle(
            color: Color(0xFFd4af37),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            l10n.rulesContent,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              l10n.rulesGotIt,
              style: const TextStyle(color: Color(0xFFd4af37)),
            ),
          ),
        ],
      ),
    );
  }
}

// _MenuButton and _MenuButtonState remain unchanged

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
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
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
