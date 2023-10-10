import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:studyingx/providers/pencil_kit_state.dart';
import 'package:studyingx/views/molecules/app_button.dart';

class PencilKit extends StatefulWidget {
  const PencilKit({super.key});

  @override
  _PencilKitState createState() => _PencilKitState();
}

const activeIconSvgColorFilter =
    ColorFilter.mode(Colors.white, BlendMode.srcIn);
const inactiveIconSvgColorFilter =
    ColorFilter.mode(Color.fromARGB(56, 255, 255, 255), BlendMode.srcIn);

class _PencilKitState extends State<PencilKit> {
  @override
  Widget build(BuildContext context) {
    PencilKitState state = context.watch<PencilKitState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconButton(
          onPressed: () {
            if (state.drawMode == PencilKitMode.pen) {
              // already in pen mode
              // TODO :: float color picker
            }
            state.setDrawMode(PencilKitMode.pen);
          },
          icon: SvgPicture.asset(
            "assets/svg/pencil_kit_pencil.svg",
            height: 25,
            width: 25,
            colorFilter: state.drawMode == PencilKitMode.pen
                ? activeIconSvgColorFilter
                : inactiveIconSvgColorFilter,
          ),
        ),
        AppIconButton(
          onPressed: () => state.setDrawMode(PencilKitMode.eraser),
          icon: SvgPicture.asset(
            "assets/svg/pencil_kit_eraser.svg",
            height: 25,
            width: 25,
            colorFilter: state.drawMode == PencilKitMode.eraser
                ? activeIconSvgColorFilter
                : inactiveIconSvgColorFilter,
          ),
        ),
        // AppIconButton(
        //   onPressed: () => state.setDrawMode(PencilKitMode.fingerDraw),
        //   icon: SvgPicture.asset(
        //     "assets/svg/pencil_kit_finger_draw.svg",
        //     height: 25,
        //     width: 25,
        //     colorFilter: state.drawMode == PencilKitMode.fingerDraw
        //         ? activeIconSvgColorFilter
        //         : inactiveIconSvgColorFilter,
        //   ),
        // ),
        AppIconButton(
          onPressed: () => state.setDrawMode(PencilKitMode.move),
          icon: SvgPicture.asset(
            "assets/svg/pencil_kit_move.svg",
            height: 25,
            width: 25,
            colorFilter: state.drawMode == PencilKitMode.move
                ? activeIconSvgColorFilter
                : inactiveIconSvgColorFilter,
          ),
        ),
      ],
    );
  }
}
