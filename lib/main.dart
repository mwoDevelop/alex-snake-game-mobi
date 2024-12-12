import 'package:alex_snake_flutter/game/snake_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AlexSnakeGameMobi());
}

class AlexSnakeGameMobi extends StatelessWidget {
  const AlexSnakeGameMobi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SnakeGame(),
    );
  }
}
