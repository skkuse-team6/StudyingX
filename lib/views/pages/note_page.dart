import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logging/logging.dart';
import 'package:studyingx/definitions/callbacks.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/fragments/note_drawer.dart';
import 'package:studyingx/views/fragments/pencil_kit_bar.dart';
import 'package:studyingx/views/fragments/summary_pannel.dart';
import 'package:studyingx/views/molecules/color_palette.dart';
import 'package:studyingx/data/file_manager.dart';
import 'package:studyingx/data/note_core_info.dart';
import 'package:studyingx/views/molecules/preview_card.dart';
import 'package:screenshot/screenshot.dart';
import 'package:studyingx/views/fragments/record_panel.dart';

class NotePage extends StatefulWidget {
  final log = Logger('NotePageState');

  NotePage({Key? key, String? path})
      : initialPath =
            path != null ? Future.value(path) : FileManager.newFilePath('/'),
        super(key: key);

  final Future<String> initialPath;

  static const String extension = '.stdx';

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final log = Logger('NotePageState');

  late NoteCoreInfo coreInfo = NoteCoreInfo(filePath: '');
  late NoteDrawer noteDrawer = coreInfo.page;
  late String path = '';

  ScreenshotController screenshotController = ScreenshotController();
  Uint8List screenshot = Uint8List(0);
  bool captured = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showColorPicker = false;
  bool showRecordPanel = false;
  bool showSummaryPanel = false;
  bool recording = false;
  int recordStartTime = 0;
  String script = '';

  @override
  void initState() {
    _initAsync();

    super.initState();
  }

  String get _filename =>
      coreInfo.filePath.substring(coreInfo.filePath.lastIndexOf('/') + 1);

  void _initAsync() async {
    coreInfo = PreviewCard.getCachedCoreInfo(await widget.initialPath);
    await _initStrokes();
  }

  Future _initStrokes() async {
    coreInfo = await NoteCoreInfo.loadFromFilePath(coreInfo.filePath);
    setState(() {});
  }

  Future<void> saveToFile() async {
    coreInfo.screenshot = screenshot;
    coreInfo.captured = captured;
    coreInfo.page = noteDrawer;
    final toSave = coreInfo.serializeToBSON();
    try {
      await FileManager.writeFile(coreInfo.filePath, toSave, awaitWrite: true);
    } catch (e) {
      log.severe('Failed to save file: $e', e);
      if (kDebugMode) rethrow;
    }
  }

  void onBackBtnPressed() {
    screenshotController
        .capture(delay: const Duration(milliseconds: 20))
        .then((Uint8List? image) {
      if (image != null) {
        setState(() {
          screenshot = image;
          captured = true;
        });
        Navigator.pop(context);
      }
    });
  }

  void onToggleColorPicker(bool mustHide) {
    setState(() {
      showColorPicker = mustHide ? false : !showColorPicker;
    });
  }

  void onToggleRecordPanel() {
    setState(() {
      showSummaryPanel = false;
      showRecordPanel = !showRecordPanel;
    });
  }

  void onToggleSummaryPanel() {
    setState(() {
      showRecordPanel = false;
      showSummaryPanel = !showSummaryPanel;
    });
  }

  void updateScript(String script) {
    setState(() {
      this.script = script;
    });
  }

  void onToggleRecord() {
    setState(() {
      if (recording) {
        recordStartTime = 0;
      } else {
        recordStartTime = DateTime.now().millisecondsSinceEpoch;
      }
      recording = !recording;
    });
  }

  @override
  Widget build(BuildContext context) {
    noteDrawer = coreInfo.page;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton.small(
      //   onPressed: () async {
      //     await screenshotController
      //         .capture(delay: const Duration(milliseconds: 20))
      //         .then((Uint8List? image) {
      //       if (image != null) {
      //         setState(() {
      //           screenshot = image;
      //           captured = true;
      //         });
      //       }
      //     });
      //     onPressed();
      //   },
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(50),
      //   ),
      //   backgroundColor: Colors.lightGreen,
      //   child: const Icon(Icons.save, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: SafeArea(
        child: Column(
          children: [
            PencilKitBar(
              onToggleColorPicker: onToggleColorPicker,
              onToggleRecordPanel: onToggleRecordPanel,
              onToggleSummaryPanel: onToggleSummaryPanel,
              onBackBtnPressed: onBackBtnPressed,
              recording: recording,
            ),
            Expanded(
              flex: 1,
              child: ClipRect(
                child: Stack(
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: noteDrawer,
                      ),
                    ),
                    // const Positioned(
                    //   top: 10,
                    //   left: 10,
                    //   child: HoveredPointerHelpSwitch(),
                    // ),
                    RecordPanel(
                      onToggleRecord: onToggleRecord,
                      recording: recording,
                      recordStartTime: recordStartTime,
                      showRecordPanel: showRecordPanel,
                      onScriptLoaded: updateScript,
                    ),
                    SummaryPanel(
                      script: script,
                      showSummaryPanel: showSummaryPanel,
                    ),
                    if (showColorPicker)
                      Positioned(
                        top: 15,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: ColorPicker(
                            onToggleColorPicker: onToggleColorPicker,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    (() async {
      await saveToFile();
    })();
    super.dispose();
  }
}

class ColorPicker extends StatefulWidget {
  const ColorPicker({Key? key, required this.onToggleColorPicker})
      : super(key: key);

  final BoolCallback onToggleColorPicker;

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  void onColorPick(Color color) {
    PencilKitState state = Provider.of<PencilKitState>(context, listen: false);
    state.setPenColor(color.value);
    widget.onToggleColorPicker(true);
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> colorPickerTemplateColors = [
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(25, 0, 0, 0)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            spreadRadius: 1,
            offset: Offset(0, 2),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ...colorPickerTemplateColors.map((color) {
            return ColorPalette(
              color: color,
              onPressed: onColorPick,
            );
          }).toList(),
          ColorPalette(
            color: Colors.black,
            onPressed: onColorPick,
            backgroundImage:
                const AssetImage("assets/images/custom_color_bg.png"),
          ),
        ],
      ),
    );
  }
}

// debug
class HoveredPointerHelpSwitch extends StatefulWidget {
  const HoveredPointerHelpSwitch({Key? key}) : super(key: key);

  @override
  State<HoveredPointerHelpSwitch> createState() =>
      _HoveredPointerHelpSwitchState();
}

class _HoveredPointerHelpSwitchState extends State<HoveredPointerHelpSwitch> {
  @override
  Widget build(BuildContext context) {
    PencilKitState state = context.watch<PencilKitState>();

    return Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: Color.fromARGB(148, 0, 0, 0)),
        child: Row(
          children: [
            const Text(
              "[Debug] recognize finger/mouse as stylus",
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            const SizedBox(width: 10),
            Transform.scale(
              scale: 0.7,
              child: SizedBox(
                height: 15,
                width: 30,
                child: Switch(
                  splashRadius: 25,
                  value: state.regardFingerAsStylus,
                  onChanged: (value) {
                    setState(() {
                      state.setRegardFingerAsStylus(value);
                    });
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
