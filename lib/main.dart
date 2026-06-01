import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'screens/screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Полноэкранный режим: прячем системные кнопки (назад/дом/последние).
  // По свайпу снизу они показываются полупрозрачным оверлеем и сами
  // скрываются через несколько секунд (immersiveSticky).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}
