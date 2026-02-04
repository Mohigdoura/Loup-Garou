import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/models/game_state.dart';
import 'package:loup_garou/features/Game/game_state_provider.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/providers/ad_provider.dart';

class NightPage extends ConsumerStatefulWidget {
  const NightPage({super.key});

  @override
  ConsumerState<NightPage> createState() => _NightPageState();
}

class _NightPageState extends ConsumerState<NightPage>
    with SingleTickerProviderStateMixin {
  String? wolvesTarget;
  String? protectorTarget;
  String? witchHealTarget;
  String? witchKillTarget;

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

  Future<void> _runNight() async {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final actors = gameStateNotifier.getActorsForNight();
    bool wolvesHaveActed = false;
    String? startName;
    String? direction;

    for (final actor in actors) {
      if (!actor.isAlive) continue;
      if (actor.gameCharacter.team == Team.wolves && !wolvesHaveActed) {
        await _wakePhase(
          'Wolves',
          Icons.pets,
          Colors.red.shade700,
          () => _wolvesPhase(),
        );
        wolvesHaveActed = true;
      }
      switch (actor.gameCharacter) {
        case final Seer seer:
          await _wakePhase(
            'Seer',
            Icons.visibility,
            Colors.purple.shade400,
            () => _seerPhase(seer), // Pass the captured seer
          );
          break;
        case final Protector protector:
          await _wakePhase(
            'Protector',
            Icons.shield,
            Colors.blue.shade400,
            () => _protectorPhase(protector), // Pass the captured protector
          );
          break;
        case final Witch witch:
          await _wakePhase(
            'Witch',
            Icons.auto_fix_high,
            Colors.green.shade400,
            () => _witchPhase(witch),
          );
          break;
        case Ancient():
          await _wakePhase(
            'Ancient',
            Icons.elderly,
            Colors.amber.shade700,
            () async {
              startName = await _chooseStartingPlayer();
              direction = await _chooseDirection();
            },
          );
          break;
        case final BlackWolf blackWolf:
          await _wakePhase(
            'Black Werewolf',
            Icons.pets,
            Colors.grey.shade800,
            () async {
              final target = await _blackWerewolfPhase(blackWolf);
              if (target != null) {
                gameStateNotifier.setSilenced(target);
              }
            },
          );
          break;
      }
    }

    await _resolveNight(startName, direction);
  }

  Future<void> _wakePhase(
    String title,
    IconData icon,
    Color color,
    Future<void> Function() action,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1a1f3a), const Color(0xFF2d1b3d)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                'Wake the $title',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please wake the $title and perform their action.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await action();
  }

  Future<void> _wolvesPhase() async {
    final gameState = ref.watch(gameStateProvider);

    final selectable = gameState.players
        .where((p) => p.isAlive && p.gameCharacter.team != Team.wolves)
        .toList();
    if (selectable.isEmpty) return;

    final target = await _pickPlayer(
      'Wolves: choose a victim',
      selectable.map((p) => p.name).toList(),
      Icons.pets,
      Colors.red.shade700,
    );
    if (target != null) {
      wolvesTarget = target;
    }
  }

  Future<void> _seerPhase(Seer seer) async {
    final gameState = ref.watch(gameStateProvider);

    final target = await _pickPlayer(
      'Seer: choose someone to see',
      gameState.players
          .where((p) => p.isAlive && !(p.gameCharacter is Seer))
          .map((p) => p.name)
          .toList(),
      Icons.visibility,
      Colors.purple.shade400,
    );

    if (target != null) {
      final found = gameState.players.firstWhere((p) => p.name == target);
      final isWolf = seer.checkPlayerIfWolf(found.gameCharacter);
      final result = isWolf ? 'is a wolf' : 'is not a wolf';

      if (mounted) {
        await _showResultDialog(
          'Seer Result',
          '$target $result',
          isWolf ? Icons.pets : Icons.home,
          isWolf ? Colors.red.shade700 : Colors.blue.shade400,
        );
      }
    }
  }

  Future<void> _protectorPhase(Protector protector) async {
    final gameState = ref.watch(gameStateProvider);

    final target = await _pickPlayer(
      'Protector: choose who to protect',
      gameState.players
          .where((p) => p.isAlive && p.name != protector.lastProtected)
          .map((p) => p.name)
          .toList(),
      Icons.shield,
      Colors.blue.shade400,
    );
    if (target != null) {
      ref.read(gameStateProvider.notifier).setLastProtectedPlayer(target);
      protectorTarget = target;
    }
  }

  Future<void> _witchPhase(Witch witch) async {
    final notifier = ref.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);

    String? tempHealTarget;
    String? tempKillTarget;

    while (true) {
      final action = await showDialog<String>(
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
                color: Colors.green.shade400.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_fix_high,
                  size: 48,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Witch: choose action',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Died tonight: ${wolvesTarget ?? "none"}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                if (witch.hasHealPotion)
                  _WitchActionButton(
                    label: tempHealTarget == null
                        ? 'Use heal potion'
                        : 'Change heal ($tempHealTarget)',
                    icon: Icons.favorite,
                    color: Colors.red.shade400,
                    onPressed: () {
                      if (tempHealTarget != null) {
                        Navigator.pop(context, 'no heal');
                      } else {
                        Navigator.pop(context, 'heal');
                      }
                    },
                  ),
                if (witch.hasKillPotion)
                  _WitchActionButton(
                    label: tempKillTarget == null
                        ? 'Use kill potion'
                        : 'Change kill ($tempKillTarget)',
                    icon: Icons.dangerous,
                    color: Colors.purple.shade400,
                    onPressed: () => Navigator.pop(context, 'kill'),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, 'skip'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('SKIP'),
                      ),
                    ),
                    if (tempHealTarget != null || tempKillTarget != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, 'confirm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('CONFIRM'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (action == 'skip' || action == null) return;

      if (action == 'heal') {
        tempHealTarget = wolvesTarget;
        continue;
      }
      if (action == 'no heal') {
        tempHealTarget = null;
        continue;
      }
      if (action == 'kill') {
        List<String> choices = gameState.players
            .where((p) => p.isAlive)
            .map((p) => p.name)
            .toList();
        choices.add('None');
        final target = await _pickPlayer(
          'Witch: choose someone to poison',
          choices,
          Icons.dangerous,
          Colors.purple.shade400,
        );
        tempKillTarget = target;
        continue;
      }

      if (action == 'confirm') {
        if (tempHealTarget != null) {
          witchHealTarget = tempHealTarget;
          notifier.witchUseHealPotion();
        }

        if (tempKillTarget != null) {
          witchKillTarget = tempKillTarget;
          notifier.witchUseKillPotion();
        }

        return;
      }
    }
  }

  Future<String?> _blackWerewolfPhase(BlackWolf blackWolf) async {
    final gameState = ref.watch(gameStateProvider);

    final selectable = gameState.players
        .where(
          (p) =>
              p.isAlive &&
              p.gameCharacter.team != Team.wolves &&
              p.name != blackWolf.lastSilenced,
        )
        .toList();
    if (selectable.isEmpty) return null;

    final target = await _pickPlayer(
      'Black werewolf: choose to silence',
      selectable.map((p) => p.name).toList(),
      Icons.voice_over_off,
      Colors.grey.shade700,
    );
    blackWolf.silencePlayer(target);
    return target;
  }

  Future<String?> _chooseStartingPlayer() async {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    final alive = gameStateNotifier.getAlivePlayers();

    final startName = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: const Text(
          'Ancient: Choose who starts',
          style: TextStyle(color: Colors.amber),
        ),
        children: alive
            .map(
              (p) => SimpleDialogOption(
                child: Text(
                  p.name,
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context, p.name),
              ),
            )
            .toList(),
      ),
    );

    return startName;
  }

  Future<String?> _chooseDirection() async {
    final direction = mounted
        ? await showDialog<String>(
            context: context,
            builder: (_) => SimpleDialog(
              backgroundColor: const Color(0xFF1a1f3a),
              title: const Text(
                'Ancient: Choose direction',
                style: TextStyle(color: Colors.amber),
              ),
              children: [
                SimpleDialogOption(
                  child: const Text(
                    'Clockwise',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context, 'clockwise'),
                ),
                SimpleDialogOption(
                  child: const Text(
                    'Counter-clockwise',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context, 'counter'),
                ),
              ],
            ),
          )
        : null;

    return direction;
  }

  Future<String?> _pickPlayer(
    String title,
    List<String> options,
    IconData icon,
    Color color,
  ) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return InkWell(
                      onTap: () => Navigator.pop(
                        context,
                        option == "None" ? null : option,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showResultDialog(
    String title,
    String message,
    IconData icon,
    Color color,
  ) async {
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
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resolveNight(String? startName, String? direction) async {
    final gameState = ref.watch(gameStateProvider);
    List<GamePlayer> killedTonight = [];
    final gameStateNotifier = ref.read(gameStateProvider.notifier);

    // Handle wolves kill
    if (wolvesTarget != null) {
      final victim = gameState.players.firstWhere(
        (p) => p.name == wolvesTarget,
      );

      if (protectorTarget != null && wolvesTarget == protectorTarget) {
        await _showResultDialog(
          'Attack Blocked',
          '$wolvesTarget was protected!',
          Icons.shield,
          Colors.blue.shade400,
        );
      } else if (witchHealTarget != null) {
        await _showResultDialog(
          'Healed!',
          '$wolvesTarget was healed!',
          Icons.favorite,
          Colors.red.shade400,
        );
      } else if (victim.gameCharacter is Ancient && victim.lives > 1) {
        gameStateNotifier.killPlayer(victim.name);
        await _showResultDialog(
          'Ancient Resisted',
          '${victim.name} survived! 1 life remaining.',
          Icons.elderly,
          Colors.amber.shade700,
        );
      } else {
        gameStateNotifier.killPlayer(victim.name);
        killedTonight.add(victim);

        if (victim.gameCharacter is Hunter) {
          try {
            final firstWolf = gameState.players.firstWhere(
              (p) => p.isAlive && p.gameCharacter.team == Team.wolves,
            );

            gameStateNotifier.killPlayer(firstWolf.name);
            killedTonight.add(firstWolf);
          } catch (e) {
            log('resolve night error: ${e.toString()}');
          }
        }
      }
    }

    // Handle witch poison
    if (witchKillTarget != null) {
      final poisoned = gameState.players.firstWhere(
        (p) => p.name == witchKillTarget,
      );
      if (poisoned.isAlive) {
        // Check if Ancient and has lives
        if (poisoned.gameCharacter is Ancient && poisoned.lives > 1) {
          gameStateNotifier.killPlayer(poisoned.name);

          await _showResultDialog(
            'Ancient Resisted',
            '${poisoned.name} survived the poison! 1 life remaining.',
            Icons.elderly,
            Colors.amber.shade700,
          );
        } else {
          gameStateNotifier.killPlayer(poisoned.name);
          killedTonight.add(poisoned);

          if (poisoned.gameCharacter is Hunter) {
            try {
              final firstWolf = gameState.players.firstWhere(
                (p) => p.isAlive && p.gameCharacter.team == Team.wolves,
              );

              gameStateNotifier.killPlayer(firstWolf.name);
              killedTonight.add(firstWolf);
            } catch (e) {
              log('resolve night error: ${e.toString()}');
            }
          }
        }
      }
    }

    // Show night results
    if (mounted) {
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
                  child: killedTonight.isEmpty
                      ? const Text(
                          'No one died tonight.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        )
                      : Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Died Tonight: ',
                                style: TextStyle(color: Colors.white70),
                              ),
                              for (var dead in killedTonight) ...[
                                TextSpan(
                                  text:
                                      '${dead.name} : ${dead.gameCharacter.name}\n',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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

    // Check win condition
    if (gameStateNotifier.checkWinCondition() && mounted) {
      await showGameOverDialog();
      return;
    }

    // Proceed to day
    gameStateNotifier.nextNight(startName, direction);
  }

  Future<void> showGameOverDialog() async {
    final gameState = ref.read(gameStateProvider);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: const Text(
          'Game Over',
          style: TextStyle(color: Color(0xFFd4af37)),
        ),
        content: Text(
          gameState.gameOverMessage ?? 'Game ended.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(adProvider.notifier)
                  .showInterstitial(
                    () => Navigator.popUntil(context, (route) => route.isFirst),
                  );
            },
            child: const Text(
              'BACK TO MENU',
              style: TextStyle(color: Color(0xFFd4af37)),
            ),
          ),
        ],
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

class _WitchActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _WitchActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
