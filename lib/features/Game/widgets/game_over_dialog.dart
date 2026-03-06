// lib/features/Game/widgets/game_over_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/providers/ad_provider.dart';

class GameOverDialog {
  /// Show the game over dialog from anywhere in the game
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.read(gameStateProvider);

    final winners = gameState.winCondition!.winners!;
    final winnerNames = winners.map((e) => e.name).join(', ');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text(
          l10n.gameOverTitle,
          style: const TextStyle(color: Color(0xFFd4af37)),
        ),
        content: Text(
          winners.length > 1
              ? l10n.gameOverWinners(winnerNames)
              : l10n.gameOverWinner(winnerNames),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(adProvider.notifier).showInterstitial(() {
                Navigator.pop(context);
                Navigator.pop(context);
              });
            },
            child: Text(
              l10n.backToMenu,
              style: const TextStyle(color: Color(0xFFd4af37)),
            ),
          ),
        ],
      ),
    );
  }
}
