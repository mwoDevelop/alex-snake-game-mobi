import 'dart:async' show Timer;
import 'dart:math';

import 'package:alex_snake_flutter/game/enums.dart';
import 'package:alex_snake_flutter/game/food.dart';
import 'package:alex_snake_flutter/game/grid.dart';
import 'package:alex_snake_flutter/game/snake.dart';
import 'package:flutter/material.dart';
import 'package:alex_snake_flutter/game/snake_bot.dart'; // Import SnakeBot

const int initialFoodCount = 100;

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  late Timer timer;
  late Snake snake; // Snake controlled by bot
  late Snake userSnake; // Snake controlled by user
  late Food food;
  late Grid grid;
  bool isGameOver = false;
  int score = 0;
  Direction? nextDirection;
  late SnakeBot snakeBot; // Dodanie instancji SnakeBot
  Direction? userNextDirection;
  int foodCount = initialFoodCount; // Zmiana na użycie stałej
  List<int> highScores = []; // Lista wyników

  @override
  void initState() {
    super.initState();
    // Dostosowanie wymiarów do proporcji 16:9
    grid = Grid(rows: 32, cols: 18, tileSize: 20);
    snake = Snake(grid: grid);
    userSnake = Snake(grid: grid, initialPosition: Point(grid.cols - 2, grid.rows - 2));
    food = Food(grid: grid);
    snakeBot = SnakeBot(); // Inicjalizacja SnakeBot
    _startGame();
  }
  void _startGame() {
    isGameOver = false;
    score = 0;
    foodCount = initialFoodCount; // Zmiana na użycie stałej
    snake = Snake(grid: grid);
    userSnake = Snake(grid: grid, initialPosition: Point(grid.cols - 2, grid.rows - 2));
    food = Food(grid: grid);
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _gameLoop();
    });
  }

  void _gameLoop() {
    if (isGameOver) return;

    setState(() {
      // Logika bota
      Direction botDirection = snakeBot.getNextDirection(
        snake.body.first,
        food.position,
        snake.body,
      );
      
      // Sprawdź czy kierunek bota jest dozwolony (nie może zawrócić)
      bool isValidDirection = true;
      if ((botDirection == Direction.up && snake.direction == Direction.down) ||
          (botDirection == Direction.down && snake.direction == Direction.up) ||
          (botDirection == Direction.left && snake.direction == Direction.right) ||
          (botDirection == Direction.right && snake.direction == Direction.left)) {
        isValidDirection = false;
      }

      if (isValidDirection) {
        nextDirection = botDirection;
      }

      if (nextDirection != null && nextDirection != snake.direction) {
        snake.changeDirection(nextDirection!);
        nextDirection = null;
      }
      snake.move();

      if (userNextDirection != null && userNextDirection != userSnake.direction) {
        userSnake.changeDirection(userNextDirection!);
        userNextDirection = null;
      }
      userSnake.move();

      if (userSnake.checkCollision(snake.body)) {
        _gameOver();
        return;
      }
      if (snake.checkCollision(userSnake.body)) {
        if (snake.body.length >= 2) {
          foodCount++;
        }
        snake = Snake(grid: grid, initialPosition: Point(grid.cols ~/ 2, grid.rows ~/ 2));
      }

      if (userSnake.body.first == food.position) {
        userSnake.grow();
        food.generateNewFood();
        foodCount--;
        score++;
      }
      if (snake.body.first == food.position) {
        snake.grow();
        food.generateNewFood();
        foodCount--;      }
      
      if (foodCount <= 0) {
        _gameOver(); // Koniec gry, gdy foodCount <= 0
      }
    });
  }

  void _gameOver() {
    timer.cancel();
    if (userSnake.body.length >= 2) {
      foodCount++;
    }
    if (score > 0) {
      highScores.add(score);
      highScores.sort((a, b) => b.compareTo(a)); // Sortuj malejąco
      if (highScores.length > 5) {
        highScores.removeLast(); // Zachowaj tylko 5 najlepszych wyników
      }
    }
    setState(() {
      isGameOver = true;
    });
  }

  void _handleSwipe(Direction direction) {
    if (!isGameOver) {
      if (direction == Direction.up && userSnake.direction != Direction.down) {
        userNextDirection = Direction.up;
      } else if (direction == Direction.down &&
          userSnake.direction != Direction.up) {
        userNextDirection = Direction.down;
      } else if (direction == Direction.left &&
          userSnake.direction != Direction.right) {
        userNextDirection = Direction.left;
      } else if (direction == Direction.right &&
          userSnake.direction != Direction.left) {
        userNextDirection = Direction.right;
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
                    color: Colors.white.withAlpha(230),                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: CustomPaint(
                    painter: GamePainter(
                      snake: snake,
                      userSnake: userSnake,
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
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(10),                  ),
                  child: Text(
                    'Score: $score   Food: $foodCount', // Wyświetlanie foodCount
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
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(15),                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: highScores.isEmpty
                        ? const Text(
                            'Game Over\nTap to restart',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'High Scores',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              for (var highScore in highScores)
                                Text(
                                  highScore.toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                  ),
                                ),
                              const Text(
                                'Tap to restart',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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
  final Snake userSnake;
  final Food food;
  final Grid grid;
  final bool isGameOver;
  final int score;

  GamePainter({
    required this.snake,
    required this.userSnake,
    required this.food,
    required this.grid,
    required this.isGameOver,
    required this.score,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final snakePaint = Paint()..color = Colors.green;
    final userSnakePaint = Paint()..color = Colors.blue;
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
    userSnake.draw(canvas, userSnakePaint);
    food.draw(canvas, foodPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
