import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/shop/providers/shop_provider.dart';
import 'package:loup_garou/models/game_character.dart';
import 'package:loup_garou/models/game_characters.dart';

/// Role selection state using role names as identifiers
class RoleSelection {
  final Map<String, int> selectedCounts;
  final int targetTotal;

  RoleSelection({required this.selectedCounts, required this.targetTotal});

  int get currentTotal =>
      selectedCounts.values.fold(0, (sum, count) => sum + count);

  int get remainingSlots => targetTotal - currentTotal;

  bool get isComplete => currentTotal == targetTotal;

  bool canIncrement() {
    if (currentTotal >= targetTotal) return false;

    return true;
  }

  bool canDecrement(GameCharacter role) {
    final count = selectedCounts[role.name] ?? 0;

    if (count <= 0) return false;

    return true;
  }

  int getCount(GameCharacter role) => selectedCounts[role.name] ?? 0;

  bool isSelected(GameCharacter role) => (selectedCounts[role.name] ?? 0) > 0;

  RoleSelection copyWith({Map<String, int>? selectedCounts, int? targetTotal}) {
    return RoleSelection(
      selectedCounts: selectedCounts ?? Map.from(this.selectedCounts),
      targetTotal: targetTotal ?? this.targetTotal,
    );
  }
}

class RoleSelectionNotifier extends Notifier<RoleSelection> {
  @override
  RoleSelection build() {
    final initialCounts = <String, int>{};
    return RoleSelection(selectedCounts: initialCounts, targetTotal: 0);
  }

  void setTargetTotal(int total) {
    state = state.copyWith(targetTotal: total);
  }

  void increment(GameCharacter role) {
    if (!state.canIncrement()) return;

    final current = state.selectedCounts[role.name] ?? 0;
    final newCounts = Map<String, int>.from(state.selectedCounts);
    newCounts[role.name] = current + 1;

    state = state.copyWith(selectedCounts: newCounts);
  }

  void decrement(GameCharacter role) {
    if (!state.canDecrement(role)) return;

    final current = state.selectedCounts[role.name] ?? 0;
    final newCounts = Map<String, int>.from(state.selectedCounts);

    if (current - 1 == 0) {
      newCounts.remove(role.name);
    } else {
      newCounts[role.name] = current - 1;
    }

    state = state.copyWith(selectedCounts: newCounts);
  }

  void reset() {
    final initialCounts = <String, int>{};

    state = RoleSelection(
      selectedCounts: initialCounts,
      targetTotal: state.targetTotal,
    );
  }
}

final roleSelectionProvider =
    NotifierProvider<RoleSelectionNotifier, RoleSelection>(() {
      return RoleSelectionNotifier();
    });

/// Configuration for a paid role
class PaidRoleConfig {
  final GameCharacter role;
  final int price;

  const PaidRoleConfig({required this.role, required this.price});
}

class RolesNotifier extends Notifier<List<GameCharacter>> {
  @override
  List<GameCharacter> build() {
    return [];
  }

  // Singleton instances - one per role type
  static final _ancient = Ancient();
  static final _seer = Seer();
  static final _protector = Protector();
  static final _doctor = Doctor();
  static final _villager = Villager();
  static final _simpleWolf = SimpleWolf();
  static final _whiteWolf = WhiteWolf();
  static final _blackWolf = BlackWolf();
  static final _witch = Witch();
  static final _hunter = Hunter();
  static final _cursedChild = CursedChild();
  static final _clown = Clown();
  static final _serialKiller = SerialKiller();
  static final _avenger = Avenger();
  static final _littlePrince = LittlePrince();
  static final _littlePrincess = LittlePrincess();
  static final _barbie = Barbie();
  static final _graveRobber = GraveRobber();

  List<GameCharacter> get _freeRoles => [
    _ancient,
    _seer,
    _protector,
    _villager,
    _simpleWolf,
    _whiteWolf,
  ];

  final List<PaidRoleConfig> _paidRolesConfig = [
    PaidRoleConfig(role: _witch, price: 100),
    PaidRoleConfig(role: _doctor, price: 100),
    PaidRoleConfig(role: _blackWolf, price: 100),
    PaidRoleConfig(role: _hunter, price: 250),
    PaidRoleConfig(role: _cursedChild, price: 350),
    PaidRoleConfig(role: _clown, price: 500),
    PaidRoleConfig(role: _serialKiller, price: 750),
    PaidRoleConfig(role: _avenger, price: 350),
    PaidRoleConfig(role: _littlePrince, price: 750),
    PaidRoleConfig(role: _littlePrincess, price: 750),
    PaidRoleConfig(role: _barbie, price: 500),
    PaidRoleConfig(role: _graveRobber, price: 500),
  ];

  // Much simpler!
  GameCharacter? createRoleByName(String name) {
    // Try free roles first
    final freeRole = _freeRoles.where((r) => r.name == name).firstOrNull;
    if (freeRole != null) return freeRole;

    // Try paid roles
    return _paidRolesConfig.where((c) => c.role.name == name).firstOrNull?.role;
  }

  // No more factory functions needed!
  void buildFromSelection(Map<String, int> selectedCounts) {
    clear();

    selectedCounts.forEach((roleName, count) {
      final role = createRoleByName(roleName);
      if (role != null) {
        for (int i = 0; i < count; i++) {
          addRole(role); // Same instance, no problem!
        }
      }
    });
  }

  /// Get all available roles (free + purchased paid roles)
  List<GameCharacter> getAllAvailableRoles() {
    final purchasedNames = ref.read(shopProvider);
    final availableRoles = [..._freeRoles];

    for (final config in _paidRolesConfig) {
      if (purchasedNames.contains(config.role.name)) {
        availableRoles.add(config.role);
      }
    }

    return availableRoles;
  }

  /// Get all unpurchased paid role configurations
  List<PaidRoleConfig> getUnpurchasedRoles() {
    final purchasedNames = ref.read(shopProvider);
    return _paidRolesConfig
        .where((config) => !purchasedNames.contains(config.role.name))
        .toList();
  }

  List<String> getAllPaidRoleNames() {
    return _paidRolesConfig.map((config) => config.role.name).toList();
  }

  /// Get all purchased paid role templates
  List<GameCharacter> getPurchasedRoles() {
    final purchasedNames = ref.read(shopProvider);
    return _paidRolesConfig
        .where((config) => purchasedNames.contains(config.role.name))
        .map((config) => config.role)
        .toList();
  }

  void addRole(GameCharacter role) {
    state = [...state, role];
  }

  void clear() {
    state = [];
  }
}

final rolesProvider = NotifierProvider<RolesNotifier, List<GameCharacter>>(() {
  return RolesNotifier();
});
