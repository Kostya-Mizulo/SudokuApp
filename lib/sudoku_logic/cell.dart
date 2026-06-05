/// Одна ячейка судоку.
///
/// Порт `sudoku_grid/Cell.java`. Геттеры/сеттеры сохранены в исходном виде,
/// чтобы порт был дословно сопоставим с Java-оригиналом.
///
/// Метод `setPredictedNumbers` в Java был перегружен (Set и int). В Dart
/// перегрузки нет, поэтому int-версия вынесена в [addPredictedNumber].
class Cell {
  Cell(this.row, this.column);

  final int row;
  final int column;

  int fieldRowIndex = 0;
  int fieldColumnIndex = 0;
  int realNumber = 0;
  int insertedNumber = 0;
  int numberByStart = 0;
  Set<int>? predictedNumbers;
  Set<int>? predictedNumbersByUser;
  bool isEmpty = false;
  bool isInsertedByStart = false;

  // UI state
  bool isSelected = false;
  bool isHighlighted = false;
  bool isInsertedNumberCurrentlyHighlighted = false;
  bool? isCorrectNumberInserted;

  void setRealNumber(int realNumber) => this.realNumber = realNumber;

  int getRealNumber() => realNumber;

  void setInsertedNumber(int insertedNumber) {
    this.insertedNumber = insertedNumber;
    isEmpty = insertedNumber != 0;
  }

  int getInsertedNumber() => insertedNumber;

  void setPredictedNumbers(Set<int> predictedNumbers) =>
      this.predictedNumbers = predictedNumbers;

  /// Соответствует Java-перегрузке `setPredictedNumbers(int number)`:
  /// лениво создаёт множество и добавляет в него число.
  void addPredictedNumber(int number) {
    predictedNumbers ??= <int>{};
    predictedNumbers!.add(number);
  }

  void clearPredictedNumbers() => predictedNumbers!.clear();

  bool removePredictedNumber(int number) => predictedNumbers!.remove(number);

  Set<int>? getPredictedNumbers() => predictedNumbers;

  /// Устанавливает стартовое число ячейки и синхронизирует [insertedNumber]
  /// с тем же значением (пустая ячейка = 0).
  void setNumberByStart(int numberByStart) {
    this.numberByStart = numberByStart;
    setInsertedNumber(numberByStart);
    isInsertedByStart = numberByStart != 0;
  }

  int getNumberByStart() => numberByStart;

  void insertNumberByUser(int number) {
    if (insertedNumber != 0) return;
    isCorrectNumberInserted = number == realNumber;
    insertedNumber = number;
    isEmpty = true;
  }

  void clearHighlight() {
    isSelected = false;
    isHighlighted = false;
    isInsertedNumberCurrentlyHighlighted = false;
  }

  Cell copySnapshot() {
    final copy = Cell(row, column);
    copy.insertedNumber = insertedNumber;
    copy.isInsertedByStart = isInsertedByStart;
    copy.isSelected = isSelected;
    copy.isHighlighted = isHighlighted;
    copy.isInsertedNumberCurrentlyHighlighted = isInsertedNumberCurrentlyHighlighted;
    copy.isCorrectNumberInserted = isCorrectNumberInserted;
    return copy;
  }
}
