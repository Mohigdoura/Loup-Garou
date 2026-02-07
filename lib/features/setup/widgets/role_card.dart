import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loup_garou/models/game_character.dart';

class RoleCard extends StatelessWidget {
  final GameCharacter role;
  final int count;
  final bool isSelected;
  final bool canIncrement;
  final bool canDecrement;
  final Color teamColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const RoleCard({
    required this.role,
    required this.count,
    required this.isSelected,
    required this.canIncrement,
    required this.canDecrement,
    required this.teamColor,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        // Use InkWell for visual feedback (ripples)
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAbilityDialog(context),
        child: Ink(
          // Use Ink to allow the decoration to show behind InkWell
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? teamColor : Colors.white10,
              width: isSelected ? 2 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isSelected
                    ? teamColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              // Changed to Row for better layout management
              children: [
                _buildRoleIcon(),
                const SizedBox(width: 16),
                Expanded(child: _buildRoleInfo()),

                // This is the critical part:
                // We wrap the control in a widget that stops the tap from reaching the InkWell/GestureDetector
                GestureDetector(
                  onTap: () {}, // Catch taps to prevent dialog trigger
                  child: _buildIncrementCounter(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleIcon() {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: teamColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: teamColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: teamColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: role.image != null && role.image!.isNotEmpty
          ? Image.asset(
              role.image!,
              color: role.imageColor,
              fit: BoxFit.contain,
            )
          : Center(
              child: FaIcon(
                role.icon,
                color: teamColor,
                size: 26,
                shadows: const [Shadow(blurRadius: 10, color: Colors.black)],
              ),
            ),
    );
  }

  Widget _buildRoleInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          role.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showAbilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Dark/Spooky vibe
        child: AlertDialog(
          backgroundColor: Colors.grey[900]?.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: teamColor.withValues(alpha: 0.5)),
          ),
          title: Text(role.name, style: const TextStyle(color: Colors.white)),
          content: Text(
            role.ability,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementCounter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: canDecrement ? onDecrement : null,
            color: canDecrement ? Colors.red.shade400 : Colors.grey,
            iconSize: 28,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFFd4af37)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: canIncrement ? onIncrement : null,
            color: canIncrement ? Colors.green.shade400 : Colors.grey,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
