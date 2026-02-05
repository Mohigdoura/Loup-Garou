import 'package:loup_garou/features/Game/models/win_condition.dart';
import 'package:loup_garou/models/game_character.dart';

class GamePlayer {
  final String name;
  final GameCharacter gameCharacter;
  final int lives;
  final bool isSilenced;
  final Map<String, dynamic>
  characterState; // ✅ NEW: Per-player character state

  GamePlayer({
    required this.name,
    required this.gameCharacter,
    int? lives,
    this.isSilenced = false,
    Map<String, dynamic>? characterState,
  }) : lives = lives ?? gameCharacter.lives,
       characterState = characterState ?? {};

  bool get isAlive => lives > 0;
  bool get isDead => !isAlive;

  GamePlayer copyWith({
    String? name,
    GameCharacter? gameCharacter,
    int? lives,
    bool? isSilenced,
    Map<String, dynamic>? characterState,
  }) {
    return GamePlayer(
      name: name ?? this.name,
      gameCharacter: gameCharacter ?? this.gameCharacter,
      lives: lives ?? this.lives,
      isSilenced: isSilenced ?? this.isSilenced,
      characterState: characterState ?? Map.from(this.characterState),
    );
  }
}

class GameState {
  final List<GamePlayer> players;
  final List<GamePlayer> talkingOrder;
  final int nightCount;
  final bool isNight;
  final WinCondition? winCondition;

  GameState({
    required this.players,
    List<GamePlayer>? talkingOrder,
    this.nightCount = 1,
    this.isNight = true,
    this.winCondition,
  }) : talkingOrder = talkingOrder ?? [...players];

  GameState copyWith({
    List<GamePlayer>? players,
    List<GamePlayer>? talkingOrder,
    int? nightCount,
    bool? isNight,
    WinCondition? winCondition,
  }) {
    return GameState(
      players: players ?? this.players,
      talkingOrder: talkingOrder ?? this.talkingOrder,
      nightCount: nightCount ?? this.nightCount,
      isNight: isNight ?? this.isNight,
      winCondition: winCondition ?? this.winCondition,
    );
  }

  /// Helper: Get all alive players
  List<GamePlayer> get alivePlayers => players.where((p) => p.isAlive).toList();

  /// Helper: Get all dead players
  List<GamePlayer> get deadPlayers => players.where((p) => p.isDead).toList();

  /// Helper: Get all alive wolves
  List<GamePlayer> get aliveWolves => players
      .where((p) => p.isAlive && p.gameCharacter.team == Team.wolves)
      .toList();

  /// Helper: Get all alive villagers
  List<GamePlayer> get aliveVillagers => players
      .where((p) => p.isAlive && p.gameCharacter.team == Team.village)
      .toList();

  /// Helper: Get all alive solo players
  List<GamePlayer> get aliveSolos => players
      .where((p) => p.isAlive && p.gameCharacter.team == Team.solo)
      .toList();

  /// Helper: Find player by name
  GamePlayer? findPlayerByName(String name) {
    try {
      return players.firstWhere((p) => p.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Helper: Update a specific player
  GameState updatePlayer(
    String playerName,
    GamePlayer Function(GamePlayer) updater,
  ) {
    final updatedPlayers = players.map((p) {
      if (p.name == playerName) {
        return updater(p);
      }
      return p;
    }).toList();

    return copyWith(players: updatedPlayers);
  }

  /// Helper: Kill a player (reduce lives by 1)
  GameState killPlayer(String playerName) {
    return updatePlayer(playerName, (p) => p.copyWith(lives: p.lives - 1));
  }

  GameState votePlayerOut(String playerName) {
    return updatePlayer(playerName, (p) => p.copyWith(lives: 0));
  }

  /// Helper: Silence/unsilence a player
  GameState setPlayerSilenced(String playerName, bool silenced) {
    return updatePlayer(playerName, (p) => p.copyWith(isSilenced: silenced));
  }

  bool get isGameOver => winCondition != null;
}
