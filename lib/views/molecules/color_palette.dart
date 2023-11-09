import 'dart:math';

import 'package:flutter/material.dart';

typedef Callback = void Function(Color color);

class ColorPalette extends StatefulWidget {
  const ColorPalette(
      {super.key, required this.color, this.onPressed, this.backgroundImage});

  final Color color;
  final Callback? onPressed;
  final AssetImage? backgroundImage;

  @override
  State<StatefulWidget> createState() {
    return _ColorPaletteState();
  }
}

class _ColorPaletteState extends State<ColorPalette> {
  Color customColor = Colors.black;
  void setCustomColor(Color color) {
    setState(() {
      customColor = color;
    });
  }

  void floatColorPicker(BuildContext context) {
    // TODO: implement floatColorPicker
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.backgroundImage != null
          ? floatColorPicker(context)
          : widget.onPressed!(widget.color),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 22,
        height: 22,
        decoration: widget.backgroundImage != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: widget.backgroundImage!,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(25),
              )
            : BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(25),
              ),
      ),
    );
  }
}
