/// What kind of interaction the UI needs to present
enum ActionType {
  /// Just show wake up X confirmation
  wakeUp,

  /// Pick one player from a list
  pickPlayer,

  /// Pick clockwise/counter-clockwise
  pickDirection,

  /// Special multi-step witch interaction
  witchMenu,

  /// Show a result (e.g. Seer: "X is/is not a wolf") then advance
  showResult,
}

/// Metadata a character provides about what it needs from the UI.
/// This is a pure data class with no Flutter dependencies.
class ActionRequirement {
  final ActionType type;
  final String title;
  final String description;
  final List<String> options;
  final Map<String, dynamic> metadata;

  const ActionRequirement({
    required this.type,
    required this.title,
    this.description = '',
    this.options = const [],
    this.metadata = const {},
  });
}
