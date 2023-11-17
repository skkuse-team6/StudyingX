import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyingx/definitions/callbacks.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/fragments/note_drawer.dart';
import 'package:studyingx/views/fragments/pencil_kit_bar.dart';
import 'package:studyingx/views/fragments/record_panel.dart';
import 'package:studyingx/views/molecules/color_palette.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool showColorPicker = false;
  bool showRecordPanel = false;
  bool recording = false;
  int recordStartTime = 0;

  void onPressed() {
    Navigator.pop(context);
  }

  void onToggleColorPicker(bool mustHide) {
    setState(() {
      showColorPicker = mustHide ? false : !showColorPicker;
    });
  }

  void onToggleRecordPanel() {
    setState(() {
      showRecordPanel = !showRecordPanel;
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            PencilKitBar(
              onToggleColorPicker: onToggleColorPicker,
              onToggleRecordPanel: onToggleRecordPanel,
              recording: recording,
            ),
            Expanded(
              flex: 1,
              child: ClipRect(
                child: Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: const NoteDrawer(),
                    ),
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: HoveredPointerHelpSwitch(),
                    ),
                    RecordPanel(
                      onToggleRecord: onToggleRecord,
                      recording: recording,
                      recordStartTime: recordStartTime,
                      showRecordPanel: showRecordPanel,
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
        boxShadow: [
          const BoxShadow(
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
