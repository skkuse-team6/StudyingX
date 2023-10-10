import 'package:flutter/material.dart';
import 'package:studyingx/views/fragments/pencil_kit.dart';
import 'package:studyingx/views/fragments/util_kit.dart';

class PencilKitBar extends StatefulWidget {
  const PencilKitBar({Key? key}) : super(key: key);

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
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color.fromARGB(56, 255, 255, 255),
                  ),
                ),
              ),
            ),
            const Expanded(child: PencilKit()),
            const Expanded(child: UtilKit()),
          ],
        ),
      ),
    );
  }
}
