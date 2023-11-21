import 'package:flutter/material.dart';
import 'package:studyingx/definitions/callbacks.dart';
import 'package:studyingx/views/fragments/pencil_kit.dart';
import 'package:studyingx/views/fragments/util_kit.dart';

class PencilKitBar extends StatefulWidget {
  const PencilKitBar(
      {Key? key,
      required this.onToggleColorPicker,
      required this.onToggleRecordPanel,
      required this.recording,
      required this.onBackBtnPressed})
      : super(key: key);

  final BoolCallback onToggleColorPicker;
  final VoidCallback onToggleRecordPanel;
  final VoidCallback onBackBtnPressed;
  final bool recording;

  @override
  State<StatefulWidget> createState() {
    return _PencilKitBarState();
  }
}

class _PencilKitBarState extends State<PencilKitBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 42, 42, 42),
      height: 40,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    widget.onBackBtnPressed();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color.fromARGB(56, 255, 255, 255),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PencilKit(
                onToggleColorPicker: widget.onToggleColorPicker,
              ),
            ),
            Expanded(
              child: UtilKit(
                onToggleRecordPanel: widget.onToggleRecordPanel,
                recording: widget.recording,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
