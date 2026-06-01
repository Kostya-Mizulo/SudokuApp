import 'package:flutter/material.dart';

class GameActionButtons extends StatefulWidget {
  const GameActionButtons({super.key});

  @override
  State<GameActionButtons> createState() => _GameActionButtonsState();
}

class _GameActionButtonsState extends State<GameActionButtons> {
  bool _notesEnabled = false;

  @override
  Widget build(BuildContext context) {
    const grey = Color(0xFF616161);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.backspace_outlined,
          label: 'Очистить',
          color: grey,
          onTap: () {},
        ),
        _ActionButton(
          icon: Icons.edit_outlined,
          label: 'Заметки',
          color: grey,
          onTap: () => setState(() => _notesEnabled = !_notesEnabled),
          badge: _NotesBadge(enabled: _notesEnabled),
        ),
        _ActionButton(
          icon: Icons.tips_and_updates_outlined,
          label: 'Подсказка',
          color: grey,
          onTap: () {},
        ),
      ],
    );
  }
}

class _NotesBadge extends StatelessWidget {
  const _NotesBadge({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const greyOff = Color(0xFFBDBDBD);
    final accentColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: enabled ? 5 : 3,
        vertical: enabled ? 2 : 1,
      ),
      decoration: BoxDecoration(
        color: enabled ? accentColor : greyOff,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        enabled ? 'ON' : 'OFF',
        style: TextStyle(
          fontSize: enabled ? 10 : 8,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 28),
              if (badge != null)
                Positioned(
                  left: 20,
                  bottom: -4,
                  child: badge!,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
