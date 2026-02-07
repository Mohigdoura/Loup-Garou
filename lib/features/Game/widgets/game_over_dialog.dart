// lib/features/Game/widgets/game_over_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';
import 'package:loup_garou/providers/ad_provider.dart';

class GameOverDialog {
  /// Show the game over dialog from anywhere in the game
  static Future<void> show(BuildContext context, WidgetRef ref) async {
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
          gameState.winCondition?.message ?? 'Game ended.',
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
            child: const Text(
              'BACK TO MENU',
              style: TextStyle(color: Color(0xFFd4af37)),
            ),
          ),
        ],
      ),
    );
  }
}
