import 'dart:math';
import 'tetromino.dart';
import 'tetris_board.dart';

// CORRECTED function - uses TetrominoType enum values
Tetromino getRandomTetromino() {
  final random = Random();
  final tetrominoTypes = TetrominoType.values; // Gets all enum values: [I, J, L, O, S, T, Z]
  final randomType = tetrominoTypes[random.nextInt(tetrominoTypes.length)];
  return Tetromino(randomType); // Uses the correct constructor
}

class GameState {
  final TetrisBoard board;
  Tetromino currentTetromino;
  Tetromino nextTetromino;

  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool isGameOver = false;
  bool isPaused = false;

  GameState(this.board)
      : currentTetromino = getRandomTetromino(),
        nextTetromino = getRandomTetromino() {
    currentTetromino.row = -1;
    currentTetromino.col = board.cols ~/ 2 - 2;
  }

  /// Swap next into current and generate a new next
  void spawnNext() {
    currentTetromino = nextTetromino;
    currentTetromino.row = -1;
    currentTetromino.col = board.cols ~/ 2 - 2;
    nextTetromino = getRandomTetromino();

    if (!board.isValidPosition(currentTetromino)) {
      isGameOver = true;
    }
  }

  /// Lock and clear, then spawn next
  void lockAndContinue() {
    board.lockTetromino(currentTetromino);
    int cleared = board.clearFullRows();
    linesCleared += cleared;
    score += cleared * 100 * level; // Score increases with level
    
    // Level up every 10 lines
    level = (linesCleared ~/ 10) + 1;
    
    spawnNext();
  }

  void reset() {
    score = 0;
    level = 1;
    linesCleared = 0;
    isGameOver = false;
    isPaused = false;
    board.resetBoard();
    currentTetromino = getRandomTetromino();
    currentTetromino.row = -1;
    currentTetromino.col = board.cols ~/ 2 - 2;
    nextTetromino = getRandomTetromino();
  }
}