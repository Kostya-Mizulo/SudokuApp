import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/bloc.dart';

class GameActionButtons extends StatelessWidget {
  const GameActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    const grey = Color(0xFF616161);

    return BlocBuilder<SudokuGameBloc, SudokuGameState>(
      buildWhen: (prev, curr) {
        if (curr is! SudokuGameLoaded) return false;
        if (prev is! SudokuGameLoaded) return true;
        return prev.isNotesActivated != curr.isNotesActivated;
      },
      builder: (context, state) {
        final notesEnabled =
            state is SudokuGameLoaded ? state.isNotesActivated : false;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.backspace_outlined,
              label: 'Очистить',
              color: grey,
              onTap: () =>
                  context.read<SudokuGameBloc>().add(SudokuGameCellCleared()),
            ),
            _ActionButton(
              icon: Icons.edit_outlined,
              label: 'Заметки',
              color: grey,
              onTap: () =>
                  context.read<SudokuGameBloc>().add(SudokuGameNotesToggled()),
              badge: _NotesBadge(enabled: notesEnabled),
            ),
            _ActionButton(
              icon: Icons.tips_and_updates_outlined,
              label: 'Подсказка',
              color: grey,
              onTap: () {},
            ),
          ],
        );
      },
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
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: enabled ? size.width * 0.013 : size.width * 0.008,
        vertical: enabled ? size.height * 0.0025 : size.height * 0.0013,
      ),
      decoration: BoxDecoration(
        color: enabled ? accentColor : greyOff,
        borderRadius: BorderRadius.circular(size.width * 0.011),
      ),
      child: Text(
        enabled ? 'ON' : 'OFF',
        style: TextStyle(
          fontSize: enabled ? size.width * 0.027 : size.width * 0.021,
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
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: size.width * 0.075),
                if (badge != null)
                  Positioned(
                    left: size.width * 0.053,
                    bottom: -size.width * 0.011,
                    child: badge!,
                  ),
              ],
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: size.width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
