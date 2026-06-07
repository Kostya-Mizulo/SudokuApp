import 'package:flutter/material.dart';

import '../../shared/screen_frame.dart';
import '../widgets/widgets.dart';

class WinScreen extends StatelessWidget {
  const WinScreen({super.key, required this.elapsedTime});

  final String elapsedTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ScreenFrame(child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Судоку\nуспешно разгадан!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Время: $elapsedTime',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.06),
              child: const HomeButton(),
            ),
          ),
        ],
      ),
    ));
  }
}
