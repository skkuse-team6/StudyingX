import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:studyingx/views/molecules/app_button.dart';

var logger = Logger();
const double recordPanelWidth = 250;

class SummaryPanel extends StatefulWidget {
  const SummaryPanel({
    Key? key,
    required this.script,
    required this.showSummaryPanel,
  }) : super(key: key);

  final String script;
  final bool showSummaryPanel;

  @override
  State<StatefulWidget> createState() {
    return _SummaryPanelState();
  }
}

class _SummaryPanelState extends State<SummaryPanel> {
  bool pdfUploaded = true;
  bool summaryLoaded = true;
  String fileId = "";
  String filename = "";
  String summary = "";

  @override
  void initState() {
    super.initState();
  }

  void uploadPDF() async {
    pdfUploaded = false;
    logger.d("Uploading PDF file");
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://api.dotoleeoak.me/upload_file/'));
    var multipartFile =
        await http.MultipartFile.fromPath('file', result.files.first.path!);
    request.files.add(multipartFile);

    try {
      // 요청 전송 및 응답 수신
      logger.d("Sending request");
      var response = await request.send();

      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        setState(() {
          pdfUploaded = true;
          fileId = json.decode(data)['file_id'];
          filename = path.basename(result.files.first.path!);
        });
      } else {
        logger.e('File Upload Failed');
      }
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void getSummary() async {
    setState(() {
      summaryLoaded = false;
    });
    logger.d("Getting summary");
    var query = {
      'file_id': fileId,
      'script': widget.script,
      'model_gpt': 'gpt-4',
    };
    var uri = Uri.https(
      'api.dotoleeoak.me',
      '/PDF_Summary/',
      query,
    );
    // var request =

    try {
      // 요청 전송 및 응답 수신
      logger.d("Sending request");
      // logger.d(request.url.toString());
      // logger.d(request.fields.toString());
      // logger.d(uri.toString());
      var response = await http.post(uri);

      if (response.statusCode == 200) {
        setState(() {
          var data = utf8.decode(response.bodyBytes);
          summary = json.decode(data)['text'];
        });
      } else {
        logger.e('Failed to get summary');
        logger.e(response.statusCode.toString());
      }
    } catch (e) {
      logger.e(e.toString());
    } finally {
      setState(() {
        summaryLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      curve: Curves.bounceOut,
      duration: const Duration(milliseconds: 700),
      top: 0,
      bottom: 0,
      right: widget.showSummaryPanel ? 0 : -(recordPanelWidth + 20),
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Container(
            //   child: const ElevatedButton(
            //     onPressed: null,
            //     child: Text("Dropdown script #1"),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Column(
                children: [
                  const Text("Upload lecture PDF file"),
                  if (pdfUploaded && filename != '')
                    Text(
                      filename,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  if (!pdfUploaded)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: uploadPDF,
                        style: ButtonStyle(
                          iconColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                        )),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  children: widget.script == ''
                      ? [
                          const Text(
                            "No Script Provided",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ]
                      : [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Generated Script"),
                          ),
                          Container(
                            width: double.infinity,
                            height: 110,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(widget.script),
                              ),
                            ),
                          ),
                        ],
                ),
              ),
            ),
            if (!summaryLoaded)
              const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (summary != "" && summaryLoaded)
              Flexible(
                flex: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Summary by AI",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 110,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              summary,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            AppButton(
              // onPressed: widget.recording ? stopRecord : startRecord,
              // label: widget.recording ? elapsedTime : "Start Recording",
              onPressed: getSummary,
              label: "Get Summary",
              backgroundColor: Colors.blue,
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
