import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/Game/day/day_page.dart';
import 'package:loup_garou/features/Game/night/night_page.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/providers/ad_provider.dart';
import 'package:loup_garou/features/Game/providers/game_state_provider.dart';

class Game extends ConsumerWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              backgroundColor: const Color(0xFF1a1f3a),
              title: Text(
                l10n.exitGameDialogTitle,
                style: const TextStyle(color: Colors.white),
              ),
              content: Text(
                l10n.exitGameDialogContent,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => dialogContext.pop(),
                  child: Text(
                    l10n.exitGameDialogCancel,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    dialogContext.pop();
                    ref.read(adProvider.notifier).showInterstitial(() {
                      context.pop();
                    });
                  },
                  child: Text(
                    l10n.exitGameDialogConfirm,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        child: SafeArea(child: gameState.isNight ? NightPage() : DayPage()),
      ),
    );
  }
}
