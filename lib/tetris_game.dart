import 'dart:async';
import 'game_state.dart';

enum MoveDirection { left, right, down }

class TetrisGame {
  final GameState state;
  Timer? _gameLoop;
  Timer? _fastDropTimer;
  
  // Normal fall speed based on level
  Duration get normalTickRate => Duration(milliseconds: (1000 - (state.level - 1) * 50).clamp(100, 1000));
  
  // Fast drop speed when down arrow is held
  static const Duration fastDropRate = Duration(milliseconds: 50);
  
  bool _isFastDropping = false;

  TetrisGame(this.state);

  void start() {
    _startGameLoop();
  }

  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(normalTickRate, (_) => _tick());
  }

  void _tick() {
    if (state.isPaused || state.isGameOver) return;

    // Try to move down; if not possible, lock and spawn next
    final tetro = state.currentTetromino;
    if (state.board.isValidPosition(tetro, offsetRow: 1)) {
      tetro.row++;
    } else {
      state.lockAndContinue();
      // Restart game loop with new level speed
      _startGameLoop();
    }
  }

  void move(MoveDirection direction) {
    if (state.isPaused || state.isGameOver) return;

    final tetro = state.currentTetromino;
    
    switch (direction) {
      case MoveDirection.left:
        if (state.board.isValidPosition(tetro, offsetCol: -1)) {
          tetro.col--;
        }
        break;
        
      case MoveDirection.right:
        if (state.board.isValidPosition(tetro, offsetCol: 1)) {
          tetro.col++;
        }
        break;
        
      case MoveDirection.down:
        // Just move down one step, don't lock immediately
        if (state.board.isValidPosition(tetro, offsetRow: 1)) {
          tetro.row++;
        } else {
          state.lockAndContinue();
          _startGameLoop();
        }
        break;
    }
  }

  void startFastDrop() {
    if (state.isPaused || state.isGameOver || _isFastDropping) return;
    
    _isFastDropping = true;
    _fastDropTimer = Timer.periodic(fastDropRate, (_) {
      if (state.isPaused || state.isGameOver) {
        stopFastDrop();
        return;
      }
      
      final tetro = state.currentTetromino;
      if (state.board.isValidPosition(tetro, offsetRow: 1)) {
        tetro.row++;
      } else {
        state.lockAndContinue();
        _startGameLoop();
        stopFastDrop();
      }
    });
  }

  void stopFastDrop() {
    _isFastDropping = false;
    _fastDropTimer?.cancel();
    _fastDropTimer = null;
  }

  void rotate() {
    if (state.isPaused || state.isGameOver) return;

    final tetro = state.currentTetromino;
    tetro.rotate();
    if (!state.board.isValidPosition(tetro)) {
      tetro.rotateCCW(); // Revert if invalid
    }
  }

  void hardDrop() {
    if (state.isPaused || state.isGameOver) return;

    final tetro = state.currentTetromino;
    int dropDistance = 0;
    
    while (state.board.isValidPosition(tetro, offsetRow: 1)) {
      tetro.row++;
      dropDistance++;
    }
    
    // Add bonus points for hard drop
    state.score += dropDistance * 2;
    state.lockAndContinue();
    _startGameLoop();
  }

  void pause() {
    state.isPaused = true;
    stopFastDrop();
  }

  void resume() {
    state.isPaused = false;
  }

  void togglePause() {
    if (state.isPaused) {
      resume();
    } else {
      pause();
    }
  }

  void restart() {
    stopFastDrop();
    state.reset();
    _startGameLoop();
  }

  void dispose() {
    _gameLoop?.cancel();
    _fastDropTimer?.cancel();
  }
}