import 'package:flutter/material.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/main.dart';
import 'package:loup_garou/models/game_character.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHARED THEME CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────

const _kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
);

const _kBorderRadius = 24.0;
const _kPadding = 24.0;

BoxDecoration _cardDecoration(Color color, {double borderOpacity = 0.5}) =>
    BoxDecoration(
      gradient: _kBgGradient,
      borderRadius: BorderRadius.circular(_kBorderRadius),
      border: Border.all(
        color: color.withValues(alpha: borderOpacity),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 20,
          spreadRadius: 4,
        ),
      ],
    );

// ─────────────────────────────────────────────────────────────────────────────
// OPTION MODEL  (used by pickOption / showSignalPicker)
// ─────────────────────────────────────────────────────────────────────────────

class CharacterOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? color;

  const CharacterOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CHARACTER UI
// ─────────────────────────────────────────────────────────────────────────────

class CharacterUI {
  // ── helpers ──────────────────────────────────────────────────────────────

  static BuildContext get _ctx => navigatorKey.currentContext!;
  static AppLocalizations get _l10n => AppLocalizations.of(_ctx)!;

  // ── 1. Wake-phase announcement ────────────────────────────────────────────
  /// Get color for a character type
  static Color getColorForCharacter(GameCharacter character) {
    switch (character.team) {
      case Team.village:
        return Colors.blue.shade400;
      case Team.wolves:
        return Colors.red.shade400;
      case Team.solo:
        return Colors.purple.shade400;
    }
  }

  static Future<void> showWakePhase({
    required String title,
    required String name,
    required IconData icon,
    required Color color,

    /// Optional extra body text shown below the default message.
    String? extraMessage,
  }) async {
    final l10n = _l10n;
    await showDialog(
      context: _ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: _cardDecoration(color),
          padding: const EdgeInsets.all(_kPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.wakePhaseTitle(title),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  // Split the localised string around the player name so we
                  // can apply the gradient span to just the name portion.
                  // The ARB message is: "Please wake {name} and perform their action."
                  // We split on the name to reconstruct the three spans.
                  children: _buildWakeMessageSpans(
                    l10n.wakePhaseMessage(name),
                    name,
                    color,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              if (extraMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  extraMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _PrimaryButton(
                label: l10n.continueButton,
                color: color,
                onPressed: () => Navigator.pop(_ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Splits [fullMessage] on [name] to rebuild three [TextSpan]s so the name
  /// can be rendered with its gradient style, exactly as before.
  static List<InlineSpan> _buildWakeMessageSpans(
    String fullMessage,
    String name,
    Color color,
  ) {
    final parts = fullMessage.split(name);
    if (parts.length < 2) {
      // Fallback: render plain text if the name isn't found in the string.
      return [TextSpan(text: fullMessage)];
    }
    return [
      TextSpan(text: parts.first),
      TextSpan(
        text: name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          foreground: Paint()
            ..shader = LinearGradient(
              colors: [Colors.blue, color],
            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
        ),
      ),
      TextSpan(text: parts.sublist(1).join(name)),
    ];
  }

  // ── 2. Pick player ────────────────────────────────────────────────────────

  static Future<String?> pickPlayer({
    required String title,
    required List<String> options,
    required IconData icon,
    required Color color,
    bool allowNone = true,

    /// Optional subtitle shown under the title.
    String? subtitle,
  }) async {
    final l10n = _l10n;
    final names = List<String>.from(options);
    final noneLabel = l10n.noneOption;
    if (allowNone) names.add(noneLabel);

    return await showDialog<String>(
      context: _ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: _cardDecoration(color),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              // List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    final name = names[index];
                    final isNone = name == noneLabel;
                    return InkWell(
                      onTap: () => Navigator.pop(_ctx, isNone ? null : name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isNone
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: isNone ? Colors.white38 : Colors.white,
                                  fontSize: 16,
                                  fontStyle: isNone
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                            if (!isNone)
                              Icon(
                                Icons.arrow_forward_ios,
                                color: color.withValues(alpha: 0.5),
                                size: 14,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> pickSignal<T>({
    required String characterName,
    required IconData characterIcon,
    required Color characterColor,
    required String prompt,
  }) async {
    final l10n = _l10n;
    return await showDialog<T>(
      context: _ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 560),
          decoration: _cardDecoration(characterColor),
          padding: const EdgeInsets.all(_kPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DAY badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.amber, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      l10n.dayActionBadge,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Character icon + name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(characterIcon, color: characterColor, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    characterName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: characterColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                prompt,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(_ctx, null),
                child: Text(
                  l10n.pickSignalDoneButton,
                  style: const TextStyle(
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 5. Result / outcome dialog  ───────────────────────────────────────────
  static Future<void> showResult({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    String? buttonLabel,

    /// Small tag shown above the title (e.g. "NIGHT RESULT", "DAY RESULT").
    String? tag,
  }) async {
    final l10n = _l10n;
    await showDialog(
      context: _ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: _cardDecoration(color),
          padding: const EdgeInsets.all(_kPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tag != null) ...[
                _TagBadge(label: tag, color: color),
                const SizedBox(height: 12),
              ],
              Icon(icon, size: 64, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 15, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: buttonLabel ?? l10n.defaultResultButton,
                color: color,
                onPressed: () => Navigator.pop(_ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TagBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
