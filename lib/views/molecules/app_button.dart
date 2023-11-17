import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton(
      {super.key,
      required this.onPressed,
      this.color,
      required this.label,
      this.borderRadius,
      this.height,
      this.backgroundColor});

  final void Function() onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        height: height ?? 40,
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color.fromARGB(255, 21, 160, 46),
          borderRadius: BorderRadius.circular(borderRadius ?? 0.0),
        ),
        child: Text(
          label,
          style: TextStyle(color: color ?? Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
