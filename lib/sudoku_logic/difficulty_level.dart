/// Уровень сложности судоку и диапазон пустых клеток, который ему соответствует.
///
/// Порт `sudoku_grid/DifficultyLevel.java`.
enum DifficultyLevel {
  easy(36, 40),
  medium(40, 46),
  hard(50, 52),
  master(52, 61),
  sixteen(132, 144);

  const DifficultyLevel(this.minEmptyCells, this.maxEmptyCells);

  final int minEmptyCells;
  final int maxEmptyCells;
}