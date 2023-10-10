import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:studyingx/objects/paint.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/fragments/note_painters.dart';

const minEdgeWidth = 3;

class NoteDrawer extends StatefulWidget {
  const NoteDrawer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NoteDrawerState();
  }
}

class _NoteDrawerState extends State<NoteDrawer> {
  var logger = Logger();

  // scrolling
  final ScrollController _scrollController = ScrollController();

  // drawing
  List<Stroke> strokes = [];
  Stroke currentStroke = Stroke([]);
  PointerDeviceKind? drawingDevice;
  Offset? lastPoint;
  double? _currentPressure;

  // erasing
  Offset? erasingPoint;
  double eraseRadius = 18; // TODO :: make this adjustable?

  // pointer handling
  final Map<int, Offset> pointers = {};

// getters and setters
  double get currentPressure => _currentPressure ?? 1.0;
  set currentPressure(double value) {
    setState(() {
      _currentPressure = value;
    });
  }

  bool get isStylus => drawingDevice == PointerDeviceKind.stylus;
  bool get usingMultiplePointers => pointers.length > 1;

  String getMode(PencilKitState state) {
    bool localStylus = isStylus || state.regardFingerAsStylus;
    switch (state.drawMode) {
      case PencilKitMode.pen:
        return localStylus ? Mode.draw : Mode.move;
      case PencilKitMode.eraser:
        return localStylus ? Mode.erase : Mode.move;
      case PencilKitMode.move:
        return Mode.move;
      default:
        return Mode.move;
    }
  }

  @override
  Widget build(BuildContext context) {
    PencilKitState state = context.watch<PencilKitState>();
    String mode = getMode(state);
    bool disableDefaultScrolling = mode == Mode.draw || mode == Mode.erase;

    void onPanStart(DragStartDetails details) {
      setState(() {
        drawingDevice = details.kind;
        logger.d(drawingDevice);
        logger.d(mode);

        switch (mode) {
          case Mode.draw:
            final point = details.localPosition;
            final absPoint =
                Offset(point.dx, point.dy + _scrollController.offset);
            lastPoint = absPoint;
            break;
        }
      });
    }

    void onPanUpdate(DragUpdateDetails details) {
      setState(() {
        final point = details.localPosition;
        final absPoint = Offset(point.dx, point.dy + _scrollController.offset);
        switch (mode) {
          case Mode.draw:
            if (lastPoint != null) {
              double edgeWidth = minEdgeWidth * max(currentPressure, 1.0);
              final newEdge = Edge(lastPoint!, absPoint, edgeWidth);
              currentStroke.addEdge(newEdge);
            }
            lastPoint = absPoint;
            break;
          case Mode.erase:
            final eraserRect =
                Rect.fromCircle(center: point, radius: eraseRadius);
            strokes.removeWhere((stroke) {
              return stroke.edges.any((edge) {
                return edge.intersectsWithCircle(eraserRect);
              });
            });
            erasingPoint = absPoint;
            break;
        }
      });
    }

    void onPanEnd(DragEndDetails details) {
      setState(() {
        switch (mode) {
          case Mode.draw:
            strokes.add(currentStroke);
            currentStroke = Stroke([]);
            lastPoint = null;
            break;
          case Mode.erase:
            erasingPoint = null;
            break;
        }
      });
    }

    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerMove: (PointerMoveEvent e) {
          setState(() {
            currentPressure = e.pressure;
          });
        },
        child: Listener(
          onPointerDown: (e) {
            pointers[e.pointer] = e.position;
          },
          onPointerUp: (e) {
            pointers.remove(e.pointer);
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: disableDefaultScrolling
                ? const NeverScrollableScrollPhysics()
                : null,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height:
                      5000, // expand if stroke reach the bottom (with padding)
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: StrokePainter(strokes, currentStroke),
                        child: Container(),
                      ),
                      if (mode == Mode.erase)
                        CustomPaint(
                          painter: EraserPainter(
                              currentPoint: erasingPoint,
                              eraseRadius: eraseRadius),
                          child: Container(),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
