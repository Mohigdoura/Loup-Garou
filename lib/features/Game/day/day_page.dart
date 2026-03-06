import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';
import 'package:loup_garou/features/Game/widgets/game_over_dialog.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/models/game_characters.dart';

class DayPage extends ConsumerStatefulWidget {
  const DayPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DayPageState();
}

class _DayPageState extends ConsumerState<DayPage>
    with TickerProviderStateMixin {
  late AnimationController _sunController;

  @override
  void initState() {
    super.initState();
    _sunController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sunController.dispose();
    super.dispose();
  }

  Future<GamePlayer?> _pickPlayer(List<GamePlayer> candidates) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<GamePlayer>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.how_to_vote,
                      color: Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.voteDialogTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
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
                  itemCount: candidates.length + 1,
                  itemBuilder: (context, index) {
                    if (index == candidates.length) {
                      return InkWell(
                        onTap: () => context.pop(null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.skip_next,
                                color: Colors.orange.shade300,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.voteSkipTie,
                                style: TextStyle(
                                  color: Colors.orange.shade300,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final player = candidates[index];
                    return InkWell(
                      onTap: () => context.pop(player),
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
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFd4af37),
                                    Color(0xFFf5e6d3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF0a0e27),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ],
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

  Future<void> _vote() async {
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.watch(gameStateProvider);
    final gameStateNotifier = ref.read(gameStateProvider.notifier);

    final candidates = gameState.talkingOrder;

    final eliminated = await _pickPlayer(candidates);

    if (eliminated != null && mounted) {
      gameStateNotifier.votePlayer(eliminated);

      final result = eliminated.gameCharacter.team == Team.wolves
          ? l10n.voteResultIsWolf
          : eliminated.gameCharacter is LittlePrince
          ? l10n.voteResultIsLittlePrince
          : eliminated.gameCharacter is SerialKiller
          ? l10n.voteResultIsSerialKiller
          : l10n.voteResultNotWolf;

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
                color:
                    (eliminated.gameCharacter.team == Team.wolves
                            ? Colors.red.shade700
                            : Colors.blue.shade600)
                        .withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  eliminated.gameCharacter.team == Team.wolves
                      ? Icons.pets
                      : Icons.home,
                  size: 64,
                  color: eliminated.gameCharacter.team == Team.wolves
                      ? Colors.red.shade700
                      : Colors.blue.shade600,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.voteResultTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.voteResultMessage(eliminated.name, result),
                  style: TextStyle(
                    fontSize: 18,
                    color:
                        eliminated.gameCharacter.team == Team.wolves ||
                            eliminated.gameCharacter is SerialKiller
                        ? Colors.red.shade400
                        : eliminated.gameCharacter is LittlePrince
                        ? Colors.green.shade400
                        : Colors.blue.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        eliminated.gameCharacter.team == Team.wolves
                        ? Colors.red.shade700
                        : Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          ),
        ),
      );

      if (gameStateNotifier.checkWinCondition() && mounted) {
        await GameOverDialog.show(context, ref);
        return;
      }
    }

    if (!mounted) return;
    gameStateNotifier.nextNight();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.watch(gameStateProvider);
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    List<GamePlayer> talkingOrder = gameState.talkingOrder;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFFffd89b), Color(0xFFffa751)],
          ),
        ),
        child: Column(
          children: [
            // Header with animated sun
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _sunController,
                    builder: (context, child) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFffd700),
                              Color.lerp(
                                const Color(0xFFffa500),
                                const Color(0xFFffd700),
                                _sunController.value,
                              )!,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFffa500,
                              ).withValues(alpha: 0.5),
                              blurRadius: 20 + (10 * _sunController.value),
                              spreadRadius: 3 + (2 * _sunController.value),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wb_sunny,
                          color: Colors.white,
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
                        l10n.dayTitle(gameState.nightCount),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        l10n.daySubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Talking order list
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFffa751), Color(0xFFffd89b)],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.record_voice_over,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.talkingOrder,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: talkingOrder.length,
                        itemBuilder: (context, index) {
                          final p = talkingOrder[index];
                          final isAlive = p.isAlive;
                          final isSilenced = p.isSilenced;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAlive
                                  ? Colors.white
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAlive
                                    ? (isSilenced
                                          ? Colors.red.shade300
                                          : Colors.orange.shade200)
                                    : Colors.grey.shade400,
                              ),
                              boxShadow: isAlive
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isAlive
                                        ? [
                                            const Color(0xFFffa751),
                                            const Color(0xFFffd89b),
                                          ]
                                        : [
                                            Colors.grey.shade400,
                                            Colors.grey.shade500,
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                p.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isAlive ? Colors.black87 : Colors.grey,
                                  decoration: isAlive
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Text(
                                p.isDead
                                    ? l10n.playerStatusDead(
                                        p.gameCharacter.name,
                                      )
                                    : isSilenced
                                    ? l10n.playerStatusSilenced(
                                        p.gameCharacter.name,
                                      )
                                    : p.gameCharacter.name,
                                style: TextStyle(
                                  color: isAlive
                                      ? (isSilenced
                                            ? Colors.red.shade700
                                            : Colors.black54)
                                      : Colors.grey,
                                  fontWeight: isSilenced
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSilenced && isAlive)
                                    Icon(
                                      Icons.voice_over_off,
                                      color: Colors.red.shade700,
                                    ),
                                  if (isAlive && p.gameCharacter.hasDayAction)
                                    IconButton(
                                      icon: const Icon(Icons.auto_fix_high),
                                      color: Colors.orange.shade700,
                                      tooltip: l10n.dayAbilityTooltip,
                                      onPressed: () async {
                                        await gameStateNotifier.dayAbility(p);
                                      },
                                    ),
                                ],
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

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _vote,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFffa751), Color(0xFFff8c42)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFffa751,
                            ).withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.how_to_vote, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.voteToEliminate,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => gameStateNotifier.nextNight(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.skipVote,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
