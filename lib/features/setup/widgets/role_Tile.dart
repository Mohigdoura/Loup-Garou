import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loup_garou/models/game_character.dart';

class RoleTile extends StatelessWidget {
  final GameCharacter role;
  final int count;
  final bool isSelected;
  final bool canIncrement;
  final bool canDecrement;
  final Color teamColor;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const RoleTile({
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSelected
              ? [
                  teamColor.withValues(alpha: 0.15),
                  teamColor.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? teamColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Team icon
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: teamColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: teamColor.withValues(alpha: 0.5)),
              ),
              child: role.image != null && role.image!.isNotEmpty
                  ? Image.asset(
                      role.image!,
                      color: role.imageColor,
                      fit: BoxFit.contain,
                    )
                  : Center(
                      child: FaIcon(role.icon, color: teamColor, size: 24),
                    ),
            ),

            const SizedBox(width: 16),

            // Role info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          role.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.ability,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            _buildIncrementCounter(),
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
