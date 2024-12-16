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

class _SnakeGameState extends State<SnakeGame> with TickerProviderStateMixin {
  late AnimationController _animationController;
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // Ustawienie czasu trwania animacji
    );
    _startGame();
  }
  void _startGame() {
    isGameOver = false;
    score = 0;
    foodCount = initialFoodCount; // Zmiana na użycie stałej
    snake = Snake(grid: grid);
    userSnake = Snake(grid: grid, initialPosition: Point(grid.cols - 2, grid.rows - 2));
    food = Food(grid: grid);
    
    // Tworzymy nowy AnimationController z tą samą prędkością
    _animationController.dispose();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    );
    
    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _gameLoop();
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
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
      
      if (userNextDirection != null && userNextDirection != userSnake.direction) {
        userSnake.changeDirection(userNextDirection!);
        userNextDirection = null;
      }

      snake.updateProgress(1);
      userSnake.updateProgress(1);

      if (snake.progress == 1.0) {
        snake.move();
      }
      if (userSnake.progress == 1.0) {
        userSnake.move();
      }

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
    _animationController.forward();
  }

  void _gameOver() {
    _animationController.stop();
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
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final gameWidth = grid.cols * grid.tileSize.toDouble();
    final gameHeight = grid.rows * grid.tileSize.toDouble();

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0) {
          _handleSwipe(Direction.up);
        } else if (details.delta.dy > 0) {
          _handleSwipe(Direction.down);
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < 0) {
          _handleSwipe(Direction.left);
        } else if (details.delta.dx > 0) {
          _handleSwipe(Direction.right);
        }
      },
      child: Scaffold(
        body: SizedBox(
          width: gameWidth,
          height: gameHeight,
          child: CustomPaint(
            painter: _GamePainter(
              snake: snake,
              userSnake: userSnake,
              food: food,
              grid: grid,
              isGameOver: isGameOver,
              score: score,
              highScores: highScores,
            ),
          ),
        ),
        floatingActionButton: isGameOver
            ? FloatingActionButton(
                onPressed: _startGame,
                child: const Icon(Icons.replay),
              )
            : null,
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final Snake snake;
  final Snake userSnake;
  final Food food;
  final Grid grid;
  final bool isGameOver;
  final int score;
  final List<int> highScores;

  _GamePainter({
    required this.snake,
    required this.userSnake,
    required this.food,
    required this.grid,
    required this.isGameOver,
    required this.score,
    required this.highScores,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final snakePaint = Paint()..color = const Color(0xFF00FF00);
    final userSnakePaint = Paint()..color = const Color(0xFF0000FF);
    final foodPaint = Paint()..color = const Color(0xFFFF0000);

    snake.draw(canvas, snakePaint);
    userSnake.draw(canvas, userSnakePaint);
    food.draw(canvas, foodPaint);

    if (isGameOver) {
      _drawGameOverScreen(canvas, size);
    }
  }

  void _drawGameOverScreen(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
    );
    final gameOverTextPainter = TextPainter(
      text: TextSpan(text: 'Game Over', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    gameOverTextPainter.layout();
    final gameOverTextPosition = Offset(
      (size.width - gameOverTextPainter.width) / 2,
      (size.height - gameOverTextPainter.height) / 2 - 30,
    );
    gameOverTextPainter.paint(canvas, gameOverTextPosition);

    final scoreTextPainter = TextPainter(
      text: TextSpan(text: 'Score: $score', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    scoreTextPainter.layout();
    final scoreTextPosition = Offset(
      (size.width - scoreTextPainter.width) / 2,
      (size.height - scoreTextPainter.height) / 2,
    );
    scoreTextPainter.paint(canvas, scoreTextPosition);

    if (highScores.isNotEmpty) {
      final highScoresTextPainter = TextPainter(
        text: TextSpan(
          text: 'High Scores: ${highScores.join(', ')}',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      highScoresTextPainter.layout();
      final highScoresTextPosition = Offset(
        (size.width - highScoresTextPainter.width) / 2,
        (size.height - highScoresTextPainter.height) / 2 + 30,
      );
      highScoresTextPainter.paint(canvas, highScoresTextPosition);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
