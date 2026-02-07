import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';
import 'package:loup_garou/features/setup/widgets/role_card.dart';
import 'package:loup_garou/providers/ad_provider.dart';
import 'package:loup_garou/features/setup/providers/names_provider.dart';
import 'package:loup_garou/features/setup/providers/roles_provider.dart';
import 'package:loup_garou/models/game_character.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;

  @override
  void initState() {
    super.initState();
    ref.read(adProvider.notifier).loadInterstitial();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetTotal = ref.read(namesProvider).length;
      ref.read(roleSelectionProvider.notifier).setTargetTotal(targetTotal);
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _startGame() {
    final selection = ref.read(roleSelectionProvider);
    ref
        .read(rolesProvider.notifier)
        .buildFromSelection(selection.selectedCounts);
    ref.read(gameStateProvider.notifier).resetGame();
    ref.read(rolesProvider).shuffle();
    context.push("/picker");
  }

  void _increment(GameCharacter role) {
    ref.read(roleSelectionProvider.notifier).increment(role);
    _progressAnimationController.forward(from: 0);
  }

  void _decrement(GameCharacter role) {
    ref.read(roleSelectionProvider.notifier).decrement(role);
    _progressAnimationController.forward(from: 0);
  }

  Color _getTeamColor(Team team) {
    switch (team) {
      case Team.wolves:
        return Colors.red.shade700;
      case Team.village:
        return Colors.blue.shade600;
      case Team.solo:
        return Colors.purple.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableRoles = ref
        .watch(rolesProvider.notifier)
        .getAllAvailableRoles();
    final selection = ref.watch(roleSelectionProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFd4af37),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Select Roles',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFd4af37),
                      ),
                    ),
                    const Spacer(),
                    // Progress indicator
                    SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${selection.currentTotal}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFd4af37),
                                ),
                              ),
                              Text(
                                ' / ${selection.targetTotal}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _progressAnimationController,
                                  builder: (context, child) {
                                    final double progress =
                                        selection.targetTotal > 0
                                        ? selection.currentTotal /
                                              selection.targetTotal
                                        : 0;
                                    return FractionallySizedBox(
                                      widthFactor: progress,
                                      child: Container(
                                        height: 12,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: selection.isComplete
                                                ? [
                                                    Colors.green.shade400,
                                                    Colors.green.shade600,
                                                  ]
                                                : [
                                                    const Color(0xFFd4af37),
                                                    const Color(0xFFf5e6d3),
                                                  ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  (selection.isComplete
                                                          ? Colors.green
                                                          : const Color(
                                                              0xFFd4af37,
                                                            ))
                                                      .withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Roles list
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: availableRoles.length,
                  itemBuilder: (context, index) {
                    final role = availableRoles[index];

                    return RoleCard(
                      role: role,
                      count: selection.getCount(role),
                      isSelected: selection.isSelected(role),
                      canIncrement: selection.canIncrement(),
                      canDecrement: selection.canDecrement(role),
                      teamColor: _getTeamColor(role.team),
                      onIncrement: () => _increment(role),
                      onDecrement: () => _decrement(role),
                    );
                  },
                ),
              ),

              // Bottom button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF0a0e27).withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: GestureDetector(
                    onTap: selection.isComplete ? _startGame : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: selection.isComplete
                            ? const LinearGradient(
                                colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
                              )
                            : null,
                        color: !selection.isComplete
                            ? Colors.grey.withValues(alpha: 0.2)
                            : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: selection.isComplete
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFd4af37,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selection.isComplete
                                ? 'START GAME'
                                : 'SELECT ${selection.remainingSlots} MORE ${selection.remainingSlots == 1 ? "ROLE" : "ROLES"}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: selection.isComplete
                                  ? const Color(0xFF0a0e27)
                                  : Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          if (selection.isComplete) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.play_arrow,
                              color: Color(0xFF0a0e27),
                            ),
                          ],
                        ],
                      ),
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
