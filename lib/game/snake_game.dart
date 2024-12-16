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
    _animationController.reset();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _gameLoop();
        _animationController.reset();
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

      if (snake._progress == 1.0) {
        snake.move();
      }
      if (userSnake._progress == 1.0) {
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
+  void dispose() {
+    _animationController.dispose();
+    super.dispose();
+  }
   @override
   Widget build(BuildContext context) {
     final gameWidth = grid.cols * grid.tileSize.toDouble();
