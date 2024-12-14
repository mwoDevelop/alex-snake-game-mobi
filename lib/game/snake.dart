import 'dart:ui';

import 'package:alex_snake_flutter/game/enums.dart';
import 'package:alex_snake_flutter/game/grid.dart';
import 'dart:math';

class Snake {
  final List<Point<int>> _body;
  Direction _direction;
  final Grid grid;

  Snake({required this.grid})
      : _body = [Point(grid.cols ~/ 2, grid.rows ~/ 2)],
        _direction = Direction.down;

  List<Point<int>> get body => _body;
  Direction get direction => _direction;

  void move() {
    final head = _body.first;
    Point<int> newHead;

    switch (_direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    // Obsługa przechodzenia przez ściany
    if (newHead.x < 0) {
      newHead = Point(grid.cols - 1, newHead.y);
    } else if (newHead.x >= grid.cols) {
      newHead = Point(0, newHead.y);
    } else if (newHead.y < 0) {
      newHead = Point(newHead.x, grid.rows - 1);
    } else if (newHead.y >= grid.rows) {
      newHead = Point(newHead.x, 0);
    }

    _body.insert(0, newHead);
    _body.removeLast();
  }

  void grow() {
    final head = _body.first;
    Point<int> newHead;

    switch (_direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    _body.insert(0, newHead);
  }

  void changeDirection(Direction newDirection) {
    if (_direction == Direction.up && newDirection == Direction.down) return;
    if (_direction == Direction.down && newDirection == Direction.up) return;
    if (_direction == Direction.left && newDirection == Direction.right) return;
    if (_direction == Direction.right && newDirection == Direction.left) return;

    _direction = newDirection;
  }

  bool checkCollision() {
    // Sprawdź kolizję z własnym ciałem
    for (int i = 1; i < body.length; i++) {
      if (body.first == body[i]) {
        return true;
      }
    }

    return false;
  }
  void draw(Canvas canvas, Paint paint) {
    // Rysowanie ciała węża
    for (final segment in _body) {
      canvas.drawRect(
        Rect.fromLTWH(
          segment.x * grid.tileSize.toDouble(),
          segment.y * grid.tileSize.toDouble(),
          grid.tileSize.toDouble(),
          grid.tileSize.toDouble(),
        ),
        paint,
      );
    }
  }
}
