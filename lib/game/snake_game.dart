import 'dart:async' show Timer;

import 'package:alex_snake_flutter/game/enums.dart';
import 'package:alex_snake_flutter/game/food.dart';
import 'package:alex_snake_flutter/game/grid.dart';
import 'package:alex_snake_flutter/game/snake.dart';
import 'package:flutter/material.dart';

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
  Direction? nextDirection;
  @override
  void initState() {
    super.initState();
    // Dostosowanie wymiarów do proporcji 16:9
    grid = Grid(rows: 32, cols: 18, tileSize: 20);
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
      if (nextDirection != null && nextDirection != snake.direction) {
        snake.changeDirection(nextDirection!);
        nextDirection = null;
      }
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

  void _handleSwipe(Direction direction) {
    if (!isGameOver) {
      if (direction == Direction.up && snake.direction != Direction.down) {
        nextDirection = Direction.up;
      } else if (direction == Direction.down &&
          snake.direction != Direction.up) {
        nextDirection = Direction.down;
      } else if (direction == Direction.left &&
          snake.direction != Direction.right) {
        nextDirection = Direction.left;
      } else if (direction == Direction.right &&
          snake.direction != Direction.left) {
        nextDirection = Direction.right;
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final gameWidth = grid.cols * grid.tileSize.toDouble();
    final gameHeight = grid.rows * grid.tileSize.toDouble();

    return GestureDetector(
      onTap: () {
        if (isGameOver) {
          _startGame();
        }
      },
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0) {
          _handleSwipe(Direction.up);
        } else {
          _handleSwipe(Direction.down);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < 0) {
          _handleSwipe(Direction.left);
        } else {
          _handleSwipe(Direction.right);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB3E5FC),
                Color(0xFF81D4FA),
              ],
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: gameWidth,
                  height: gameHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border.all(color: Colors.black, width: 2.0),
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
                top: 40,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isGameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: const Text(
                      'Game Over\nTap to restart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
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
  
    // Dodajemy rysowanie grubej ramki
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;  // Grubsza ramka
    
    // Rysujemy ramkę
    canvas.drawRect(
      Rect.fromLTWH(
        0, 
        0, 
        grid.cols * grid.tileSize.toDouble(),
        grid.rows * grid.tileSize.toDouble()
      ),
      borderPaint,
    );

    snake.draw(canvas, snakePaint);
    food.draw(canvas, foodPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
