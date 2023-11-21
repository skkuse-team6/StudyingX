import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:studyingx/objects/paint.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/fragments/note_painters.dart';

const double pageHeightUnit = 800;
const double minPageHeight = 2 * pageHeightUnit;
const double panelExpandToleranceY = 50;

class NoteDrawer extends StatefulWidget {
  NoteDrawer({
    Key? key,
    String? path,
    List<Stroke>? strokes,
  })  : path = path ?? '',
        strokes = strokes ?? [],
        super(key: key);

  final String path;
  final List<Stroke> strokes;

  bool get isEmpty => strokes.isEmpty;
  bool get isNotEmpty => !isEmpty;

  factory NoteDrawer.fromJson(Map<String, dynamic> json) {
    return NoteDrawer(
      path: json['p'] as String? ?? '',
      strokes: parseStrokesJson(json['s'] as List?),
    );
  }

  Map<String, dynamic> toJson(List<Uint8List> assets) => {
        'p': path,
        's': strokes.map((stroke) => stroke.toJson()).toList(),
      };

  static List<Stroke> parseStrokesJson(
    List<dynamic>? strokes,
  ) =>
      strokes
          ?.map((dynamic stroke) {
            final map = stroke as Map<String, dynamic>;
            return Stroke.fromJson(map);
          })
          .cast<Stroke>()
          .toList() ??
      [];

  @override
  State<StatefulWidget> createState() {
    return _NoteDrawerState();
  }
}

class _NoteDrawerState extends State<NoteDrawer> {
  var logger = Logger();

  // scrolling
  final ScrollController _scrollController = ScrollController();

  // panel
  double panelHeight = minPageHeight;

  double calculateLastPointY() {
    double maxY = 0;
    for (int i = strokes.length - 1; i >= 0; i--) {
      final stroke = strokes[i];
      for (int j = stroke.edges.length - 1; j >= 0; j--) {
        final edge = stroke.edges[j];
        if (maxY < edge.start.dy) {
          maxY = edge.start.dy;
        }
        if (maxY < edge.end.dy) {
          maxY = edge.end.dy;
        }
      }
    }
    return maxY;
  }

  // drawing
  List<Stroke> strokes = [];
  Stroke currentStroke = Stroke([], Colors.black);
  PointerDeviceKind? drawingDevice;
  Offset? lastPoint;
  double? _currentPressure;
  double? _currentOrientation;
  double? _currentTilt;

  // erasing
  Offset? erasingPoint;
  double eraseRadius = 18; // TODO :: make this adjustable?

  // pointer handling
  final Map<int, PointerDeviceKind> pointers = {};

  // iOS Method Channel
  late final MethodChannel iOSChannel;

  @override
  void initState() {
    super.initState();

    // load strokes from file
    // TODO :: load strokes from file

    iOSChannel = const MethodChannel("com.studyingx/apple_pencil");
    iOSChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "applePencilSideDoubleTapped":
          logger.d("applePencilSideDoubleTapped");

          PencilKitState state =
              Provider.of<PencilKitState>(context, listen: false);
          if (state.drawMode == PencilKitMode.eraser) {
            state.setDrawMode(PencilKitMode.pen);
          } else {
            state.setDrawMode(PencilKitMode.eraser);
          }
      }
    });
  }

  @override
  void dispose() {
    iOSChannel.setMethodCallHandler(null);
    super.dispose();

    var strokesJson = strokes.map((stroke) => stroke.toObject()).toList();
    // TODO :: save strokesJson to file
  }

// getters and setters
  double get currentPressure => _currentPressure ?? 1.0;
  set currentPressure(double value) {
    setState(() {
      _currentPressure = value;
    });
  }

  double get currentOrientation => _currentOrientation ?? 0.0;
  set currentOrientation(double value) {
    setState(() {
      _currentOrientation = value;
    });
  }

  double get currentTilt => _currentTilt ?? 0.0;
  set currentTilt(double value) {
    setState(() {
      _currentTilt = value;
    });
  }

  bool get usingStylus =>
      pointers.values.any((device) => device == PointerDeviceKind.stylus);

  bool get usingMultiplePointers => pointers.length > 1;

  String getMode(PencilKitState state) {
    bool localStylus = usingStylus || state.regardFingerAsStylus;
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
    strokes = widget.strokes;

    PencilKitState state = context.watch<PencilKitState>();
    String mode = getMode(state);
    bool disableDefaultScrolling = mode == Mode.draw || mode == Mode.erase;

    void onPointerDown(PointerDownEvent e) {
      setState(() {
        if (!state.regardFingerAsStylus && e.kind != PointerDeviceKind.stylus) {
          // stylus is already in use, but finger is trying to draw
          // ignore finger
          return;
        }

        pointers[e.pointer] = e.kind;

        switch (mode) {
          case Mode.draw:
            currentStroke = Stroke([], Color(state.penColor));
            final point = e.localPosition;
            final absPoint =
                Offset(point.dx, point.dy + _scrollController.offset);
            lastPoint = absPoint;
            drawingDevice = e.kind;
            break;
        }
      });
    }

    void onPointerMove(PointerMoveEvent e) {
      setState(() {
        if (!state.regardFingerAsStylus && e.kind != PointerDeviceKind.stylus) {
          // stylus is already in use, but finger is trying to draw
          // ignore finger
          return;
        }

        pointers[e.pointer] = e.kind;
        currentPressure = e.pressure;
        currentOrientation = e.orientation;
        currentTilt = e.tilt;

        final point = e.localPosition;
        final absPoint = Offset(point.dx, point.dy + _scrollController.offset);

        switch (mode) {
          case Mode.draw:
            if (lastPoint != null) {
              double vertexPressure = currentPressure;
              final newEdge = Edge(lastPoint!, absPoint, vertexPressure);
              // if last point is same as current point, don't add edge
              if (newEdge.start != newEdge.end) {
                currentStroke.addEdge(newEdge);
              }
            }
            if (absPoint.dy > panelHeight - panelExpandToleranceY) {
              setState(() {
                panelHeight += pageHeightUnit;
              });
            }
            lastPoint = absPoint;
            break;
          case Mode.erase:
            final eraserRect =
                Rect.fromCircle(center: absPoint, radius: eraseRadius);
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

    void onPointerUp(PointerUpEvent e) {
      setState(() {
        pointers.remove(e.pointer);

        switch (mode) {
          case Mode.draw:
            // currentStroke.smoothify2();
            strokes.add(currentStroke);
            currentStroke = Stroke([], Color(state.penColor));
            lastPoint = null;
            break;
          case Mode.erase:
            if (panelHeight > minPageHeight) {
              double maxY = calculateLastPointY();
              logger.d("maxY: $maxY");
              while (
                  maxY < panelHeight - pageHeightUnit - panelExpandToleranceY) {
                panelHeight -= pageHeightUnit;
              }
            }
            erasingPoint = null;
            break;
        }
      });
    }

    void onPointerCancel(PointerCancelEvent e) {
      setState(() {
        pointers.remove(e.pointer);

        switch (mode) {
          case Mode.draw:
            strokes.add(currentStroke);
            currentStroke = Stroke([], Color(state.penColor));
            lastPoint = null;
            break;
          case Mode.erase:
            erasingPoint = null;
            break;
        }
      });
    }

    return GestureDetector(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
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
                    panelHeight, // expand if stroke reach the bottom (with padding)
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
                    CustomPaint(
                      painter: PageSegmentPainter(
                        pageHeightUnit: pageHeightUnit,
                        panelHeight: panelHeight,
                      ),
                      child: Container(),
                    ),
                    Positioned(
                      top: 100,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(174, 0, 0, 0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("mode: $mode",
                                style: const TextStyle(color: Colors.white)),
                            Text("drawing device: $drawingDevice",
                                style: const TextStyle(color: Colors.white)),
                            Text("pointers: ${pointers.length}",
                                style: const TextStyle(color: Colors.white)),
                            Text("using stylus: $usingStylus",
                                style: const TextStyle(color: Colors.white)),
                            Text("panel height: $panelHeight",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                                "current stroke: ${currentStroke.edges.length}",
                                style: const TextStyle(color: Colors.white)),
                            Text(
                              "pressure: ${currentPressure.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "orientation: ${currentOrientation.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              "tilt: ${currentTilt.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
