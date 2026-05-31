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

  void setRealNumber(int realNumber) => this.realNumber = realNumber;

  int getRealNumber() => realNumber;

  void setInsertedNumber(int insertedNumber) => this.insertedNumber = insertedNumber;

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

  void setNumberByStart(int numberByStart) {
    this.numberByStart = numberByStart;
    insertedNumber = numberByStart;
  }

  int getNumberByStart() => numberByStart;
}
