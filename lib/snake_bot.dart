import 'dart:math';
import 'package:alex_snake_flutter/game/enums.dart';

class SnakeBot {
  Direction getNextDirection(Point snakeHead, Point food, List<Point> snakeBody) {
    // Prosta logika bota: idź w kierunku jedzenia
    if (food.x > snakeHead.x) {
      return Direction.right;
    } else if (food.x < snakeHead.x) {
      return Direction.left;
    } else if (food.y > snakeHead.y) {
      return Direction.down;
    } else if (food.y < snakeHead.y) {
      return Direction.up;
    }
    // Jeśli na tej samej pozycji, kontynuuj w obecnym kierunku
    return Direction.right;
  }
}
