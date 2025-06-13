import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Added missing import
import 'tetris_board.dart';
import 'game_state.dart';
import 'tetris_game.dart';
import 'painter.dart';
import 'tetromino.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF6B35),
          surface: Color(0xFF1A1A1A),
          background: Color(0xFF0A0A0A),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const TetrisGameScreen(),
    );
  }
}

class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends State<TetrisGameScreen>
    with TickerProviderStateMixin {
  late final TetrisBoard board;
  late final GameState state;
  late final TetrisGame game;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final int rows = 20;
  final int cols = 10;

  @override
  void initState() {
    super.initState();
    board = TetrisBoard(rows: rows, cols: cols);
    state = GameState(board);
    game = TetrisGame(state);
    game.start();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Start a timer to refresh the UI regularly
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    game.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void handleKeyDown(LogicalKeyboardKey key) {
    if (!mounted) return;
    
    switch (key) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        game.move(MoveDirection.left);
        break;
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        game.move(MoveDirection.right);
        break;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        game.startFastDrop(); // Start fast dropping
        break;
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
      case LogicalKeyboardKey.keyX:
        game.rotate();
        break;
      case LogicalKeyboardKey.space:
        game.hardDrop();
        break;
      case LogicalKeyboardKey.keyP:
        game.togglePause();
        break;
      case LogicalKeyboardKey.keyR:
        game.restart();
        break;
    }
  }

  void handleKeyUp(LogicalKeyboardKey key) {
    if (!mounted) return;
    
    // Stop fast dropping when down arrow is released
    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
      game.stopFastDrop();
    }
  }

  void handleInput(String key) {
    if (!mounted) return;
    setState(() {
      switch (key) {
        case 'ArrowLeft':
        case 'a':
          game.move(MoveDirection.left);
          break;
        case 'ArrowRight':
        case 'd':
          game.move(MoveDirection.right);
          break;
        case 'ArrowDown':
        case 's':
          game.move(MoveDirection.down);
          break;
        case 'ArrowUp':
        case 'w':
        case 'x':
          game.rotate();
          break;
        case ' ':
          game.hardDrop();
          break;
        case 'p':
          game.togglePause();
          break;
        case 'r':
          game.restart();
          break;
      }
    });
  }

  Widget _buildGameBoard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CustomPaint(
          painter: TetrisPainter(
            board: board,
            current: state.currentTetromino,
            rows: rows,
            cols: cols,
          ),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildNextPiece() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NEXT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: NextPiecePainter(nextTetromino: state.nextTetromino),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildStatRow('SCORE', state.score.toString()),
          const SizedBox(height: 12),
          _buildStatRow('LEVEL', state.level.toString()),
          const SizedBox(height: 12),
          _buildStatRow('LINES', state.linesCleared.toString()),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.8),
              (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.6),
            ],
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          iconSize: 24,
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Movement controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.keyboard_arrow_left,
                onPressed: () => handleInput('ArrowLeft'),
                tooltip: 'Move Left (A)',
              ),
              _buildControlButton(
                icon: Icons.rotate_right,
                onPressed: () => handleInput('ArrowUp'),
                tooltip: 'Rotate (W/↑)',
              ),
              _buildControlButton(
                icon: Icons.keyboard_arrow_right,
                onPressed: () => handleInput('ArrowRight'),
                tooltip: 'Move Right (D)',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.keyboard_arrow_down,
                onPressed: () => handleInput('ArrowDown'),
                tooltip: 'Fast Drop (S/↓)',
              ),
              _buildControlButton(
                icon: Icons.vertical_align_bottom,
                onPressed: () => handleInput(' '),
                tooltip: 'Hard Drop (Space)',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Game controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => setState(() => game.togglePause()),
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(state.isPaused ? 'Resume' : 'Pause'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.isPaused 
                    ? Colors.green.withOpacity(0.8)
                    : Colors.orange.withOpacity(0.8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => setState(() => game.restart()),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Restart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Final Score: ${state.score}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level: ${state.level}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => game.restart()),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          handleKeyDown(event.logicalKey);
        } else if (event is KeyUpEvent) {
          handleKeyUp(event.logicalKey);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'TETRIS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    // Desktop layout
                    return Row(
                      children: [
                        // Left panel
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildNextPiece(),
                              const SizedBox(height: 16),
                              _buildGameStats(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Game board
                        Expanded(
                          flex: 4,
                          child: AspectRatio(
                            aspectRatio: cols / rows,
                            child: _buildGameBoard(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right panel
                        Expanded(
                          flex: 2,
                          child: _buildGameControls(),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout
                    return Column(
                      children: [
                        // Top info row
                        Row(
                          children: [
                            Expanded(child: _buildGameStats()),
                            const SizedBox(width: 16),
                            _buildNextPiece(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Game board
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: cols / rows,
                            child: _buildGameBoard(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Controls
                        _buildGameControls(),
                      ],
                    );
                  }
                },
              ),
            ),
            // Game over overlay
            if (state.isGameOver) _buildGameOverOverlay(),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the next piece preview
class NextPiecePainter extends CustomPainter {
  final Tetromino nextTetromino;

  NextPiecePainter({required this.nextTetromino});

  @override
  void paint(Canvas canvas, Size size) {
    final shape = nextTetromino.shape;
    final blockSize = size.width / 4;
    final paint = Paint()..color = nextTetromino.color;

    // Center the piece
    final shapeWidth = shape[0].length * blockSize;
    final shapeHeight = shape.length * blockSize;
    final offsetX = (size.width - shapeWidth) / 2;
    final offsetY = (size.height - shapeHeight) / 2;

    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                offsetX + j * blockSize,
                offsetY + i * blockSize,
                blockSize - 1,
                blockSize - 1,
              ),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant NextPiecePainter oldDelegate) {
    return nextTetromino != oldDelegate.nextTetromino;
  }
}