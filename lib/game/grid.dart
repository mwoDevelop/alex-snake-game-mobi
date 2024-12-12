import 'package:flutter/material.dart';

class Grid {
  final int rows;
  final int cols;
  final double tileSize;

  Grid({required this.rows, required this.cols, required this.tileSize});

  Offset gridToScreen(int row, int col) {
    return Offset(col * tileSize, row * tileSize);
  }

  (int, int) screenToGrid(Offset position) {
    return (
      (position.dy / tileSize).floor(),
      (position.dx / tileSize).floor(),
    );
  }
}
