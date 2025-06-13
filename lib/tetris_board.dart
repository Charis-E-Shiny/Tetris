import 'package:flutter/material.dart';
import 'tetromino.dart';

class TetrisBoard {
  final int rows;
  final int cols;
  late List<List<Color?>> grid;

  TetrisBoard({this.rows = 20, this.cols = 10}) {
    resetBoard();
  }

  void resetBoard() {
    grid = List.generate(rows, (_) => List.generate(cols, (_) => null));
  }

  /// Checks if tetromino can be placed at its current position
  bool isValidPosition(Tetromino tetromino, {int offsetRow = 0, int offsetCol = 0}) {
    final shape = tetromino.shape;
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 0) continue;
        final newRow = tetromino.row + i + offsetRow;
        final newCol = tetromino.col + j + offsetCol;

        // Allow pieces to start above the board (negative row)
        if (newRow >= rows || newCol < 0 || newCol >= cols) return false;
        
        // Only check collision with existing blocks if piece is within board bounds
        if (newRow >= 0 && grid[newRow][newCol] != null) return false;
      }
    }
    return true;
  }

  /// Locks the tetromino into the grid (makes its blocks permanent)
  void lockTetromino(Tetromino tetromino) {
    final shape = tetromino.shape;
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 0) continue;
        final r = tetromino.row + i;
        final c = tetromino.col + j;
        if (r >= 0 && r < rows && c >= 0 && c < cols) {
          grid[r][c] = tetromino.color;
        }
      }
    }
  }

  /// Clears full rows and returns how many rows were cleared
  int clearFullRows() {
    int cleared = 0;

    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r].every((cell) => cell != null)) {
        grid.removeAt(r);
        grid.insert(0, List.generate(cols, (_) => null));
        cleared++;
        r++; // Re-check this row after insert
      }
    }

    return cleared;
  }

  /// Gets the grid cell color at (row, col)
  Color? getCell(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    return grid[row][col];
  }
}