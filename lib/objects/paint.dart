import 'dart:math';
import 'dart:ui';

class PressuredVertex {
  PressuredVertex(this.point, this.pressure);
  Offset point;
  double pressure;
}

class Edge {
  Edge(this.start, this.end, this.pressure);
  Offset start = Offset.zero;
  Offset end = Offset.zero;
  double pressure;

  bool intersectsWithCircle(Rect circle) {
    Offset center = circle.center;
    double radius = circle.width / 2;

    final startDistance = (start - center).distance;
    final endDistance = (end - center).distance;

    final halfEdgeWidth = pressure / 2;

    if (startDistance <= radius + halfEdgeWidth ||
        endDistance <= radius + halfEdgeWidth) {
      // single vertex of the edge is inside the circle
      return true;
    }

    // calculate vector of edge
    final direction = end - start;
    // normalize
    final normalizedDirection = direction / direction.distance;
    // vector from circle center to edge start
    final toCenter = center - start;
    // project to line
    final projectionLength = toCenter.dx * normalizedDirection.dx +
        toCenter.dy * normalizedDirection.dy;

    if (projectionLength < 0 || projectionLength > direction.distance) {
      // projection is outside the edge
      return false;
    }

    final projectionPoint = start + normalizedDirection * projectionLength;
    // distance from projection point to circle center
    final distanceToCenter = (projectionPoint - center).distance;
    return distanceToCenter <= radius + halfEdgeWidth;
  }

  Object toObject() {
    return {
      "start": {"x": start.dx, "y": start.dy},
      "end": {"x": end.dx, "y": end.dy},
      "pressure": pressure
    };
  }
}

class Stroke {
  Stroke(this.edges, this.color);
  List<Edge> edges = [];
  Color color;

  void addEdge(Edge edge) {
    edges.add(edge);
  }

  List<PressuredVertex> getVertices() {
    List<PressuredVertex> vertices = [];
    if (edges.isEmpty) return vertices;
    vertices.add(PressuredVertex(edges.first.start, edges.first.pressure));
    for (final edge in edges) {
      vertices.add(PressuredVertex(edge.end, edge.pressure));
    }
    return vertices;
  }

  Object toObject() {
    return {
      "edges": edges.map((e) => e.toObject()).toList(),
      "color": color.value
    };
  }
}

class Mode {
  static const String draw = "draw";
  static const String move = "move";
  static const String erase = "erase";
}

double pointLineDistance(Offset point, Offset startLine, Offset endLine) {
  var num = (startLine.dy - endLine.dy) * point.dx -
      (startLine.dx - endLine.dx) * point.dy +
      startLine.dx * endLine.dy -
      startLine.dy * endLine.dx;
  var denom =
      pow(startLine.dx - endLine.dx, 2) + pow(startLine.dy - endLine.dy, 2);
  return num.abs() / sqrt(denom);
}

List<Offset> douglasPeucker(List<Offset> points, double epsilon) {
  if (points.length <= 2) {
    return points;
  }

  double maxDistance = 0.0;
  int index = 0;

  for (int i = 1; i < points.length - 1; i++) {
    double distance = pointLineDistance(points[i], points.first, points.last);

    if (distance > maxDistance) {
      maxDistance = distance;
      index = i;
    }
  }

  if (maxDistance > epsilon) {
    var left = douglasPeucker(points.sublist(0, index + 1), epsilon);
    var right = douglasPeucker(points.sublist(index), epsilon);

    return [...left, ...right.skip(1)];
  } else {
    return [points.first, points.last];
  }
}
