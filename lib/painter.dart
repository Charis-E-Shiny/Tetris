import 'package:flutter/material.dart';
import 'tetris_board.dart';
import 'tetromino.dart';

class TetrisPainter extends CustomPainter {
  final TetrisBoard board;
  final Tetromino current;
  final int rows;
  final int cols;

  TetrisPainter({
    required this.board,
    required this.current,
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double blockWidth = size.width / cols;
    final double blockHeight = size.height / rows;
    final Paint paint = Paint();
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Draw background gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.shade900,
          Colors.black,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw locked blocks with 3D effect
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final color = board.getCell(r, c);
        if (color != null) {
          _drawBlock(canvas, c * blockWidth, r * blockHeight, blockWidth, blockHeight, color, paint, shadowPaint);
        }
      }
    }

    // Draw ghost piece (preview where current piece will land)
    _drawGhostPiece(canvas, blockWidth, blockHeight, paint);

    // Draw current tetromino with glow effect
    final shape = current.shape;
    for (int i = 0; i < shape.length; i++) {
      for (int j = 0; j < shape[i].length; j++) {
        if (shape[i][j] == 0) continue;
        int row = current.row + i;
        int col = current.col + j;

        if (row >= 0 && row < rows && col >= 0 && col < cols) {
          _drawBlock(
            canvas, 
            col * blockWidth, 
            row * blockHeight, 
            blockWidth, 
            blockHeight, 
            current.color, 
            paint, 
            shadowPaint,
            isActive: true,
          );
        }
      }
    }

    // Draw subtle grid lines
    _drawGrid(canvas, size, blockWidth, blockHeight);
  }

  void _drawBlock(
    Canvas canvas, 
    double x, 
    double y, 
    double width, 
    double height, 
    Color color, 
    Paint paint, 
    Paint shadowPaint, {
    bool isActive = false,
  }) {
    final rect = Rect.fromLTWH(x + 1, y + 1, width - 2, height - 2);
    final roundedRect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    // Draw shadow for 3D effect
    if (!isActive) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2, y + 2, width - 2, height - 2),
          const Radius.circular(3),
        ),
        shadowPaint,
      );
    }

    // Draw main block with gradient
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(isActive ? 1.0 : 0.9),
        color.withOpacity(isActive ? 0.8 : 0.7),
      ],
    ).createShader(rect);
    canvas.drawRRect(roundedRect, paint);

    // Add highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(isActive ? 0.4 : 0.2)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(x + 2, y + 2),
      Offset(x + width - 2, y + 2),
      highlightPaint,
    );
    canvas.drawLine(
      Offset(x + 2, y + 2),
      Offset(x + 2, y + height - 2),
      highlightPaint,
    );

    // Add glow effect for active pieces
    if (isActive) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2, y - 2, width + 4, height + 4),
          const Radius.circular(5),
        ),
        glowPaint,
      );
    }
  }

  void _drawGhostPiece(Canvas canvas, double blockWidth, double blockHeight, Paint paint) {
    // Calculate ghost position
    final ghostTetromino = Tetromino(current.type);
    ghostTetromino.shape = current.shape.map((row) => List<int>.from(row)).toList();
    ghostTetromino.row = current.row;
    ghostTetromino.col = current.col;

    // Move ghost down until it can't move anymore
    while (board.isValidPosition(ghostTetromino, offsetRow: 1)) {
      ghostTetromino.row++;
    }

    // Only draw ghost if it's different from current position
    if (ghostTetromino.row != current.row) {
      final shape = ghostTetromino.shape;
      paint.color = current.color.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;

      for (int i = 0; i < shape.length; i++) {
        for (int j = 0; j < shape[i].length; j++) {
          if (shape[i][j] == 0) continue;
          int row = ghostTetromino.row + i;
          int col = ghostTetromino.col + j;

          if (row >= 0 && row < rows && col >= 0 && col < cols) {
            final rect = Rect.fromLTWH(
              col * blockWidth + 2, 
              row * blockHeight + 2, 
              blockWidth - 4, 
              blockHeight - 4,
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(rect, const Radius.circular(3)),
              paint,
            );
          }
        }
      }
      paint.style = PaintingStyle.fill; // Reset paint style
    }
  }

  void _drawGrid(Canvas canvas, Size size, double blockWidth, double blockHeight) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int c = 0; c <= cols; c++) {
      final x = c * blockWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (int r = 0; r <= rows; r++) {
      final y = r * blockHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TetrisPainter oldDelegate) {
    return true; // Always repaint for smooth animations
  }
}