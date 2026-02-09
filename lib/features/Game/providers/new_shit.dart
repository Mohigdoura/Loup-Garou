
enum InputFilter {
    All;
    AllButMe;
    Wolfs;
    Villagers;
    Dead;
}

int ChooseAPlayer(InputFilter filter) {
    // UI waryy lista mte3 ll players by its filter
}

mixin Killer    { int kill()    { return ChooseAPlayer(AllButMe); } }
mixin Seer      { int see()     { return ChooseAPlayer(AllButMe); } }
mixin Protector { int protect() { return ChooseAPlayer(All); } }
mixin Reviver   { int revive()  { return ChooseAPlayer(Dead); } }
mixin Muter     { int mute()    { return ChooseAPlayer(All); } }

enum Result {
    None;
    Safe;
    Wolf;
}

abstract class Player {
    final String name;
    final bool alive = true;
    final bool protected = false;
    final int periority;
    Player(this.name, this.periority);
    abstract Result seerResult();
}

class Voyant    extends Player with Seer   { Voyant(super.name, 2);    Result seerResult() { return Safe; } }
class LoupNoir  extends Player with Muter  { LoupNoir(super.name, 3);  Result seerResult() { return Wolf; } }
class LoupBlanc extends Player with Killer { LoupBlanc(super.name, 3); Result seerResult() { return Wolf; } }
class Sorcier   extends Player with Killer, Reviver { Sorcier(super.name, 4); Result seerResult() { return Safe; } }
class Protecteur extends Player with Protector { Protecteur(super.name, 1); Result seerResult() { return Safe; } }

class Game {
    final List<Player> players;
    final List<int> going_to_die;

    void NightShit() {

        Map<int, Player> p_this_round = Map.fromEntries(
            players
                .asMap()
                .entries
                .where((p) => p.alive)
                .toList()
            ..sort((a, b) => a.value.priority.compareTo(b.value.priority)),
        );

        for p in p_this_round {
            if (p is Killer) {
                if (!p.protected) going_to_die.push(p.kill());
            }
            if (p is Protector) p_this_round[p.protect()].protected = true;
            if (p is Reviver) going_to_die.remove(p.revive());
            // ...

            for (gonna_die in going_to_die) {
                players[gonna_die].alive = false;
            }
        }
    }
}