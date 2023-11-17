import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:studyingx/views/molecules/app_button.dart';

const double recordPanelWidth = 250;
const String exampleScript =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi eget augue sit amet quam bibendum placerat non sed mi. Vestibulum molestie nulla erat, in convallis tortor hendrerit nec. Etiam ac diam vehicula, posuere purus ac, ultricies lacus. Suspendisse mattis ligula nec est porttitor sollicitudin. Quisque et metus non dui viverra semper non placerat ex. Vivamus arcu risus, convallis non est ac, congue ornare nunc. Nam elementum neque tristique tellus venenatis, molestie ultrices est elementum. Integer pellentesque est eros, eget venenatis nunc pulvinar vitae. Pellentesque malesuada mauris nec mauris posuere, sit amet dictum ligula cursus. Duis id nulla aliquet, rhoncus turpis nec, eleifend est. Vivamus tellus ante, sodales ac nunc ac, gravida lobortis dui. Nam luctus fringilla auctor. Nam id enim efficitur, rhoncus neque quis, tempor dui. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec hendrerit justo rhoncus libero dignissim congue. Nulla felis mi, imperdiet vitae consequat ac, euismod ut velit. Proin velit purus, egestas vel facilisis nec, malesuada non elit. Praesent sagittis enim quis sapien blandit, eu condimentum felis commodo. Nulla vitae sem non lectus placerat interdum. Phasellus convallis libero sit amet massa fermentum, a accumsan elit tempus. Nullam eleifend purus non leo lobortis, sed blandit libero fringilla. Suspendisse non turpis sit amet mi suscipit accumsan a vel ante. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec et nisl eget enim pharetra finibus et sed metus. Fusce pellentesque mollis sagittis. Sed at tincidunt nunc. Quisque sed mi viverra, facilisis sem et, facilisis arcu. Fusce tortor nisi, cursus eget massa eget, dapibus venenatis dolor. Fusce sit amet sapien bibendum, posuere lorem et, congue tellus. Nulla vitae eros condimentum, maximus orci in, imperdiet velit. Maecenas pharetra gravida ligula et tempor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi dapibus velit in commodo elementum. Fusce placerat sem nibh, id posuere ante porttitor sit amet. Praesent ac libero orci. Maecenas maximus pretium arcu at cursus. Morbi lobortis blandit pharetra. Mauris sodales mi porta ullamcorper ultrices. Praesent consequat mi et tincidunt pulvinar. Integer varius tellus augue, ut finibus dolor gravida ac. Sed viverra, est eu aliquam tempor, diam nibh imperdiet velit, id hendrerit risus augue in leo. Etiam vitae purus ac libero accumsan eleifend at in lacus.";

class RecordPanel extends StatefulWidget {
  const RecordPanel(
      {Key? key,
      required this.showRecordPanel,
      required this.recording,
      required this.recordStartTime,
      required this.onToggleRecord})
      : super(key: key);

  final bool showRecordPanel;
  final VoidCallback onToggleRecord;
  final bool recording;
  final int recordStartTime;

  @override
  State<StatefulWidget> createState() {
    return _RecordPanelState();
  }
}

class _RecordPanelState extends State<RecordPanel> {
  Timer? _timer;
  String elapsedTime = "0:00:00";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (widget.recording) {
          var diff = DateTime.now().difference(
              DateTime.fromMillisecondsSinceEpoch(widget.recordStartTime));
          elapsedTime = diff.toString().split(".")[0];
        } else {
          elapsedTime = "0:00:00";
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startRecord() {
    widget.onToggleRecord();
  }

  String currentRecordTime() {
    if (widget.recording) {
      return DateTime.now()
          .difference(
              DateTime.fromMillisecondsSinceEpoch(widget.recordStartTime))
          .toString()
          .split(".")[0];
    } else {
      return "00:00:00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.bounceOut,
      duration: const Duration(milliseconds: 700),
      top: 0,
      bottom: 0,
      right: widget.showRecordPanel ? 0 : -(recordPanelWidth + 20),
      child: Container(
        width: recordPanelWidth,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(100, 0, 0, 0),
              spreadRadius: 2,
              blurRadius: 20,
              offset: Offset.zero,
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              child: ElevatedButton(
                onPressed: null,
                child: Text("Dropdown script #1"),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: SingleChildScrollView(
                  child: Text(exampleScript),
                ),
              ),
            ),
            AppButton(
              onPressed: startRecord,
              label: widget.recording ? elapsedTime : "Start Recording",
              backgroundColor: widget.recording
                  ? const Color.fromARGB(255, 255, 112, 102)
                  : Color.fromARGB(255, 21, 160, 46),
              borderRadius: 0,
              height: 50,
              color: Colors.white,
            )
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: 50,
            //   alignment: Alignment.center,
            //   color: Color.fromARGB(255, 21, 160, 46),
            //   child: const Text(
            //     "Start Recording",
            //     style: InkWell(
            //       fontSize: 13,
            //       // fontWeight: FontWeight.normal,
            //       color: Color.fromARGB(255, 255, 255, 255),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
