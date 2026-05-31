/// Размер судоку: классический 9x9 или 16x16.
///
/// Порт `sudoku_grid/SudokuSize.java`.
enum SudokuSize {
  nine(9),
  sixteen(16);

  const SudokuSize(this.size);

  final int size;
}
