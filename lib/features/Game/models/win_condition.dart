import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/features/Game/models/game_state.dart';

class WinCondition {
  final Team winningTeam; // null for special wins
  final List<GamePlayer>? winners; // specific winners for special conditions

  const WinCondition({required this.winningTeam, this.winners});
}
