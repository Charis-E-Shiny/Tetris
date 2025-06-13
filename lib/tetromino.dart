import 'package:flutter/material.dart';

enum TetrominoType { I, J, L, O, S, T, Z }

/// Shape definitions using 4x4 matrices (each shape in its default rotation)
final Map<TetrominoType, List<List<List<int>>>> tetrominoShapes = {
  TetrominoType.I: [
    [
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]
  ],
  TetrominoType.J: [
    [
      [1, 0, 0],
      [1, 1, 1],
      [0, 0, 0],
    ]
  ],
  TetrominoType.L: [
    [
      [0, 0, 1],
      [1, 1, 1],
      [0, 0, 0],
    ]
  ],
  TetrominoType.O: [
    [
      [1, 1],
      [1, 1],
    ]
  ],
  TetrominoType.S: [
    [
      [0, 1, 1],
      [1, 1, 0],
      [0, 0, 0],
    ]
  ],
  TetrominoType.T: [
    [
      [0, 1, 0],
      [1, 1, 1],
      [0, 0, 0],
    ]
  ],
  TetrominoType.Z: [
    [
      [1, 1, 0],
      [0, 1, 1],
      [0, 0, 0],
    ]
  ],
};

/// Colors for each Tetromino
final Map<TetrominoType, Color> tetrominoColors = {
  TetrominoType.I: Colors.cyan,
  TetrominoType.J: Colors.blue,
  TetrominoType.L: Colors.orange,
  TetrominoType.O: Colors.yellow,
  TetrominoType.S: Colors.green,
  TetrominoType.T: Colors.purple,
  TetrominoType.Z: Colors.red,
};

/// Class representing an active falling Tetromino
class Tetromino {
  TetrominoType type;
  List<List<int>> shape;
  int row;
  int col;

  Tetromino(this.type, {this.row = 0, this.col = 3})
      : shape = tetrominoShapes[type]![0].map((r) => List<int>.from(r)).toList();

  Color get color => tetrominoColors[type]!;

  /// Rotate clockwise
  void rotate() {
    final n = shape.length;
    final rotated = List.generate(n, (i) => List.generate(n, (j) => 0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        rotated[j][n - 1 - i] = shape[i][j];
      }
    }
    shape = rotated;
  }

  /// Rotate counter-clockwise
  void rotateCCW() {
    final n = shape.length;
    final rotated = List.generate(n, (i) => List.generate(n, (j) => 0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        rotated[n - 1 - j][i] = shape[i][j];
      }
    }
    shape = rotated;
  }
}