import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'repositories/puzzle_storage_service.dart';
import 'screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await PuzzleStorageService.initialize();
  runApp(const MyApp());
}