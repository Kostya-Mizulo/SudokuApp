import 'package:flutter/material.dart';

import '../../../repositories/active_session_repository.dart';
import '../../../sudoku_logic/sudoku_logic.dart';
import '../../shared/screen_frame.dart';
import '../../sudoku_9x9_game/view/view.dart';
import '../../sudoku_16x16_game/view/view.dart';
import '../widgets/widgets.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key, required this.title});

  final String title;

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  static const _repository = ActiveSessionRepository();

  bool _hasActiveSession = false;

  @override
  void initState() {
    super.initState();
    _refreshSessionState();
  }

  Future<void> _refreshSessionState() async {
    final has = await _repository.hasSession();
    if (mounted) setState(() => _hasActiveSession = has);
  }

  Future<void> _onNewGamePressed() async {
    final difficulty = await DifficultyPopup.show(context);
    if (difficulty == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => difficulty == DifficultyLevel.sixteen
            ? Sudoku16x16GameScreen(difficulty: difficulty)
            : Sudoku9x9GameScreen(difficulty: difficulty),
      ),
    );
    if (mounted) _refreshSessionState();
  }

  Future<void> _onContinuePressed() async {
    final difficulty = await _repository.getSessionDifficulty();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => difficulty == DifficultyLevel.sixteen
            ? const Sudoku16x16GameScreen.resume()
            : const Sudoku9x9GameScreen.resume(),
      ),
    );
    if (mounted) _refreshSessionState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ScreenFrame(child: Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //   surfaceTintColor: Colors.transparent,
      //   shadowColor: Colors.transparent,
      //   elevation: 0,
      //   scrolledUnderElevation: 0,
      //   title: Text(
      //     'Главная',
      //     style: TextStyle(color: Theme.of(context).colorScheme.primary),
      //   ),
      //   centerTitle: true,
      // ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const SizedBox.expand(),
          Align(
            alignment: const Alignment(0, -0.4),
            child: Image.asset(
              'lib/resources/images/logo_iphone.png',
              width: size.width * 0.55,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.06),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasActiveSession) ...[
                  ContinueGameButton(onPressed: _onContinuePressed),
                  SizedBox(height: size.height * 0.02),
                ],
                NewGameButton(onPressed: _onNewGamePressed),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
