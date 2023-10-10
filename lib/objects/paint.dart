import 'dart:ui';

class Edge {
  Edge(this.start, this.end, this.edgeWidth);
  Offset start = Offset.zero;
  Offset end = Offset.zero;
  double edgeWidth;

  bool intersectsWithCircle(Rect circle) {
    Offset center = circle.center;
    double radius = circle.width / 2;

    final startDistance = (start - center).distance;
    final endDistance = (end - center).distance;

    final halfEdgeWidth = edgeWidth / 2;

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
}

class Stroke {
  Stroke(this.edges);
  List<Edge> edges = [];

  void addEdge(Edge edge) {
    edges.add(edge);
  }
}

class Mode {
  static const String draw = "draw";
  static const String move = "move";
  static const String erase = "erase";
}
