import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/Game/day/day_page.dart';
import 'package:loup_garou/features/Game/night/night_page.dart';
import 'package:loup_garou/providers/ad_provider.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';

class Game extends ConsumerWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop)
            return; // Important: prevent showing dialog if already popped

          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: const Color(0xFF1a1f3a),
              title: const Text(
                'Exit Game?',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Are you sure you want to exit the game? Your progress will be lost.',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => dialogContext.pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    dialogContext.pop(); // Close the dialog
                    ref.read(adProvider.notifier).showInterstitial(() {
                      context.pop(); // Exit the game screen
                    });
                  },
                  child: const Text(
                    'Exit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        child: gameState.isNight ? NightPage() : DayPage(),
      ),
    );
  }
}
