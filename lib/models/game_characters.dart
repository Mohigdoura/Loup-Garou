import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loup_garou/features/Game/models/win_condition.dart';
import 'package:loup_garou/main.dart';
import 'package:loup_garou/features/Game/game_actions.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';

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

Future<String?> _pickPlayer(
  String title,
  List<String> options,
  IconData icon,
  Color color,
) async {
  final names = List<String>.from(options);
  names.add("None");
  return await showDialog<String>(
    context: navigatorKey.currentContext!,
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
                itemCount: names.length,
                itemBuilder: (context, index) {
                  final name = names[index];
                  return InkWell(
                    onTap: () => Navigator.pop(
                      navigatorKey.currentContext!,
                      name == "None" ? null : name,
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
                        name,
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

/// Show wake-up dialog for a character
Future<void> _wakePhase(
  String title,
  String name,
  IconData icon,
  Color color,
) async {
  await showDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: false,
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
              'Please wake the $name and perform their action.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(navigatorKey.currentContext!),
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
}

/// Get color for a character type
Color _getColorForCharacter(GameCharacter character) {
  switch (character.runtimeType) {
    case Seer:
      return Colors.purple.shade400;
    case Protector:
      return Colors.blue.shade400;
    case Witch:
      return Colors.green.shade400;
    case Ancient:
      return Colors.amber.shade700;
    case BlackWolf:
      return Colors.grey.shade700;
    case WhiteWolf:
      return Colors.grey;
    case SimpleWolf:
      return Colors.red.shade700;
    case Hunter:
      return Colors.orange.shade600;
    default:
      return Colors.white;
  }
}

// ============================================================================
// VILLAGE TEAM ROLES
// ============================================================================

class Ancient extends GameCharacter {
  @override
  String get name => "Ancient";

  @override
  Team get team => Team.village;

  @override
  IconData get icon => FontAwesomeIcons.scroll;

  @override
  String get ability =>
      "has two lives and can decide who starts the talking and in which order";
  @override
  int get lives => 2;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await _wakePhase(
      self.gameCharacter.name,
      self.name,
      self.gameCharacter.icon,
      _getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;

    final alive = state.players.where((p) => p.isAlive).toList();

    // Choose starting player
    final startName = await showDialog<String>(
      context: navigatorKey.currentContext!,
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
                onPressed: () =>
                    Navigator.pop(navigatorKey.currentContext!, p.name),
              ),
            )
            .toList(),
      ),
    );

    // Choose direction
    final direction = await showDialog<String>(
      context: navigatorKey.currentContext!,
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
            onPressed: () =>
                Navigator.pop(navigatorKey.currentContext!, 'clockwise'),
          ),
          SimpleDialogOption(
            child: const Text(
              'Counter-clockwise',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () =>
                Navigator.pop(navigatorKey.currentContext!, 'counter'),
          ),
        ],
      ),
    );
    actions.setStartNameAndDirection(startName, direction);
  }
}

class Seer extends GameCharacter {
  @override
  String get name => "Seer";
  @override
  Team get team => Team.village;

  @override
  String get ability => 'View one player\'s alignment each night.';
  @override
  IconData get icon => FontAwesomeIcons.eye;
  @override
  int get priority => 90;

  /// Check a player's alignment
  bool checkPlayerIfWolf(GameCharacter player) {
    if (player.visibleToSeer) {
      return player.team == Team.wolves ? true : false;
    }
    // White Wolf appears as village to seer
    return false;
  }

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await _wakePhase(
      self.gameCharacter.name,
      self.name,
      self.gameCharacter.icon,
      _getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;
    final targets = state.players
        .where((p) => p.isAlive && p.name != self.name)
        .map((p) => p.name)
        .toList();

    final target = await _pickPlayer(
      'Seer: choose someone to see',
      targets,
      FontAwesomeIcons.eye,
      _getColorForCharacter(self.gameCharacter),
    );

    if (target != null) {
      final found = state.players.firstWhere((p) => p.name == target);
      final isWolf = checkPlayerIfWolf(found.gameCharacter);
      final result = isWolf ? 'is a wolf' : 'is not a wolf';

      await showDialog(
        context: navigatorKey.currentContext!,
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
                color: (isWolf ? Colors.red.shade700 : Colors.blue.shade400)
                    .withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWolf ? Icons.pets : Icons.home,
                  size: 64,
                  color: isWolf ? Colors.red.shade700 : Colors.blue.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Seer Result',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isWolf ? Colors.red.shade700 : Colors.blue.shade400,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$target $result',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(navigatorKey.currentContext!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWolf
                        ? Colors.red.shade700
                        : Colors.blue.shade400,
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
  }
}

class Protector extends GameCharacter {
  @override
  String get name => "Protector";
  @override
  Team get team => Team.village;

  @override
  String get ability => 'Protect one player from being killed each night.';
  @override
  IconData get icon => FontAwesomeIcons.shield;
  @override
  int get priority => 80;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await _wakePhase(
      self.gameCharacter.name,
      self.name,

      self.gameCharacter.icon,
      _getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;

    final lastProtected = self.characterState['lastProtected'] as String?;
    final targets = state.players
        .where((p) => p.isAlive && p.name != lastProtected)
        .map((p) => p.name)
        .toList();

    final target = await _pickPlayer(
      'Protector: choose who to protect',
      targets,
      FontAwesomeIcons.shield,
      _getColorForCharacter(self.gameCharacter),
    );

    if (target != null) {
      // ✅ Need to update the player's state in GameStateNotifier
      // This requires adding a method to update character state
      final targetPlayer = state.players.firstWhere((p) => p.name == target);
      actions.addProtected(targetPlayer);
      actions.updateCharacterState(self, {'lastProtected': target});
    }
  }
}

class Villager extends GameCharacter {
  @override
  String get name => "Villager";

  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.person;
  @override
  String get ability => 'No special ability, just your vote.';
}

class Witch extends GameCharacter {
  @override
  String get name => 'Witch';
  @override
  String get ability => 'One heal potion and one kill potion per game.';

  @override
  IconData get icon => FontAwesomeIcons.wandSparkles;

  @override
  Team get team => Team.village;

  @override
  int get priority => 10;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await _wakePhase(
      self.gameCharacter.name,
      self.name,

      self.gameCharacter.icon,
      _getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;
    final night = actions.nightContext;
    final hasHeal = self.characterState['hasHeal'] as bool? ?? true;
    final hasKill = self.characterState['hasKill'] as bool? ?? true;

    String? tempHealTarget;
    String? tempKillTarget;
    // return first key where value.team is team.wolf
    final wolvesTarget = night.toDie.entries
        .where((entry) => entry.value.gameCharacter.team == Team.wolves)
        .map((entry) => entry.key)
        .firstOrNull
        ?.name;

    while (true) {
      final action = await showDialog<String>(
        context: navigatorKey.currentContext!,
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
                    'Died tonight: ${wolvesTarget ?? 'no one'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                if (hasHeal)
                  _WitchActionButton(
                    label: tempHealTarget == null
                        ? 'Use heal potion'
                        : 'Change heal ($tempHealTarget)',
                    icon: Icons.favorite,
                    color: Colors.red.shade400,
                    onPressed: () {
                      if (tempHealTarget != null) {
                        Navigator.pop(navigatorKey.currentContext!, 'no heal');
                      } else {
                        Navigator.pop(navigatorKey.currentContext!, 'heal');
                      }
                    },
                  ),
                if (hasKill)
                  _WitchActionButton(
                    label: tempKillTarget == null
                        ? 'Use kill potion'
                        : 'Change kill ($tempKillTarget)',
                    icon: Icons.dangerous,
                    color: Colors.purple.shade400,
                    onPressed: () =>
                        Navigator.pop(navigatorKey.currentContext!, 'kill'),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.pop(navigatorKey.currentContext!, 'skip'),
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
                          onPressed: () => Navigator.pop(
                            navigatorKey.currentContext!,
                            'confirm',
                          ),
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

      if (action == 'heal' && wolvesTarget != null) {
        tempHealTarget = wolvesTarget;
        continue;
      }
      if (action == 'no heal') {
        tempHealTarget = null;
        continue;
      }
      if (action == 'kill') {
        List<String> choices = state.players
            .where((p) => p.isAlive)
            .map((p) => p.name)
            .toList();

        final target = await _pickPlayer(
          'Witch: choose someone to poison',
          choices,
          Icons.dangerous,
          _getColorForCharacter(self.gameCharacter),
        );
        tempKillTarget = target;
        continue;
      }

      if (action == 'confirm') {
        if (tempHealTarget != null) {
          final healTarget = state.players.firstWhere(
            (p) => p.name == tempHealTarget,
          );

          actions.updateCharacterState(self, {'hasHeal': false});
          actions.removeFromDie(healTarget);
        }

        if (tempKillTarget != null) {
          final killTarget = state.players.firstWhere(
            (p) => p.name == tempKillTarget,
          );

          actions.updateCharacterState(self, {'hasKill': false});
          actions.addToDie(killTarget, self);
        }
        return;
      }
    }
  }
}

class Hunter extends GameCharacter {
  @override
  String get name => "Hunter";
  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.crosshairs;
  @override
  String get ability => 'If killed, take the first wolf down with you.';

  @override
  Future<void> onKilled({
    required GameActions actions,
    required GamePlayer self,
    required GamePlayer killer,
  }) async {
    if (killer.gameCharacter.team == Team.wolves) {
      // Find first alive wolf
      final state = actions.state;
      final firstWolf = state.players.firstWhere(
        (p) => p.isAlive && p.gameCharacter.team == Team.wolves,
      );
      await actions.killPlayer(firstWolf, self);
    }
  }
}

class Avenger extends GameCharacter {
  @override
  String get name => "Avenger";
  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.faceAngry;
  @override
  String get ability => 'If killed, take the next player down with you.';

  @override
  Future<void> onKilled({
    required GameActions actions,
    required GamePlayer self,
    required GamePlayer killer,
  }) async {
    // Find the next alive player after this player
    final state = actions.state;
    final thisPlayerIndex = state.players.indexOf(self);
    final lastPlayer = state.players.length - 1;
    final nextPlayer = (thisPlayerIndex + 1) % (lastPlayer + 1);
    final nextAlivePlayer = state.players[nextPlayer];
    await actions.killPlayer(nextAlivePlayer, self);
  }
}

// ============================================================================
// WOLVES TEAM ROLES
// ============================================================================

class SimpleWolf extends GameCharacter {
  @override
  String get name => "Simple Wolf";
  @override
  int get priority => 100;
  @override
  String? get image => 'assets/wolf.png';
  @override
  Color? get imageColor => Colors.grey;
  @override
  Team get team => Team.wolves;
  @override
  IconData get icon => FontAwesomeIcons.paw;
  @override
  String get ability => 'Vote to kill one player every night.';

  Future<void> wolfsActions({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await _wakePhase(
      "Wolves",
      "Wolves",
      self.gameCharacter.icon,
      _getColorForCharacter(SimpleWolf()),
    );
    final state = actions.state;
    final targets = state.players
        .where((p) => p.isAlive && p.gameCharacter.team != Team.wolves)
        .map((p) => p.name)
        .toList();
    final target = await _pickPlayer(
      'Wolves: choose a victim',
      targets,
      Icons.pets,
      _getColorForCharacter(SimpleWolf()),
    );

    if (target != null) {
      final targetPlayer = state.players.firstWhere((p) => p.name == target);
      actions.addToDie(targetPlayer, self);
    }
  }
}

class WhiteWolf extends SimpleWolf {
  @override
  String get name => "White Wolf";
  @override
  int get priority => 100;
  @override
  String? get image => 'assets/wolf.png';
  @override
  Color? get imageColor => Colors.grey;
  @override
  Team get team => Team.wolves;
  @override
  IconData get icon => FontAwesomeIcons.paw;
  @override
  String get ability =>
      "Vote to kill one player every night and can't be seen by the seer.";
  @override
  bool get visibleToSeer => false;
}

class BlackWolf extends SimpleWolf {
  @override
  String get name => "Black Wolf";
  @override
  int get priority => 100;
  @override
  String? get image => 'assets/wolf.png';
  @override
  Color? get imageColor => Colors.grey.shade700;
  @override
  Team get team => Team.wolves;
  @override
  IconData get icon => FontAwesomeIcons.paw;
  @override
  String get ability =>
      "Vote to kill one player every night and silences a player once a night.";

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await _wakePhase(
      self.gameCharacter.name,
      self.name,
      self.gameCharacter.icon,
      _getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;
    final lastSilenced = self.characterState['lastSilenced'] as String?;
    // First, silence a player
    final silenceTargets = state.players
        .where(
          (p) =>
              p.isAlive &&
              p.gameCharacter.team != Team.wolves &&
              p.name != lastSilenced,
        )
        .map((p) => p.name)
        .toList();

    final silenceTarget = await _pickPlayer(
      'Black werewolf: choose to silence',
      silenceTargets,
      Icons.voice_over_off,
      _getColorForCharacter(self.gameCharacter),
    );

    if (silenceTarget != null) {
      actions.updateCharacterState(self, {'lastSilenced': silenceTarget});

      final silencedPlayer = state.players.firstWhere(
        (p) => p.name == silenceTarget,
      );

      actions.setSilenced(silencedPlayer);
    }
  }
}

class CursedChild extends GameCharacter {
  @override
  String get name => "Cursed Child";

  @override
  String? get image => 'assets/wolf.png';
  @override
  Color? get imageColor => Colors.grey;
  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.paw;
  @override
  String get ability => "When killed by wolves becomes one of them.";
  @override
  Future<void> onKilled({
    required GameActions actions,
    required GamePlayer self,
    required GamePlayer killer,
  }) async {
    if (killer.gameCharacter.team == Team.wolves) {
      actions.cursedChildKilled(self);
      return;
    }
  }
}

// ============================================================================
// SOLO TEAM ROLES
// ============================================================================

class Clown extends GameCharacter {
  @override
  String get name => "Clown";

  @override
  Team get team => Team.solo;
  @override
  IconData get icon => FontAwesomeIcons.faceGrinTongueWink;
  @override
  String get ability => "When voted out wins.";
  @override
  Future<void> onVotedOut({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    actions.setWinCondition(
      WinCondition(
        message: '${self.name} (Clown) wins! They were voted out.',
        winningTeam: Team.solo,
        winners: [self],
      ),
    );
  }
}

class SerialKiller extends GameCharacter {
  @override
  String get name => "Serial Killer";
  @override
  int get priority => 70;
  @override
  Team get team => Team.solo;
  @override
  IconData get icon => FontAwesomeIcons.skull;
  @override
  String get ability =>
      "Each night you kill another player. If you are the last player alive you win";
  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    final alivePlayers = actions.state.alivePlayers
        .where((p) => p.name != self.name)
        .toList();
    await _wakePhase(
      self.gameCharacter.name,
      self.name,
      self.gameCharacter.icon,
      _getColorForCharacter(self.gameCharacter),
    );

    final target = await _pickPlayer(
      'Serial Killer: choose to kill',
      alivePlayers.map((p) => p.name).toList(),
      FontAwesomeIcons.skullCrossbones,
      _getColorForCharacter(self.gameCharacter),
    );
    final targetPlayer = actions.state.players.firstWhere(
      (p) => p.name == target,
    );
    actions.addToDie(targetPlayer, self);
  }
}
