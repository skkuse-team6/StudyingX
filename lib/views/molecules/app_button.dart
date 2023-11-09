import 'package:flutter/material.dart';
import 'package:studyingx/views/styles/palette.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton(
      {super.key, required this.onPressed, required this.icon, this.color});

  final void Function() onPressed;
  final Widget icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: 15,
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColor.highlight;
            }
            return Colors.white;
          },
        ),
        // transparent
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            return color ?? Colors.transparent;
          },
        ),
        animationDuration: Duration.zero,
      ),
    );
  }
}
