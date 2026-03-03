import 'package:flutter/material.dart';
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
                'Wake the $title',
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
                  text: 'Please wake ',
                  children: [
                    TextSpan(
                      text: name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        foreground: Paint()
                          ..shader =
                              LinearGradient(
                                colors: [Colors.blue, color],
                              ).createShader(
                                const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                              ),
                      ),
                    ),
                    const TextSpan(text: ' and perform their action.'),
                  ],
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
                label: 'CONTINUE',
                color: color,
                onPressed: () => Navigator.pop(_ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 2. Pick player (unchanged API, small internal refactor) ────────────────

  static Future<String?> pickPlayer({
    required String title,
    required List<String> options,
    required IconData icon,
    required Color color,
    bool allowNone = true,

    /// Optional subtitle shown under the title.
    String? subtitle,
  }) async {
    final names = List<String>.from(options);
    if (allowNone) names.add("None");

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
                    final isNone = name == "None";
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

  // ── 3. Generic rich-option picker  ────────────────────────────────────────
  ///
  /// Use this when each option has its own icon/colour/subtitle — perfect for
  /// day-action signals, potion selection, special choices, etc.
  ///
  /// Example:
  /// ```dart
  /// final signal = await CharacterUI.pickOption<String>(
  ///   title: 'Barbie: choose your signal',
  ///   icon: FontAwesomeIcons.wandMagicSparkles,
  ///   color: Colors.pink,
  ///   options: [
  ///     CharacterOption(value: 'sleep', label: 'Put everyone to sleep',
  ///         icon: Icons.bedtime, color: Colors.indigo),
  ///     CharacterOption(value: 'kill',  label: 'Execute a player',
  ///         icon: Icons.dangerous, color: Colors.red),
  ///   ],
  /// );
  /// ```
  static Future<T?> pickOption<T>({
    required String title,
    required List<CharacterOption<T>> options,
    required IconData icon,
    required Color color,
    String? subtitle,
    bool allowDismiss = false,
  }) async {
    return await showDialog<T>(
      context: _ctx,
      barrierDismissible: allowDismiss,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: _cardDecoration(color),
          padding: const EdgeInsets.all(_kPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Options
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: options.map((opt) {
                      final c = opt.color ?? color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => Navigator.pop(_ctx, opt.value),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: c.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (opt.icon != null) ...[
                                  Icon(opt.icon, color: c, size: 22),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt.label,
                                        style: TextStyle(
                                          color: c,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (opt.subtitle != null)
                                        Text(
                                          opt.subtitle!,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.55,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: c.withValues(alpha: 0.5),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (allowDismiss) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(_ctx, null),
                    child: const Text(
                      'SKIP',
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. Day-signal picker  ─────────────────────────────────────────────────
  ///
  /// Specialised version of [pickOption] styled for day-phase signal events.
  /// Shows a prominent "DAY ACTION" badge. Returns the chosen signal value.
  ///
  /// Example (Barbie):
  /// ```dart
  /// final signal = await CharacterUI.pickSignal<String>(
  ///   characterName: 'Barbie',
  ///   characterIcon: FontAwesomeIcons.wandMagicSparkles,
  ///   characterColor: Colors.pinkAccent,
  ///   prompt: 'Choose your daytime signal',
  ///   signals: [
  ///     CharacterOption(value: 'everyone_sleep', label: 'Everyone, sleep!',
  ///         subtitle: 'Make all players close their eyes.',
  ///         icon: Icons.bedtime, color: Colors.indigo.shade300),
  ///     CharacterOption(value: 'execute', label: 'I choose you!',
  ///         subtitle: 'Secretly mark a player to kill.',
  ///         icon: Icons.dangerous, color: Colors.red.shade400),
  ///   ],
  /// );
  /// ```
  static Future<T?> pickSignal<T>({
    required String characterName,
    required IconData characterIcon,
    required Color characterColor,
    required String prompt,
  }) async {
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
                    const Text(
                      'DAY ACTION',
                      style: TextStyle(
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
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white38, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 5. Result / outcome dialog  ───────────────────────────────────────────
  ///
  /// Show the outcome of a character's action. Used after Seer reveal, potion
  /// use, kill confirmation, etc.
  static Future<void> showResult({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    String buttonLabel = 'OK',

    /// Small tag shown above the title (e.g. "NIGHT RESULT", "DAY RESULT").
    String? tag,
  }) async {
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
                label: buttonLabel,
                color: color,
                onPressed: () => Navigator.pop(_ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 6. Confirmation dialog  ───────────────────────────────────────────────
  ///
  /// Two-button confirm/cancel.  Returns `true` if confirmed.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await CharacterUI.confirm(
  ///   title: 'Use heal potion?',
  ///   message: 'This will save $name but you lose your heal forever.',
  ///   icon: Icons.favorite,
  ///   color: Colors.red,
  ///   confirmLabel: 'HEAL',
  /// );
  /// ```
  static Future<bool> confirm({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
  }) async {
    return await showDialog<bool>(
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
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(_ctx, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            cancelLabel,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrimaryButton(
                          label: confirmLabel,
                          color: color,
                          onPressed: () => Navigator.pop(_ctx, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
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

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDone;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDone,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: _kBgGradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
