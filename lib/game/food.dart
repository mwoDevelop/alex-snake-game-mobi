import 'dart:math';
import 'dart:ui';

import 'package:alex_snake_flutter/game/grid.dart';

class Food {
  Point<int> _position;
  final Grid grid;

  Food({required this.grid}) : _position = _generateRandomPosition(grid);

  Point<int> get position => _position;

  void generateNewFood() {
    _position = _generateRandomPosition(grid);
  }

  static Point<int> _generateRandomPosition(Grid grid) {
    final random = Random();
    return Point(random.nextInt(grid.cols), random.nextInt(grid.rows));
  }

  void draw(Canvas canvas, Paint paint) {
    canvas.drawRect(
      Rect.fromLTWH(
        _position.x * grid.tileSize.toDouble(),
        _position.y * grid.tileSize.toDouble(),
        grid.tileSize.toDouble(),
        grid.tileSize.toDouble(),
      ),
      paint,
    );
  }
}
