import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyingx/data/note_core_info.dart';

DateFormat formatter = DateFormat('yyyy년 M월 d일', 'ko_KR');

class NotePreview extends StatelessWidget {
  const NotePreview({
    super.key,
    required this.width,
    required this.height,
    required this.coreInfo,
  });

  final double? width;
  final double? height;
  final NoteCoreInfo coreInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: const BoxDecoration(boxShadow: [
      //   BoxShadow(
      //     color: Color.fromARGB(100, 0, 0, 0),
      //     spreadRadius: -5,
      //     blurRadius: 7,
      //     offset: Offset(0, 3), // changes position of shadow
      //   )
      // ]),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          children: [
            Expanded(
              child: coreInfo.screenshot.isNotEmpty
                  ? Image.memory(
                      coreInfo.screenshot,
                      width: width,
                      height: 200,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      'assets/images/initial_page_bg.jpg',
                      width: width,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
