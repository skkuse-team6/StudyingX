import 'package:flutter/material.dart';
import 'package:studyingx/objects/paint.dart';

class EraserPainter extends CustomPainter {
  EraserPainter({this.currentPoint, required this.eraseRadius});
  Offset? currentPoint;
  double eraseRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // draw eraser circle
    if (currentPoint != null) {
      final fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPoint!, eraseRadius, fillPaint);

      final borderPaint = Paint()
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawCircle(currentPoint!, eraseRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class StrokePainter extends CustomPainter {
  StrokePainter(this.strokes, this.currentStroke);
  List<Stroke> strokes = [];
  Stroke currentStroke;

  void drawStrokeAsPath(Canvas canvas, Stroke stroke) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    bool isFirstEdge = true;
    Offset? prevEnd;
    for (final edge in stroke.edges) {
      if (isFirstEdge) {
        path.moveTo(edge.start.dx, edge.start.dy);
        isFirstEdge = false;
      }

      paint.strokeWidth = edge.edgeWidth;

      final controlPoint = Offset(
        (edge.start.dx + edge.end.dx) / 2,
        (edge.start.dy + edge.end.dy) / 2,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        edge.end.dx,
        edge.end.dy,
      );

      prevEnd = edge.end;
    }

    canvas.drawPath(path, paint);
  }

  void drawStroke(Canvas canvas, Stroke stroke) {
    for (final edge in stroke.edges) {
      drawEdge(canvas, edge);
    }
  }

  void drawEdge(Canvas canvas, Edge edge) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = edge.edgeWidth;
    canvas.drawLine(edge.start, edge.end, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // draw edges
    for (final stroke in strokes) {
      drawStroke(canvas, stroke);
    }

    // draw current edge
    drawStroke(canvas, currentStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
