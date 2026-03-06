import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/l10n/app_localizations.dart';
import 'package:loup_garou/language/language.dart';
import 'package:loup_garou/language/language_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
          ),
        ),
        child: Stack(
          children: [
            // Star field background
            ...List.generate(30, (index) {
              return Positioned(
                left: (index * 37) % MediaQuery.of(context).size.width,
                top: (index * 53) % MediaQuery.of(context).size.height,
                child: Container(
                  width: 2 + (index % 3).toDouble(),
                  height: 2 + (index % 3).toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(
                                  0xFFd4af37,
                                ).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFFd4af37),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFf5e6d3), Color(0xFFd4af37)],
                          ).createShader(bounds),
                          child: Text(
                            l10n.settings,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFd4af37).withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Settings content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Language section
                          _SettingsSection(
                            title: l10n.settingsLanguage,
                            icon: Icons.language_rounded,
                            child: _LanguageSelector(),
                          ),

                          const SizedBox(height: 20),

                          // Danger zone
                          _SettingsSection(
                            title: l10n.settingsDangerZone,
                            icon: Icons.warning_amber_rounded,
                            iconColor: const Color(0xFFe05c5c),
                            titleColor: const Color(0xFFe05c5c),
                            child: _WipeDataButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Settings Section Card ────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFd4af37);
    final resolvedIcon = iconColor ?? gold;
    final resolvedTitle = titleColor ?? gold;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1f3a).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: resolvedIcon.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: resolvedIcon.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(icon, color: resolvedIcon, size: 18),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: resolvedTitle,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: resolvedIcon.withValues(alpha: 0.15)),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }
}

// ─── Language Selector ────────────────────────────────────────────────────────

class _LanguageSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsLanguageLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsLanguageDesc,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StyledLanguagePopup(
          currentLanguage: language,
          onSelected: (value) =>
              ref.read(languageProvider.notifier).setLanguage(value),
        ),
      ],
    );
  }
}

class _StyledLanguagePopup extends StatelessWidget {
  final Language currentLanguage;
  final ValueChanged<Language> onSelected;

  const _StyledLanguagePopup({
    required this.currentLanguage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Language>(
      onSelected: onSelected,
      color: const Color(0xFF1a1f3a),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFd4af37).withValues(alpha: 0.3)),
      ),
      elevation: 8,
      itemBuilder: (context) => [
        for (final lang in Language.values)
          PopupMenuItem<Language>(
            value: lang,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  lang.name,
                  style: TextStyle(
                    color: lang == currentLanguage
                        ? const Color(0xFFd4af37)
                        : Colors.white.withValues(alpha: 0.85),
                    fontWeight: lang == currentLanguage
                        ? FontWeight.w700
                        : FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                if (lang == currentLanguage) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    color: Color(0xFFd4af37),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFd4af37).withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFd4af37).withValues(alpha: 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentLanguage.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              currentLanguage.name,
              style: const TextStyle(
                color: Color(0xFFd4af37),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFFd4af37),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wipe Data Button ─────────────────────────────────────────────────────────

class _WipeDataButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsWipeData,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsWipeDataDesc,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _WipeButton(
          onConfirmed: () {
            // TODO: call your wipe data provider here
            // e.g. ref.read(dataProvider.notifier).wipeAll();
          },
        ),
      ],
    );
  }
}

class _WipeButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  const _WipeButton({required this.onConfirmed});

  @override
  State<_WipeButton> createState() => _WipeButtonState();
}

class _WipeButtonState extends State<_WipeButton> {
  bool _isPressed = false;

  void _showConfirmDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFe05c5c).withValues(alpha: 0.4),
          ),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFe05c5c),
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              l10n.settingsWipeConfirmTitle,
              style: const TextStyle(
                color: Color(0xFFe05c5c),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.settingsWipeConfirmMessage,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.6,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ctx.pop();
              widget.onConfirmed();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFe05c5c).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFe05c5c).withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                l10n.settingsWipeConfirm,
                style: const TextStyle(
                  color: Color(0xFFe05c5c),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showConfirmDialog(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFe05c5c).withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFFe05c5c).withValues(alpha: 0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFe05c5c),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'WIPE',
                style: TextStyle(
                  color: Color(0xFFe05c5c),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
