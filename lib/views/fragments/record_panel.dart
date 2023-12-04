import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:logger/logger.dart';
import 'package:studyingx/views/molecules/app_button.dart';

var logger = Logger();
const double recordPanelWidth = 250;

class RecordPanel extends StatefulWidget {
  const RecordPanel({
    Key? key,
    required this.showRecordPanel,
    required this.recording,
    required this.recordStartTime,
    required this.onToggleRecord,
    required this.onScriptLoaded,
  }) : super(key: key);

  final bool showRecordPanel;
  final VoidCallback onToggleRecord;
  final Function onScriptLoaded;
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
  String script = "Start recording to see the script.";
  late AudioRecorder record;
  bool scriptLoaded = true;

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

    record = AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<String> _getPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(
      dir.path,
      'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  void startRecord() async {
    if (await record.hasPermission()) {
      const config = RecordConfig(encoder: AudioEncoder.aacLc);
      String path = await _getPath();
      await record.start(config, path: path);
      setState(() {
        scriptLoaded = false;
      });
    }
    widget.onToggleRecord();
  }

  void stopRecord() async {
    widget.onToggleRecord();

    final path = await record.stop();
    logger.d("Stop recording: $path");

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://api.dotoleeoak.me/Speech-to-Text/'));

    var file = await http.MultipartFile.fromPath('file', path!);
    request.files.add(file);

    try {
      // 요청 전송 및 응답 수신
      logger.d("Sending request");
      var response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var jsonData = json.decode(data);
        setState(() {
          script = jsonData['text'];
          scriptLoaded = true;
          widget.onScriptLoaded(script);
        });
      } else {
        logger.e('File Upload Failed');
      }
    } catch (e) {
      logger.e(e.toString());
    }
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
            // Container(
            //   child: const ElevatedButton(
            //     onPressed: null,
            //     child: Text("Dropdown script #1"),
            //   ),
            // ),
            Expanded(
              flex: 1,
              child: scriptLoaded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: SingleChildScrollView(
                        child: Text(script),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
            AppButton(
              onPressed: widget.recording ? stopRecord : startRecord,
              label: widget.recording ? elapsedTime : "Start Recording",
              backgroundColor: widget.recording
                  ? const Color.fromARGB(255, 255, 112, 102)
                  : const Color.fromARGB(255, 21, 160, 46),
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
