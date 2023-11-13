import 'package:flutter/material.dart';
import 'package:studyingx/views/styles/palette.dart';

class AppIconTextButton extends StatelessWidget {
  const AppIconTextButton(
      {super.key,
      required this.onPressed,
      required this.label,
      required this.icon});

  final void Function() onPressed;
  final String label;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
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
            if (states.contains(MaterialState.hovered)) {
              return Colors.transparent;
            }
            return Colors.transparent;
          },
        ),
        animationDuration: Duration.zero,
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
