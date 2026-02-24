import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';
import 'package:loup_garou/features/Game/widgets/game_over_dialog.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/features/Game/providers/night_action_result.dart';

class NightPage extends ConsumerStatefulWidget {
  const NightPage({super.key});

  @override
  ConsumerState<NightPage> createState() => _NightPageState();
}

class _NightPageState extends ConsumerState<NightPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _moonController;

  @override
  void initState() {
    super.initState();
    _moonController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _moonController.dispose();
    super.dispose();
  }

  /// Main night phase runner - delegates to GameStateNotifier
  Future<void> _runNight() async {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);

    // Get actors sorted by priority
    final actors = _getActorsForNight(gameState);

    // Show each character's wake phase and execute their actions
    await _executeNightPhases(actors);

    // GameStateNotifier handles all the action resolution internally via runNight()
    await gameStateNotifier.runNight();

    // Show night results
    if (mounted) {
      await _showNightResults();
    }

    // Check win condition
    if (gameStateNotifier.checkWinCondition() && mounted) {
      await GameOverDialog.show(context, ref);
      return;
    }

    // Proceed to day phase
    gameStateNotifier.nextDay();
  }

  /// Get all actors sorted by their character's priority
  List<GamePlayer> _getActorsForNight(GameState gameState) {
    final alivePlayers = gameState.players.where((p) => p.isAlive).toList();

    // Get unique roles and sort by priority
    final rolesInOrder =
        alivePlayers.map((p) => p.gameCharacter).toSet().toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    // Build actor list with players for each role
    final actors = <GamePlayer>[];
    for (final role in rolesInOrder) {
      final playersWithRole = alivePlayers
          .where((p) => p.gameCharacter.runtimeType == role.runtimeType)
          .toList();
      actors.addAll(playersWithRole);
    }

    return actors;
  }

  /// Show wake-up dialogs for each character type
  Future<void> _executeNightPhases(List<GamePlayer> actors) async {
    // Track which role types have been shown (to avoid duplicate wake-ups)
    final Set<Type> shownRoles = {};

    for (final actor in actors) {
      final roleType = actor.gameCharacter.runtimeType;

      // Skip if we already showed this role type
      if (shownRoles.contains(roleType)) {
        continue;
      }

      // Mark this role as shown
      shownRoles.add(roleType);
    }
  }

  /// Show night results by comparing before/after state
  Future<void> _showNightResults() async {
    List<NightEvent> nightResults = ref
        .read(nightContextProvider.notifier)
        .showNightResults();

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFd4af37).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.brightness_3,
                size: 64,
                color: Color(0xFFd4af37),
              ),
              const SizedBox(height: 16),
              const Text(
                'Night Results',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFd4af37),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: nightResults.isEmpty
                    ? const Text(
                        'Nothing happened tonight.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        children: [
                          const Text(
                            'What happened tonight Tonight:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (var nightEvent in nightResults)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '${nightEvent.player.name} (${nightEvent.player.gameCharacter.name}) : ${nightEvent.result.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color:
                                      nightEvent.result ==
                                              Result.killedByWolves ||
                                          nightEvent.result == Result.killed
                                      ? Colors.red
                                      : nightEvent.result == Result.transformed
                                      ? Colors.purple
                                      : Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd4af37),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'CONTINUE TO DAY',
                  style: TextStyle(color: Color(0xFF0a0e27)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0a0e27), Color(0xFF1a1438), Color(0xFF2d1b3d)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with animated moon
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _moonController,
                    builder: (context, child) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFf5e6d3),
                              Color.lerp(
                                const Color(0xFFd4af37),
                                const Color(0xFFf5e6d3),
                                _moonController.value,
                              )!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFd4af37,
                              ).withValues(alpha: 0.4),
                              blurRadius: 20 + (10 * _moonController.value),
                              spreadRadius: 3 + (2 * _moonController.value),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.brightness_3,
                          color: Color(0xFF0a0e27),
                          size: 28,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Night ${gameState.nightCount}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFd4af37),
                        ),
                      ),
                      Text(
                        'The village sleeps...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Players list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: gameState.players.length,
                itemBuilder: (context, index) {
                  final p = gameState.players[index];
                  final teamColor = p.gameCharacter.team == Team.wolves
                      ? Colors.red.shade700
                      : p.gameCharacter.team == Team.village
                      ? Colors.blue.shade600
                      : Colors.purple.shade600;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          teamColor.withValues(alpha: 0.1),
                          teamColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: teamColor.withValues(
                          alpha: p.isDead ? 0.2 : 0.5,
                        ),
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: teamColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          p.gameCharacter.team == Team.wolves
                              ? Icons.pets
                              : p.gameCharacter.team == Team.village
                              ? Icons.home
                              : Icons.person,
                          color: teamColor,
                        ),
                      ),
                      title: Text(
                        p.gameCharacter.name + (p.isDead ? ' • DEAD' : ''),
                        style: TextStyle(
                          color: p.isDead ? Colors.grey : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Lives: ${p.lives}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing: Text(
                        p.name,
                        style: TextStyle(
                          color: p.isDead
                              ? Colors.grey
                              : const Color(0xFFd4af37),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Run night button
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _runNight,
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Color(0xFF0a0e27)),
                      SizedBox(width: 8),
                      Text(
                        'RUN NIGHT PHASE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Color(0xFF0a0e27),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
