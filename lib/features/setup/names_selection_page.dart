// names_selection_page.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/setup/providers/names_provider.dart';
import 'package:loup_garou/l10n/app_localizations.dart';

class NamesSelectionPage extends ConsumerStatefulWidget {
  const NamesSelectionPage({super.key});

  @override
  ConsumerState<NamesSelectionPage> createState() => _NamesSelectionPageState();
}

class _NamesSelectionPageState extends ConsumerState<NamesSelectionPage>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isReady = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final names = ref.read(namesProvider);
    if (names.contains(name)) {
      _showDuplicateSnackbar();
      _nameController.clear();
      return;
    }

    ref.read(namesProvider.notifier).addName(name);
    _nameController.clear();
    _nameFocusNode.requestFocus();
  }

  void _showDuplicateSnackbar() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.duplicatePlayerError),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _editPlayerName(int index, String currentName) {
    final l10n = AppLocalizations.of(context)!;
    final editController = TextEditingController(text: currentName);
    final FocusNode editFocusNode = FocusNode();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text(
          l10n.editName,
          style: const TextStyle(
            color: Color(0xFFd4af37),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: editController,
          focusNode: editFocusNode,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.enterPlayerName,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFd4af37)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFd4af37), width: 2),
            ),
          ),
          onSubmitted: (_) => Navigator.of(dialogContext).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = editController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                final names = ref.read(namesProvider);
                if (names.where((n) => n != currentName).contains(newName)) {
                  _showDuplicateSnackbar();
                  return;
                }
                ref.read(namesProvider.notifier).updateName(index, newName);
              }
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd4af37),
              foregroundColor: const Color(0xFF0a0e27),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((_) => {editController.dispose(), editFocusNode.dispose()});
  }

  /// Bottom sheet to pick from previously saved players
  void _showSavedPlayersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1f3a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) => _SavedPlayersSheet(
        onAdd: (name) => ref.read(namesProvider.notifier).addName(name),
        onAddMultiple: (names) =>
            ref.read(namesProvider.notifier).addNames(names),
        onDeleteFromSaved: (name) =>
            ref.read(namesProvider.notifier).removeFromSavedList(name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final names = ref.watch(namesProvider);
    final notifier = ref.read(namesProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
            ),
          ),
          child: !_isReady
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFd4af37)),
                )
              : Column(
                  children: [
                    // ── Header ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFd4af37),
                            ),
                            onPressed: () => context.pop(),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.addPlayers,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFd4af37),
                                ),
                              ),
                              Text(
                                l10n.playersAdded(names.length),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Input row ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          // Text field
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFFd4af37,
                                  ).withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      autofocus: names.length < 5 && _isReady,
                                      focusNode: _nameFocusNode,
                                      controller: _nameController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: l10n.typeAName,
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.4,
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        icon: const Icon(
                                          Icons.person_add,
                                          color: Color(0xFFd4af37),
                                        ),
                                      ),
                                      onSubmitted: (_) => _addPlayer(),
                                    ),
                                  ),
                                  // Add typed name
                                  IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFd4af37),
                                            Color(0xFFf5e6d3),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Color(0xFF0a0e27),
                                      ),
                                    ),
                                    onPressed: _addPlayer,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Saved-list picker button
                          Tooltip(
                            message: l10n.pickFromSavedPlayers,
                            child: GestureDetector(
                              onTap: _showSavedPlayersSheet,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFd4af37,
                                    ).withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.group,
                                  color: Color(0xFFd4af37),
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Min-players notice ───────────────────────────────
                    if (names.length < 5)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.minPlayersNeeded(5 - names.length),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Player list ──────────────────────────────────────
                    Expanded(
                      child: names.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_add,
                                    size: 80,
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.noPlayersYet,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.noPlayersHint,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              itemCount: names.length,
                              itemBuilder: (context, index) => _PlayerCard(
                                key: ValueKey(names[index]),
                                name: names[index],
                                index: index,
                                onRemove: () => notifier.removeAt(index),
                                onTap: () =>
                                    _editPlayerName(index, names[index]),
                              ),
                              onReorder: (oldIndex, newIndex) {
                                if (oldIndex < newIndex) newIndex -= 1;
                                notifier.moveName(oldIndex, newIndex);
                              },
                            ),
                    ),

                    // ── Continue button ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0a0e27).withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: _ContinueButton(
                          isEnabled: names.length >= 5,
                          playerCount: names.length,
                          onPressed: () async {
                            _nameFocusNode.unfocus();
                            await notifier.saveAsLastPlayed();
                            if (context.mounted) {
                              context.push("/role-selection");
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Saved Players Bottom Sheet ───────────────────────────────────────────────

class _SavedPlayersSheet extends ConsumerStatefulWidget {
  final void Function(String) onAdd;
  final void Function(List<String>) onAddMultiple;
  final void Function(String) onDeleteFromSaved;

  const _SavedPlayersSheet({
    required this.onAdd,
    required this.onAddMultiple,
    required this.onDeleteFromSaved,
  });

  @override
  ConsumerState<_SavedPlayersSheet> createState() => _SavedPlayersSheetState();
}

class _SavedPlayersSheetState extends ConsumerState<_SavedPlayersSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(namesProvider.notifier);
    // Re-derive on each build so removals reflect immediately
    final available = notifier.availableToAdd;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Handle + title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.savedPlayers,
                      style: const TextStyle(
                        color: Color(0xFFd4af37),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_selected.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          widget.onAddMultiple(_selected.toList());
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.check,
                          color: Color(0xFFd4af37),
                          size: 18,
                        ),
                        label: Text(
                          l10n.addCount(_selected.length),
                          style: const TextStyle(color: Color(0xFFd4af37)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12),

          // List
          Expanded(
            child: available.isEmpty
                ? Center(
                    child: Text(
                      l10n.allSavedAlreadyAdded,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: available.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemBuilder: (_, i) {
                      final name = available[i];
                      final isSelected = _selected.contains(name);
                      return ListTile(
                        onTap: () => setState(
                          () => isSelected
                              ? _selected.remove(name)
                              : _selected.add(name),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? const Color(0xFFd4af37)
                              : Colors.white.withValues(alpha: 0.08),
                          child: Icon(
                            isSelected ? Icons.check : Icons.person,
                            color: isSelected
                                ? const Color(0xFF0a0e27)
                                : Colors.white54,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFd4af37)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          onPressed: () {
                            _selected.remove(name);
                            widget.onDeleteFromSaved(name);
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Bottom action bar
          if (available.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _selected.addAll(available)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFd4af37)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        l10n.selectAll,
                        style: const TextStyle(color: Color(0xFFd4af37)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selected.isEmpty
                          ? null
                          : () {
                              widget.onAddMultiple(_selected.toList());
                              Navigator.of(context).pop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd4af37),
                        foregroundColor: const Color(0xFF0a0e27),
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _selected.isEmpty
                            ? l10n.addSelected
                            : l10n.addCount(_selected.length),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selected.isEmpty
                              ? Colors.white.withValues(alpha: 0.3)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Player Card (unchanged logic, kept local) ────────────────────────────────
class _FastDelayedDragStartListener extends ReorderableDragStartListener {
  const _FastDelayedDragStartListener({
    required super.index,
    required super.child,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(
      delay: const Duration(milliseconds: 200),
      debugOwner: this,
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _PlayerCard({
    required super.key,
    required this.name,
    required this.index,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFd4af37).withValues(alpha: 0.2),
        ),
      ),
      child: _FastDelayedDragStartListener(
        index: index,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.drag_indicator,
              color: Color(0xFF0a0e27),
              size: 20,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.red.shade400),
            onPressed: onRemove,
          ),
        ),
      ),
    );
  }
}

// ── Continue Button ──────────────────────────────────────────────────────────

class _ContinueButton extends StatelessWidget {
  final bool isEnabled;
  final int playerCount;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.isEnabled,
    required this.playerCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
                )
              : null,
          color: isEnabled ? null : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFd4af37).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEnabled
                  ? l10n.continueWithPlayers(playerCount)
                  : l10n.addAtLeast5Players,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isEnabled
                    ? const Color(0xFF0a0e27)
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
            if (isEnabled) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Color(0xFF0a0e27)),
            ],
          ],
        ),
      ),
    );
  }
}
