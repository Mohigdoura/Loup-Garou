import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loup_garou/features/setup/providers/names_provider.dart';

class NamesSelectionPage extends ConsumerStatefulWidget {
  const NamesSelectionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NamesSelectionPageState();
}

class _NamesSelectionPageState extends ConsumerState<NamesSelectionPage>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _listAnimationController;
  final FocusNode _nameFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // Use ref.read for both - don't use ref.watch in callbacks!
      final names = ref.read(namesProvider);

      // Check for duplicates
      if (names.contains(name)) {
        _nameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Player name already exists!'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      // Call addName - no need for setState since Riverpod handles it
      ref.read(namesProvider.notifier).addName(name);
      _nameController.clear();
      _listAnimationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final names = ref.watch(namesProvider);
    final namesNotifier = ref.read(namesProvider.notifier);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d1b3d)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                        const Text(
                          'Add Players',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFd4af37),
                          ),
                        ),
                        Text(
                          '${names.length} ${names.length == 1 ? "player" : "players"} added',
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

              // Input section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFd4af37).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          autofocus: names.length < 5,
                          focusNode: _nameFocusNode,
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter player name',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            border: InputBorder.none,
                            icon: const Icon(
                              Icons.person_add,
                              color: Color(0xFFd4af37),
                            ),
                          ),
                          onSubmitted: (_) {
                            _addPlayer();
                            _nameFocusNode.requestFocus();
                          },
                        ),
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFd4af37), Color(0xFFf5e6d3)],
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

              // Minimum players notice
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
                            'Minimum ${5 - names.length} more ${5 - names.length == 1 ? "player" : "players"} needed',
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

              // Players list
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
                              'No players added yet',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey(names.length),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: names.length,
                        itemBuilder: (context, index) {
                          return _PlayerCard(
                            name: names[index],
                            index: index,
                            onRemove: () async {
                              await namesNotifier.removeAt(index);
                            },
                          );
                        },
                      ),
              ),

              // Bottom button
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
                    onPressed: () {
                      _nameFocusNode.unfocus();
                      context.push("/role-selection");
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

class _PlayerCard extends StatelessWidget {
  final String name;
  final int index;
  final VoidCallback onRemove;

  const _PlayerCard({
    required this.name,
    required this.index,
    required this.onRemove,
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
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

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
          onPressed: () => onRemove(),
        ),
      ),
    );
  }
}

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
                  ? 'CONTINUE WITH $playerCount PLAYERS'
                  : 'ADD AT LEAST 5 PLAYERS',
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
              Icon(Icons.arrow_forward, color: const Color(0xFF0a0e27)),
            ],
          ],
        ),
      ),
    );
  }
}
