import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loup_garou/features/shop/shop_provider.dart';
import 'package:loup_garou/models/game_character.dart';

/// Role selection state using role names as identifiers
class RoleSelection {
  final Map<String, int> selectedCounts;
  final int targetTotal;

  RoleSelection({required this.selectedCounts, required this.targetTotal});

  int get currentTotal =>
      selectedCounts.values.fold(0, (sum, count) => sum + count);

  int get remainingSlots => targetTotal - currentTotal;

  bool get isComplete => currentTotal == targetTotal;

  bool canIncrement(GameCharacter role) {
    final count = selectedCounts[role.name] ?? 0;

    if (currentTotal >= targetTotal) return false;
    if (role.isUnique && count >= 1) return false;

    return true;
  }

  bool canDecrement(GameCharacter role) {
    final count = selectedCounts[role.name] ?? 0;

    if (count <= 0) return false;
    if (role.isMandatory && role.isUnique) return false;
    if (role.isMandatory && count <= 1) return false;

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
    final allRoles = ref.read(rolesProvider.notifier).getAllAvailableRoles();

    for (final role in allRoles) {
      if (role.isMandatory && role.isUnique) {
        initialCounts[role.name] = 1;
      } else if (role.isMandatory) {
        initialCounts[role.name] = 1;
      }
    }

    return RoleSelection(selectedCounts: initialCounts, targetTotal: 0);
  }

  void setTargetTotal(int total) {
    state = state.copyWith(targetTotal: total);
  }

  void increment(GameCharacter role) {
    if (!state.canIncrement(role)) return;

    final current = state.selectedCounts[role.name] ?? 0;
    final newCounts = Map<String, int>.from(state.selectedCounts);
    newCounts[role.name] = current + 1;

    state = state.copyWith(selectedCounts: newCounts);
  }

  void decrement(GameCharacter role) {
    if (!state.canDecrement(role)) return;

    final current = state.selectedCounts[role.name] ?? 0;
    final newCounts = Map<String, int>.from(state.selectedCounts);

    if (current - 1 == 0 && !role.isMandatory) {
      newCounts.remove(role.name);
    } else {
      newCounts[role.name] = current - 1;
    }

    state = state.copyWith(selectedCounts: newCounts);
  }

  void reset() {
    final initialCounts = <String, int>{};
    final allRoles = ref.read(rolesProvider.notifier).getAllAvailableRoles();

    for (final role in allRoles) {
      if (role.isMandatory && role.isUnique) {
        initialCounts[role.name] = 1;
      } else if (role.isMandatory) {
        initialCounts[role.name] = 1;
      }
    }

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
  final String roleName;
  final int price;
  final GameCharacter Function() createInstance;

  const PaidRoleConfig({
    required this.roleName,
    required this.price,
    required this.createInstance,
  });
}

class RolesNotifier extends Notifier<List<GameCharacter>> {
  @override
  List<GameCharacter> build() {
    return [];
  }

  // Base free roles - using factory functions for fresh instances
  List<GameCharacter> get _freeRoles => [
    Ancient(),
    Seer(),
    Protector(),
    Villager(),
    SimpleWolf(),
    WhiteWolf(),
    BlackWolf(),
  ];

  // Paid roles configuration with prices
  final List<PaidRoleConfig> _paidRolesConfig = const [
    PaidRoleConfig(roleName: 'Witch', price: 100, createInstance: Witch.new),
    PaidRoleConfig(roleName: 'Hunter', price: 150, createInstance: Hunter.new),
  ];

  /// Get map of paid role names to their prices
  Map<String, int> getPaidRolePrices() {
    return {
      for (final config in _paidRolesConfig) config.roleName: config.price,
    };
  }

  /// Get all paid role configurations
  List<PaidRoleConfig> getPaidRoleConfigs() => _paidRolesConfig;

  /// Create a fresh role instance by name
  GameCharacter? createRoleByName(String name) {
    // Check free roles
    for (final role in _freeRoles) {
      if (role.name == name) {
        // Return the role's type constructor
        return role.runtimeType.toString() == 'Ancient'
            ? Ancient()
            : role.runtimeType.toString() == 'Seer'
            ? Seer()
            : role.runtimeType.toString() == 'Protector'
            ? Protector()
            : role.runtimeType.toString() == 'Villager'
            ? Villager()
            : role.runtimeType.toString() == 'SimpleWolf'
            ? SimpleWolf()
            : role.runtimeType.toString() == 'WhiteWolf'
            ? WhiteWolf()
            : role.runtimeType.toString() == 'BlackWolf'
            ? BlackWolf()
            : null;
      }
    }

    // Check paid roles
    for (final config in _paidRolesConfig) {
      if (config.roleName == name) {
        return config.createInstance();
      }
    }

    return null;
  }

  /// Get a template role instance by name (for display purposes)
  GameCharacter? getRoleTemplateByName(String name) {
    // Check free roles
    final freeRole = _freeRoles.where((role) => role.name == name).firstOrNull;
    if (freeRole != null) return freeRole;

    // Check paid roles
    final paidConfig = _paidRolesConfig
        .where((config) => config.roleName == name)
        .firstOrNull;
    if (paidConfig != null) return paidConfig.createInstance();

    return null;
  }

  /// Get all available roles (free + purchased paid roles)
  List<GameCharacter> getAllAvailableRoles() {
    final purchasedNames = ref.read(shopProvider);
    final availableRoles = [..._freeRoles];

    for (final config in _paidRolesConfig) {
      if (purchasedNames.contains(config.roleName)) {
        availableRoles.add(config.createInstance());
      }
    }

    return availableRoles;
  }

  /// Get all unpurchased paid role configurations
  List<PaidRoleConfig> getUnpurchasedRoles() {
    final purchasedNames = ref.read(shopProvider);
    return _paidRolesConfig
        .where((config) => !purchasedNames.contains(config.roleName))
        .toList();
  }

  /// Get all purchased paid role templates
  List<GameCharacter> getPurchasedRoles() {
    final purchasedNames = ref.read(shopProvider);
    return _paidRolesConfig
        .where((config) => purchasedNames.contains(config.roleName))
        .map((config) => config.createInstance())
        .toList();
  }

  void addRole(GameCharacter role) {
    state = [...state, role];
  }

  void shuffle() {
    state = [...state]..shuffle();
  }

  void clear() {
    state = [];
  }

  /// Build roles from selection map (uses role names as keys)
  void buildFromSelection(Map<String, int> selectedCounts) {
    clear();

    selectedCounts.forEach((roleName, count) {
      for (int i = 0; i < count; i++) {
        // Create fresh instance for each role
        final role = createRoleByName(roleName);
        if (role != null) {
          addRole(role);
        }
      }
    });
  }
}

final rolesProvider = NotifierProvider<RolesNotifier, List<GameCharacter>>(() {
  return RolesNotifier();
});
