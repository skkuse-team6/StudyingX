import 'package:flutter/material.dart';

class TouchableCard extends StatelessWidget {
  const TouchableCard({
    Key? key,
    required this.onTap,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: margin,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 10),
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 10),
          child: InkWell(
            onTap: onTap,
            child: child,
          )),
    );
  }
}
