import 'package:flutter/material.dart';
import 'package:sudokuapp/sudoku_logic/sudoku_logic.dart';

import '../widgets/widgets.dart';

class Sudoku9x9GameScreen extends StatefulWidget {
  const Sudoku9x9GameScreen({super.key, required this.difficulty});

  final DifficultyLevel difficulty;

  @override
  State<Sudoku9x9GameScreen> createState() => _Sudoku9x9GameScreenState();
}

class _Sudoku9x9GameScreenState extends State<Sudoku9x9GameScreen> {
  int? _selectedRow;
  int? _selectedCol;

  String get _difficultyLabel => switch (widget.difficulty) {
        DifficultyLevel.easy => 'Лёгкий',
        DifficultyLevel.medium => 'Средний',
        DifficultyLevel.hard => 'Тяжёлый',
        DifficultyLevel.master => 'Мастер',
        DifficultyLevel.sixteen => '16 × 16',
      };

  void _onCellTap(int row, int col) {
    setState(() {
      if (_selectedRow == row && _selectedCol == col) {
        _selectedRow = null;
        _selectedCol = null;
      } else {
        _selectedRow = row;
        _selectedCol = col;
      }
    });
  }

  void _deselect() {
    if (_selectedRow != null || _selectedCol != null) {
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 36,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: _deselect,
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Уровень',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    _difficultyLabel,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Center(
              child: SudokuMap(
                selectedRow: _selectedRow,
                selectedCol: _selectedCol,
                onCellTap: _onCellTap,
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            const GameActionButtons(),
            SizedBox(height: screenHeight * 0.04),
            const NumberInputRow(),
          ],
        ),
      ),
    );
  }
}
