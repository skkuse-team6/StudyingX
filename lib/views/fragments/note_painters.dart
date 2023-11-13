import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:studyingx/objects/paint.dart';

class PageSegmentPainter extends CustomPainter {
  PageSegmentPainter({required this.panelHeight, required this.pageHeightUnit});
  final double panelHeight;
  final double pageHeightUnit;

  @override
  void paint(Canvas canvas, Size size) {
    int segments = panelHeight ~/ pageHeightUnit;
    for (int i = 1; i <= segments; i++) {
      final paint = Paint()
        ..color = const Color.fromARGB(70, 0, 0, 0)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.0
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, pageHeightUnit * i),
          Offset(size.width, pageHeightUnit * i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

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

  // void drawStroke(Canvas canvas, Stroke stroke) {
  //   for (final edge in stroke.edges) {
  //     drawEdge(canvas, edge, stroke.color);
  //   }
  // }

  // void drawEdge(Canvas canvas, Edge edge, Color color) {
  //   final paint = Paint()
  //     ..color = color
  //     ..strokeCap = StrokeCap.round
  //     ..strokeWidth = edge.pressure * 5
  //     ..strokeJoin = StrokeJoin.round
  //     ..isAntiAlias = true;
  //   canvas.drawLine(edge.start, edge.end, paint);
  // }

  @override
  void paint(Canvas canvas, Size size) {
    List<Stroke> allStrokes = [...strokes, currentStroke];
    // draw edges
    for (final stroke in allStrokes) {
      drawSmoothStroke(canvas, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawSmoothStroke(Canvas canvas, Stroke stroke) {
    List<Point> points = [];
    for (final vertex in stroke.getVertices()) {
      points.add(Point(vertex.point.dx, vertex.point.dy, vertex.pressure));
    }

    final outlinePoints = getStroke(
      points,
      size: 5,
      thinning: 0.7,
      smoothing: 0.5,
      streamline: 0.5,
      taperStart: 0.0,
      taperEnd: 0.0,
      capStart: true,
      capEnd: true,
      simulatePressure: false,
      isComplete: false,
    );

    final path = Path();

    if (outlinePoints.isEmpty) {
      // If the list is empty, don't do anything.
      return;
    } else if (outlinePoints.length < 2) {
      // If the list only has one point, draw a dot.
      path.addOval(Rect.fromCircle(
          center: Offset(outlinePoints[0].x, outlinePoints[0].y), radius: 1));
    } else {
      // Otherwise, draw a line that connects each point with a bezier curve segment.
      path.moveTo(outlinePoints[0].x, outlinePoints[0].y);

      for (int i = 1; i < outlinePoints.length - 1; ++i) {
        final p0 = outlinePoints[i];
        final p1 = outlinePoints[i + 1];
        path.quadraticBezierTo(
            p0.x, p0.y, (p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
      }
    }

    // 3. Draw the path to the canvas
    Paint paint = Paint()..color = stroke.color;
    canvas.drawPath(path, paint);
  }

  // void drawStrokeAsPath(Canvas canvas, Stroke stroke) {
  //   if (stroke.edges.isEmpty) return;

  //   List<Edge> groupedEdges = [];
  //   double currentWidth = stroke.edges.first.pressure;

  //   for (final edge in stroke.edges) {
  //     if (edge.pressure != currentWidth) {
  //       // Draw the accumulated edges first
  //       _drawSmoothPathFromEdges(canvas, groupedEdges, currentWidth);

  //       // Reset for the next group
  //       groupedEdges = [];
  //       currentWidth = edge.pressure;
  //     }
  //     groupedEdges.add(edge);
  //   }

  //   // Draw the remaining edges
  //   if (groupedEdges.isNotEmpty) {
  //     _drawSmoothPathFromEdges(canvas, groupedEdges, currentWidth);
  //   }
  // }

  // void _drawSmoothPathFromEdges(Canvas canvas, List<Edge> edges, double width) {
  //   final paint = Paint()
  //     ..color = Colors.black
  //     ..strokeCap = StrokeCap.round
  //     ..strokeWidth = width
  //     ..strokeJoin = StrokeJoin.round
  //     ..isAntiAlias = true
  //     ..style = PaintingStyle.stroke;

  //   final path = Path();
  //   path.moveTo(edges.first.start.dx, edges.first.start.dy);

  //   for (final edge in edges) {
  //     // path.lineTo(edge.end.dx, edge.end.dy);
  //     path.cubicTo(
  //       edge.start.dx,
  //       edge.start.dy,
  //       edge.end.dx,
  //       edge.end.dy,
  //       edge.end.dx,
  //       edge.end.dy,
  //     );
  //   }

  //   canvas.drawPath(path, paint);
  // }
}
