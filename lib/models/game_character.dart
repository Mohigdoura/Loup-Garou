import 'package:flutter/material.dart';
import 'package:loup_garou/features/Game/providers/game_actions.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';
import 'package:loup_garou/features/Game/providers/night_action_result.dart';

enum Team { village, wolves, solo }

/// Base class for all game characters
abstract class GameCharacter {
  String get name;
  Team get team;
  IconData get icon;
  String? get image => null;
  Color? get imageColor => null;
  String get ability;
  int get priority => 0;
  bool get visibleToSeer => true;
  bool get hasDayAction => false;
  int get lives => 1;

  Future<void> nightAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {}

  Future<void> dayAction({
    required GameActions actions,
    required GamePlayer self,
  }) async {}

  Future<void> onKilled({
    required GameActions actions,
    required NightEvent nightEvent,
  }) async {}
  Future<void> onVotedOut({
    required GameActions actions,
    required GamePlayer self,
  }) async {}
}
