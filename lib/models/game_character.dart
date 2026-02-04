import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loup_garou/models/game_state.dart';
import 'package:loup_garou/models/night_action_result.dart';

enum Team { village, wolves, solo }

/// Base class for all game characters
abstract class GameCharacter {
  String get name;
  Team get team;
  IconData get icon;
  String? get image;
  Color? get imageColor;
  String get ability;
  int get priority => 0;
  bool get visibleToSeer => true;
  int get lives => 1;

  List<NightActionResult> nightAction({
    required GameState state,
    required NightContext night,
    required GamePlayer self,
  });

  List<NightActionResult> onKilled({
    required GameState state,
    required GamePlayer self,
  });
}

// ============================================================================
// VILLAGE TEAM ROLES
// ============================================================================

class Ancient extends GameCharacter {
  Ancient()
    : super(
        name: 'Ancient',
        team: Team.village,
        icon: FontAwesomeIcons.scroll,
        ability:
            'has two lives and can decide who starts the talking and in which order',
        priority: 0,
        lives: 2,
      );

  /// Ancient chooses speaking order
  void chooseSpeakingOrder(List<GameCharacter> players) {
    // Implementation for choosing speaking order
  }

  @override
  bool canActTonight() => true;
}

class Seer extends GameCharacter {
  Seer()
    : super(
        name: 'Seer',
        team: Team.village,
        icon: FontAwesomeIcons.eye,
        ability: 'View one player\'s alignment each night.',
        priority: 90,
      );

  @override
  void performNightAction() {
    // Implementation for viewing a player's alignment
  }

  @override
  bool canActTonight() => true;

  /// Check a player's alignment
  bool checkPlayerIfWolf(GameCharacter player) {
    if (player.visibleToSeer) {
      return player.team == Team.wolves ? true : false;
    }
    // White Wolf appears as village to seer
    return false;
  }
}

class Protector extends GameCharacter {
  String? lastProtected;

  Protector()
    : super(
        name: 'Protector',
        team: Team.village,
        icon: FontAwesomeIcons.shield,
        ability: 'Protect one player from being killed each night.',
        priority: 80,
      );

  @override
  void performNightAction() {
    // Implementation for protecting a player
  }

  @override
  bool canActTonight() => true;

  /// Protect a player (cannot protect same player twice in a row)
  void setlastProtectedPlayer(String player) {
    lastProtected = player;
  }
}

class Villager extends GameCharacter {
  Villager()
    : super(
        name: 'Villager',
        team: Team.village,
        icon: FontAwesomeIcons.person,
        ability: 'No special ability, just your vote.',
      );
}

class Witch extends GameCharacter {
  @override
  String get name => 'Witch';
  @override
  String get ability => 'One heal potion and one kill potion per game.';

  bool hasHeal = true;
  bool hasKill = true;

  @override
  int get priority => 3; // after wolves

  @override
  List<NightActionResult> nightAction({
    required GameState state,
    required NightContext night,
    required GamePlayer self,
  }) {
    final actions = <NightActionResult>[];

    if (hasHeal && night.toDie.isNotEmpty) {
      final victim = night.toDie.first; // chosen via UI
      actions.add(
        NightActionResult(type: ActionType.heal, actor: self, target: victim),
      );
      hasHeal = false;
    }

    return actions;
  }

  @override
  List<NightActionResult> onKilled({required state, required self}) => [];
}

class Hunter extends GameCharacter {
  Hunter()
    : super(
        name: 'Hunter',
        team: Team.village,
        icon: FontAwesomeIcons.crosshairs,
        ability: 'If killed, take the first wolf down with you.',
      );
}

// ============================================================================
// WOLVES TEAM ROLES
// ============================================================================

class SimpleWolf extends GameCharacter {
  SimpleWolf()
    : super(
        name: 'Simple Wolf',
        team: Team.wolves,
        icon: FontAwesomeIcons.paw,
        image: 'assets/wolf.png',
        imageColor: Colors.grey,
        ability: 'Vote to kill one player every night.',
        priority: 100,
      );

  @override
  bool canActTonight() => true;

  @override
  void performNightAction() {
    // Implementation for wolf vote
  }
}

class WhiteWolf extends GameCharacter {
  WhiteWolf()
    : super(
        name: 'White Wolf',
        team: Team.wolves,
        icon: FontAwesomeIcons.paw,
        image: 'assets/wolf.png',
        imageColor: Colors.white,
        ability:
            "Vote to kill one player every night and can't be seen by the seer.",
        priority: 100,
        visibleToSeer: false, // Key difference - appears as village to seer
      );

  @override
  bool canActTonight() => true;

  @override
  void performNightAction() {
    // Implementation for wolf vote (same as simple wolf)
  }
}

class BlackWolf extends GameCharacter {
  String? lastSilenced;

  BlackWolf()
    : super(
        name: 'Black Wolf',
        team: Team.wolves,
        icon: Icons.nightlight_round,
        image: 'assets/wolf.png',
        imageColor: Colors.black,
        ability:
            "Vote to kill one player every night and silences a player once a night.",
        priority: 100,
      );

  @override
  bool canActTonight() => true;

  @override
  void performNightAction() {
    // Implementation for wolf vote and silence
  }

  /// Silence a player for the next day
  void silencePlayer(String? player) {
    lastSilenced = player;
  }
}
