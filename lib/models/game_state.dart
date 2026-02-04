import 'package:loup_garou/models/game_character.dart';

class GamePlayer {
  final String name;
  final GameCharacter gameCharacter;
  int lives;
  bool isSilenced;

  GamePlayer({
    required this.name,
    required this.gameCharacter,
    int? lives,
    this.isSilenced = false,
  }) : lives = lives ?? gameCharacter.lives;

  bool get isAlive => lives > 0;
  bool get isDead => lives == 0;
  void killPlayer() {
    lives--;
  }

  GamePlayer copyWith({
    String? name,
    GameCharacter? gameCharacter,
    int? lives,
    bool? isSilenced,
  }) {
    return GamePlayer(
      name: name ?? this.name,
      gameCharacter: gameCharacter ?? this.gameCharacter,
      lives: lives ?? this.lives,
      isSilenced: isSilenced ?? this.isSilenced,
    );
  }
}

class GameState {
  final List<GamePlayer> players;
  List<GamePlayer> talkingOrder;
  int nightCount = 1;
  String? gameOverMessage;
  bool isNight = true;

  GameState({required this.players}) : talkingOrder = [...players];
  copyWith({
    List<GamePlayer>? players,
    List<GamePlayer>? talkingOrder,
    int? nightCount,
    bool? isNight,
    String? gameOverMessage,
  }) {
    final newState = GameState(players: players ?? this.players);
    newState.talkingOrder = talkingOrder ?? this.talkingOrder;
    newState.nightCount = nightCount ?? this.nightCount;
    newState.isNight = isNight ?? this.isNight;
    newState.gameOverMessage = gameOverMessage ?? this.gameOverMessage;
    return newState;
  }
}
