import 'dart:ui';

import 'package:alex_snake_flutter/game/enums.dart';
import 'package:alex_snake_flutter/game/grid.dart';
import 'dart:math';

class Snake {
  final List<Point<int>> _body;
  Direction _direction;
  final Grid grid;

  Snake({required this.grid, Point<int>? initialPosition})
      : _body = [initialPosition ?? Point(grid.cols ~/ 2, grid.rows ~/ 2)],
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

  bool checkCollision(List<Point<int>> otherBody) {
    // Sprawdź kolizję z własnym ciałem
    for (int i = 0; i < otherBody.length; i++) {
      if (body.first == otherBody[i]) {
        return true;
      }
    }

    return false;
  }
  void draw(Canvas canvas, Paint paint) {
    for (int i = 0; i < _body.length; i++) {
      final segment = _body[i];
      final isHead = i == 0;
      final segmentRect = Rect.fromLTWH(
        segment.x * grid.tileSize.toDouble(),
        segment.y * grid.tileSize.toDouble(),
        grid.tileSize.toDouble(),
        grid.tileSize.toDouble(),
      );

      if (isHead) {
        // Rysowanie głowy węża
        canvas.drawRect(segmentRect, paint);

        // Rysowanie oczu
        final eyeSize = grid.tileSize / 5;
        final eyeOffset = grid.tileSize / 4;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(segmentRect.center.dx - eyeOffset, segmentRect.center.dy - eyeOffset),
            width: eyeSize,
            height: eyeSize,
          ),
          Paint()..color = Color(0xFF000000),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(segmentRect.center.dx + eyeOffset, segmentRect.center.dy - eyeOffset),
            width: eyeSize,
            height: eyeSize,
          ),
          Paint()..color = Color(0xFF000000),
        );

        // Rysowanie języka
        final tongueWidth = grid.tileSize / 4;
        final tongueHeight = grid.tileSize / 3;
        final tongueOffset = grid.tileSize / 2;
        final tonguePath = Path();
        tonguePath.moveTo(segmentRect.center.dx, segmentRect.center.dy + tongueOffset);
        tonguePath.lineTo(segmentRect.center.dx - tongueWidth / 2, segmentRect.center.dy + tongueOffset + tongueHeight);
        tonguePath.lineTo(segmentRect.center.dx + tongueWidth / 2, segmentRect.center.dy + tongueOffset + tongueHeight);
        tonguePath.close();
        canvas.drawPath(tonguePath, Paint()..color = Color(0xFFff0000));


      } else {
        // Rysowanie reszty ciała
        canvas.drawRect(segmentRect, paint);
      }
    }
  }
}
