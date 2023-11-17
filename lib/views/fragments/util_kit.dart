import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:studyingx/views/molecules/app_icon_button.dart';

class UtilKit extends StatefulWidget {
  const UtilKit(
      {super.key, required this.onToggleRecordPanel, required this.recording});

  final VoidCallback onToggleRecordPanel;
  final bool recording;

  @override
  _UtilKitState createState() => _UtilKitState();
}

const activeIconSvgColorFilter =
    ColorFilter.mode(Colors.white, BlendMode.srcIn);
const inactiveIconSvgColorFilter =
    ColorFilter.mode(Color.fromARGB(56, 255, 255, 255), BlendMode.srcIn);

class _UtilKitState extends State<UtilKit> {
  final bool _isAutoScriptPanelOpen = false;
  bool get isAutoScriptPanelOpen => _isAutoScriptPanelOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppIconButton(
          onPressed: widget.onToggleRecordPanel,
          icon: SvgPicture.asset(
            "assets/svg/mic_icon.svg",
            height: 20,
            width: 20,
            colorFilter: widget.recording
                ? ColorFilter.mode(Colors.red, BlendMode.srcIn)
                : inactiveIconSvgColorFilter,
          ),
        ),
        AppIconButton(
          onPressed: () {},
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 38, 255, 73),
                  Color.fromARGB(255, 176, 77, 255)
                ],
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            child: SvgPicture.asset(
              "assets/svg/gpt_icon.svg",
              height: 20,
              width: 20,
              color: Colors.white, // SVG의 기존 색상을 모두 하얀색으로 설정하여 그라데이션 적용
            ),
          ),
        ),
      ],
    );
  }
}
