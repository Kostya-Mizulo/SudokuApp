/// Уровень сложности судоку и диапазон пустых клеток, который ему соответствует.
///
/// Порт `sudoku_grid/DifficultyLevel.java`.
enum DifficultyLevel {
  easy(30, 40),
  medium(40, 50),
  hard(50, 55),
  master(55, 64),
  sixteen(145, 157);

  const DifficultyLevel(this.minEmptyCells, this.maxEmptyCells);

  final int minEmptyCells;
  final int maxEmptyCells;
}
