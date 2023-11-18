import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  Color? customColor;
  void setCustomColor(Color color) {
    setState(() {
      customColor = color;
    });
  }

  void floatColorPicker(BuildContext context) {
    Color pickerColor = customColor ?? Colors.black;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Custom Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: setCustomColor,
            enableAlpha: false,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: setCustomColor,
          //   enableLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: setCustomColor,
          // ),
          //
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              widget.onPressed!(customColor ?? Colors.black);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
