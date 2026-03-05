import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loup_garou/features/Game/models/win_condition.dart';
import 'package:loup_garou/features/Game/providers/night_action_result.dart';
import 'package:loup_garou/main.dart';
import 'package:loup_garou/features/Game/providers/game_actions.dart';
import 'package:loup_garou/models/character_ui.dart';
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
      "has two lives and if killed no one on the villagers team can use his ability and can decide who starts the talking and in which order";
  @override
  int get lives => 2;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
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
              'Clockwise (default)',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () =>
                Navigator.pop(navigatorKey.currentContext!, 'clockwise'),
          ),
          SimpleDialogOption(
            child: const Text(
              'Counter-clockwise (reverse)',
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
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;
    final targets = state.players
        .where((p) => p.isAlive && p.name != self.name)
        .map((p) => p.name)
        .toList();

    final target = await CharacterUI.pickPlayer(
      title: 'Seer: choose someone to see',
      options: targets,
      icon: FontAwesomeIcons.eye,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    if (target != null) {
      final found = state.players.where((p) => p.name == target).firstOrNull;
      if (found == null) return;
      final isWolf = checkPlayerIfWolf(found.gameCharacter);
      final result = isWolf ? 'is a wolf' : 'is not a wolf';

      await CharacterUI.showResult(
        title: 'Seer Result',
        message: target + ' ' + result,
        icon: isWolf ? Icons.pets : Icons.home,
        color: isWolf ? Colors.red.shade700 : Colors.blue.shade400,
        tag: 'NIGHT RESULT', // optional badge
        buttonLabel: 'GOT IT', // optional override
      );
      if (isWolf) {
        actions.addSeen(found);
      }
    }
  }
}

class Protector extends GameCharacter {
  @override
  String get name => "Protector";
  @override
  Team get team => Team.village;

  @override
  String get ability =>
      'Protect one player from being killed by wolves each night.';
  @override
  IconData get icon => FontAwesomeIcons.shield;
  @override
  int get priority => 110;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;

    final lastProtected = self.characterState['lastProtected'] as String?;
    final targets = state.players
        .where((p) => p.isAlive && p.name != lastProtected)
        .map((p) => p.name)
        .toList();

    final target = await CharacterUI.pickPlayer(
      title: 'Protector: choose who to protect',
      options: targets,
      icon: FontAwesomeIcons.shield,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    if (target != null) {
      // ✅ Need to update the player's state in GameStateNotifier
      // This requires adding a method to update character state
      final targetPlayer = state.players
          .where((p) => p.name == target)
          .firstOrNull;
      if (targetPlayer == null) return;
      actions.addProtected(targetPlayer);
      actions.updateCharacterState(self, {'lastProtected': target});
    }
  }
}

class Doctor extends GameCharacter {
  @override
  String get name => "Doctor";
  @override
  Team get team => Team.village;

  @override
  String get ability =>
      "Heals one player each night (like the protector but isn't limited to wolves victim).";
  @override
  IconData get icon => FontAwesomeIcons.heartCircleCheck;
  @override
  int get priority => 10;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;

    final lastProtected = self.characterState['lastHealed'] as String?;
    final targets = state.players
        .where((p) => p.isAlive && p.name != lastProtected)
        .map((p) => p.name)
        .toList();

    final target = await CharacterUI.pickPlayer(
      title: 'Healer: choose who to heal',
      options: targets,
      icon: FontAwesomeIcons.heartCircleCheck,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    if (target != null) {
      final targetPlayer = state.players
          .where((p) => p.name == target)
          .firstOrNull;
      if (targetPlayer == null) return;
      actions.heal(targetPlayer);
      actions.updateCharacterState(self, {'lastHealed': target});
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
  int get priority => 30;

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );
    final state = actions.state;
    final night = actions.nightContext;
    final hasHeal = self.characterState['hasHeal'] as bool? ?? true;
    final hasKill = self.characterState['hasKill'] as bool? ?? true;

    String? tempHealTarget;
    String? tempKillTarget;

    final killedPlayers = night.nightEvents
        .where(
          (element) =>
              element.result == Result.HealedByWolves ||
              element.result == Result.Killed,
        )
        .map((e) => e.player.name)
        .toList();

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
                    'Died tonight: ${killedPlayers.isNotEmpty ? killedPlayers.join(', ') : 'no one'}',
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

      if (action == 'heal') {
        if (killedPlayers.isEmpty) {
          // No one died tonight, nothing to heal
          continue;
        }

        if (killedPlayers.length == 1) {
          // Only one option, auto-select
          tempHealTarget = killedPlayers.first;
          continue;
        }

        // Let witch pick who to heal from the dead players
        final healPick = await CharacterUI.pickPlayer(
          title: 'Witch: choose someone to heal',
          options: killedPlayers,
          icon: Icons.favorite,
          color: Colors.red.shade400,
        );
        tempHealTarget = healPick;
        continue;
      }
      if (action == 'no heal') {
        tempHealTarget = null;
        continue;
      }
      if (action == 'kill') {
        List<String> choices = state.players
            .where((p) => p.isAlive && p.name != self.name)
            .map((p) => p.name)
            .toList();

        final target = await CharacterUI.pickPlayer(
          title: 'Witch: choose someone to poison',
          options: choices,
          icon: Icons.dangerous,
          color: CharacterUI.getColorForCharacter(self.gameCharacter),
        );
        tempKillTarget = target;
        continue;
      }

      if (action == 'confirm') {
        if (tempHealTarget != null) {
          final healTarget = state.players
              .where((p) => p.name == tempHealTarget)
              .firstOrNull;
          if (healTarget == null) return;
          actions.updateCharacterState(self, {'hasHeal': false});
          actions.heal(healTarget);
        }

        if (tempKillTarget != null) {
          final killTarget = state.players
              .where((p) => p.name == tempKillTarget)
              .firstOrNull;
          if (killTarget == null) return;

          actions.updateCharacterState(self, {'hasKill': false});
          actions.addKilled(killTarget);
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
  void onKilled({
    required GameActions actions,
    required NightEvent nightEvent,
  }) async {
    if (nightEvent.result == Result.HealedByWolves) {
      // Find first alive wolf
      final state = actions.state;
      final firstWolf = state.players
          .where((p) => p.isAlive && p.gameCharacter.team == Team.wolves)
          .firstOrNull;
      if (firstWolf == null) return;
      actions.addKilled(firstWolf);
      actions.killPlayer(firstWolf);
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
  void onKilled({
    required GameActions actions,
    required NightEvent nightEvent,
  }) async {
    // Find the next alive player after this player
    final state = actions.state;
    final thisPlayerIndex = state.alivePlayers.indexOf(nightEvent.player);
    final lastPlayer = state.players.length - 1;
    final nextPlayer = (thisPlayerIndex + 1) % (lastPlayer + 1);
    final nextAlivePlayer = state.players[nextPlayer];
    actions.addKilled(nextAlivePlayer);
    actions.killPlayer(nextAlivePlayer);
  }
}

class LittlePrince extends GameCharacter {
  @override
  String get name => "Little Prince";
  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.crown;
  @override
  String get ability => 'If voted out, reveals his role and stays in the game.';

  @override
  Future<void> onVotedOut({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    actions.littlePrinceOnVotedOut(self);
  }
}

class LittlePrincess extends GameCharacter {
  @override
  String get name => "Little Princess";
  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.crown;
  @override
  String get ability => "can't be killed by wolves, she always survives.";

  @override
  void onKilled({
    required GameActions actions,
    required NightEvent nightEvent,
  }) {
    if (nightEvent.result == Result.HealedByWolves) {
      actions.princessKilled(nightEvent.player);
      return;
    }
  }
}

class Barbie extends GameCharacter {
  @override
  String get name => "Barbie";
  @override
  Team get team => Team.village;
  @override
  IconData get icon => FontAwesomeIcons.wandMagicSparkles;
  @override
  int get priority => 120;
  @override
  bool get hasDayAction => true;
  @override
  String get ability =>
      'can make everyone sleep during daytime and chooses who to kill.';

  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    if (actions.state.nightCount == 1) {
      await CharacterUI.showWakePhase(
        title: self.gameCharacter.name,
        name: self.name,
        icon: self.gameCharacter.icon,
        color: CharacterUI.getColorForCharacter(self.gameCharacter),
      );
      await CharacterUI.pickSignal<String>(
        characterName: 'Barbie',
        characterIcon: FontAwesomeIcons.wandMagicSparkles,
        characterColor: Colors.pinkAccent,
        prompt: 'Choose your daytime signal',
      );
    }
  }

  @override
  Future<void> dayAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    final hasBullet = self.characterState['hasBullet'] as bool? ?? true;
    if (!hasBullet) {
      return;
    }
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    final state = actions.state;

    final targets = state.players
        .where((p) => p.isAlive && p.name != self.name)
        .map((p) => p.name)
        .toList();

    final target = await CharacterUI.pickPlayer(
      title: 'Barbie: choose who to kill',
      options: targets,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );
    if (target != null) {
      final targetPlayer = state.alivePlayers
          .where((p) => p.name == target)
          .firstOrNull;
      if (targetPlayer == null) return;
      if (targetPlayer.gameCharacter.name == 'Ancient') {
        await actions.killPlayer(self);
        await CharacterUI.showResult(
          title: 'Died Today',
          message: self.name + ' killed himself',
          icon: self.gameCharacter.icon,
          color: CharacterUI.getColorForCharacter(self.gameCharacter),
          tag: 'Barbie RESULT', // optional badge
          buttonLabel: 'GOT IT', // optional override
        );
      } else {
        await actions.killPlayer(targetPlayer);
        await CharacterUI.showResult(
          title: 'Died Today',
          message: target + ' was killed',
          icon: self.gameCharacter.icon,
          color: CharacterUI.getColorForCharacter(self.gameCharacter),
          tag: 'Barbie RESULT', // optional badge
          buttonLabel: 'GOT IT', // optional override
        );
        actions.updateCharacterState(self, {'hasBullet': false});
      }
    }
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
    await CharacterUI.showWakePhase(
      title: "Wolves",
      name: "The Wolves",
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(SimpleWolf()),
    );
    final state = actions.state;
    final targets = state.players
        .where((p) => p.isAlive && p.gameCharacter.team != Team.wolves)
        .map((p) => p.name)
        .toList();
    final target = await CharacterUI.pickPlayer(
      title: 'Wolves: choose a victim',
      options: targets,
      icon: Icons.pets,
      color: CharacterUI.getColorForCharacter(SimpleWolf()),
      allowNone: false,
    );

    if (target != null) {
      final targetPlayer = state.players
          .where((p) => p.name == target)
          .firstOrNull;
      if (targetPlayer == null) return;
      actions.addKilledByWolves(targetPlayer);
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
  Color? get imageColor => Colors.white;
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
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
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

    final silenceTarget = await CharacterUI.pickPlayer(
      title: 'Black werewolf: choose to silence',
      options: silenceTargets,
      icon: Icons.voice_over_off,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
      allowNone: false,
    );

    if (silenceTarget != null) {
      actions.updateCharacterState(self, {'lastSilenced': silenceTarget});

      final silencedPlayer = state.players
          .where((p) => p.name == silenceTarget)
          .firstOrNull;
      if (silencedPlayer == null) return;

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
  void onKilled({
    required GameActions actions,
    required NightEvent nightEvent,
  }) async {
    if (nightEvent.result == Result.HealedByWolves) {
      actions.cursedChildKilled(nightEvent.player);
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
    final options = actions.state.players
        .where((p) => p.isAlive && p.name != self.name)
        .map((p) => p.name)
        .toList();
    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    final target = await CharacterUI.pickPlayer(
      title: 'Serial Killer: choose to kill',
      options: options,
      icon: FontAwesomeIcons.skullCrossbones,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );
    final targetPlayer = actions.state.players
        .where((p) => p.name == target)
        .firstOrNull;
    if (targetPlayer == null) return;
    actions.addKilled(targetPlayer);
  }
}

class GraveRobber extends GameCharacter {
  @override
  String get name => "Grave Robber";

  @override
  int get priority => 20;

  @override
  Team get team => Team.solo;
  @override
  IconData get icon => FontAwesomeIcons.breadSlice;
  @override
  String get ability =>
      "Can choose a player each night, if that player dies he takes his role.";
  @override
  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {
    final options = actions.state.players
        .where((p) => p.isAlive && p.name != self.name)
        .map((e) => e.name)
        .toList();

    await CharacterUI.showWakePhase(
      title: self.gameCharacter.name,
      name: self.name,
      icon: self.gameCharacter.icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    final target = await CharacterUI.pickPlayer(
      title: 'Grave Robber: choose who to watch',
      options: options,
      icon: icon,
      color: CharacterUI.getColorForCharacter(self.gameCharacter),
    );

    if (target != null) {
      // Save target so _finalizeNight can check it
      actions.updateCharacterState(self, {'watchingTarget': target});
    }
  }
}
