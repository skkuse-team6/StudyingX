import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/fragments/note_drawer.dart';
import 'package:studyingx/views/fragments/pencil_kit_bar.dart';
import 'package:studyingx/views/molecules/app_button.dart';
import 'package:studyingx/views/molecules/app_icon_text_button.dart';
import 'package:studyingx/views/styles/palette.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  void onPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PencilKitBar(),
            Expanded(
              flex: 1,
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
                  )
                ],
              ),
            ),
          ],
        ),
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
        decoration: BoxDecoration(color: Color.fromARGB(148, 0, 0, 0)),
        child: Row(
          children: [
            Text(
              "[Debug] recognize finger/mouse as stylus",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            SizedBox(width: 10),
            Transform.scale(
              scale: 0.7,
              child: Container(
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
