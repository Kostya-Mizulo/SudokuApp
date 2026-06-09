import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'database/app_database.dart';
import 'repositories/puzzle_storage_service.dart';
import 'repositories/sudoku_repository.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final db = AppDatabase();
  await PuzzleStorageService.initialize(db);
  runApp(
    RepositoryProvider(
      create: (_) => SudokuRepository(db),
      child: const MyApp(),
    ),
  );
}