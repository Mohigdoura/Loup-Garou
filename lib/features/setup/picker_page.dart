import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/setup/providers/names_provider.dart';
import 'package:loup_garou/features/setup/providers/roles_provider.dart';
import 'package:loup_garou/models/game_character.dart';

class PickerPage extends ConsumerStatefulWidget {
  const PickerPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PickerPageState();
}

class _PickerPageState extends ConsumerState<PickerPage> {
  int currentIndex = 0;
  late GameCharacter currentRole = ref.watch(rolesProvider)[currentIndex];
  bool isShown = false;

  @override
  Widget build(BuildContext context) {
    final names = ref.watch(namesProvider);

    return Scaffold(
      body: Container(
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
            ...List.generate(20, (index) {
              return Positioned(
                left: (index * 41) % MediaQuery.of(context).size.width,
                top: (index * 67) % MediaQuery.of(context).size.height,
                child: Opacity(
                  opacity: 0.2 + (index % 3) * 0.15,
                  child: Container(
                    width: 2 + (index % 3).toDouble(),
                    height: 2 + (index % 3).toDouble(),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Role Assignment',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFd4af37),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Player ${currentIndex + 1} of ${names.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        // Progress indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFd4af37,
                                ).withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            '${currentIndex + 1}/${names.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0a0e27),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (currentIndex + 1) / names.length,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFd4af37,
                                ).withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Card
                    GestureDetector(
                      onTap: () {
                        if (!isShown) {
                          setState(() {
                            isShown = true;
                          });
                        }
                      },
                      child: AnimatedCardFlip(
                        role: currentRole,
                        name: names[currentIndex],
                        isShown: isShown,
                      ),
                    ),

                    const Spacer(),

                    // Instruction text or button
                    if (isShown)
                      _NextButton(
                        isLastPlayer: currentIndex >= names.length - 1,
                        onPressed: () {
                          if (currentIndex < names.length - 1) {
                            setState(() {
                              isShown = false;
                              currentIndex++;
                            });

                            Future.delayed(
                              const Duration(milliseconds: 600),
                              () {
                                setState(() {
                                  currentRole = ref.watch(
                                    rolesProvider,
                                  )[currentIndex];
                                });
                              },
                            );
                          } else {
                            context.pushReplacement("/give-narrator");
                          }
                        },
                      )
                    else
                      SizedBox(height: 64),

                    const SizedBox(height: 16),

                    if (kDebugMode)
                      TextButton(
                        onPressed: () {
                          context.pushReplacement("/give-narrator");
                        },
                        child: Text(
                          "Skip to game",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatefulWidget {
  final bool isLastPlayer;
  final VoidCallback onPressed;

  const _NextButton({required this.isLastPlayer, required this.onPressed});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 18),
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
              Text(
                widget.isLastPlayer ? 'DONE' : 'NEXT PLAYER',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFF0a0e27),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                widget.isLastPlayer ? Icons.check_circle : Icons.arrow_forward,
                color: const Color(0xFF0a0e27),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedCardFlip extends StatefulWidget {
  final GameCharacter role;
  final String name;
  final bool isShown;

  const AnimatedCardFlip({
    super.key,
    required this.role,
    required this.name,
    required this.isShown,
  });

  @override
  State<AnimatedCardFlip> createState() => _AnimatedCardFlipState();
}

class _AnimatedCardFlipState extends State<AnimatedCardFlip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedCardFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShown != oldWidget.isShown) {
      if (widget.isShown) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else if (widget.role != oldWidget.role && !widget.isShown) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        final isReversed = angle > pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isReversed
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildFrontCard(),
                )
              : _buildBackCard(),
        );
      },
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: 340,
      height: 460,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFd4af37).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFd4af37).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFf5e6d3),
                  const Color(0xFFd4af37).withValues(alpha: 0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFd4af37).withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(Icons.person, size: 48, color: const Color(0xFF0a0e27)),
          ),
          const SizedBox(height: 24),
          Text(
            widget.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFd4af37),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFd4af37).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to reveal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: 340,
      height: 460,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFd4af37), Color(0xFFf5e6d3), Color(0xFFd4af37)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFd4af37).withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
          ),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Role icon/badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFd4af37).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  _getRoleIcon(widget.role.name),
                  size: 64,
                  color: const Color(0xFFd4af37),
                ),
              ),

              const SizedBox(height: 24),

              // Role name
              Text(
                widget.role.name,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4af37),
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Divider
              Container(
                width: 80,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFd4af37),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Ability
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFd4af37).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'ABILITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: const Color(0xFFd4af37).withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.role.ability,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'werewolf':
      case 'loup-garou':
        return Icons.nightlight_round;
      case 'seer':
      case 'voyante':
        return Icons.visibility;
      case 'protector':
      case 'guardian':
      case 'salvateur':
        return Icons.shield;
      case 'witch':
      case 'sorcière':
        return Icons.auto_fix_high;
      case 'hunter':
      case 'chasseur':
        return Icons.gps_fixed;
      case 'ancient':
      case 'ancien':
        return Icons.account_balance;
      default:
        return Icons.person;
    }
  }
}
