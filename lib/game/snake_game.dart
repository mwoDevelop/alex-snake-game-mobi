import 'dart:async';

import 'package:alex_snake_flutter/game/enums.dart';
import 'package:alex_snake_flutter/game/food.dart';
import 'package:alex_snake_flutter/game/grid.dart';
import 'package:alex_snake_flutter/game/snake.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  late Timer timer;
  late Snake snake;
  late Food food;
  late Grid grid;
  bool isGameOver = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    grid = Grid(rows: 45, cols: 30, tileSize: 15);
    snake = Snake(grid: grid);
    food = Food(grid: grid);
    _startGame();
  }

  void _startGame() {
    isGameOver = false;
    score = 0;
    snake = Snake(grid: grid);
    food = Food(grid: grid);
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _gameLoop();
    });
  }

  void _gameLoop() {
    if (isGameOver) return;

    setState(() {
      snake.move();
      if (snake.checkCollision()) {
        _gameOver();
        return;
      }

      if (snake.body.first == food.position) {
        snake.grow();
        food.generateNewFood();
        score++;
      }
    });
  }

  void _gameOver() {
    timer.cancel();
    setState(() {
      isGameOver = true;
    });
  }

  void _handleInput(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      setState(() {
        if (key == LogicalKeyboardKey.arrowUp) {
          snake.changeDirection(Direction.up);
        } else if (key == LogicalKeyboardKey.arrowDown) {
          snake.changeDirection(Direction.down);
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          snake.changeDirection(Direction.left);
        } else if (key == LogicalKeyboardKey.arrowRight) {
          snake.changeDirection(Direction.right);
        }
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleInput,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: CustomPaint(
                  painter: GamePainter(
                    snake: snake,
                    food: food,
                    grid: grid,
                    isGameOver: isGameOver,
                    score: score,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isGameOver)
              Center(
                child: Text(
                  'Game Over\nTap to restart',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final Snake snake;
  final Food food;
  final Grid grid;
  final bool isGameOver;
  final int score;

  GamePainter({
    required this.snake,
    required this.food,
    required this.grid,
    required this.isGameOver,
    required this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final snakePaint = Paint()..color = Colors.green;
    final foodPaint = Paint()..color = Colors.red;

    snake.draw(canvas, snakePaint);
    food.draw(canvas, foodPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
